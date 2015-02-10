

using MultivariateStats


##      s1_star = AAM.s0;
## 	s2_star(1:np) = -AAM.s0(np+1:end);
## 	s2_star(np+1:2*np) = AAM.s0(1:np);
## 	s3_star(1:np) = ones(np,1);
## 	s3_star(np+1:2*np) = zeros(np,1);
## 	s4_star(1:np) = zeros(np,1);
## 	s4_star(np+1:2*np) = ones(np,1);

## 	% Stack the basis we found before with the shape basis so
## 	% we can orthonormalize
## 	s_star_pc(:,1) = s1_star;
## 	s_star_pc(:,2) = s2_star;
## 	s_star_pc(:,3) = s3_star;
## 	s_star_pc(:,4) = s4_star;

## 	s_star_pc(:,5:size(pc,2)+4) = pc;


## 	% Orthogonalize the basis (should already be close to orthogonal)
## 	s_star_pc = gs_orthonorm(s_star_pc);

## 	% Basis for the global shape transform
## 	AAM.s_star = s_star_pc(:,1:4);
## 	% Basis for the shape model
## 	AAM.s = s_star_pc(:,5:end);


# add gloabl shape transformation parameters and orthonormalize all vectors
function global_shape_transform(s0, pc)
    npc = size(pc, 2)
    np = int(length(s0) / 2)
    # columns 1:4 - global transform params
    # columns 5:end - shape principal components
    s_star_pc = zeros(2*np, npc+4)
    s_star_pc[:, 1] = s0
    s_star_pc[1:np, 2] = -s0[np+1:end]
    s_star_pc[np+1:end, 2] = s0[1:np]
    s_star_pc[1:np, 3] = ones(np)
    s_star_pc[np+1:end, 3] = zeros(np)
    s_star_pc[1:np, 4] = zeros(np)
    s_star_pc[np+1:2*np] = ones(np)
    s_star_pc[:, 5:end] = pc
    # orthonormalizing all
    s_star_pc = gs_orthonorm(s_star_pc)
    # splitting back into global transformation params and star
    s_star, S = s_star_pc[:, 1:4], s_star_pc[:, 5:end]
    return s_star, S
end


function init_shape_model!(aam::AAModel, shapes::Vector{Shape})
    mean_shape, shapes_aligned = align_shapes(shapes)
    # do we need to move shape center to origin?
    mini = minimum(mean_shape[:, 1])
    minj = minimum(mean_shape[:, 2])
    maxi = maximum(mean_shape[:, 1])
    maxj = maximum(mean_shape[:, 2])
    modelw = ceil(maxj - minj + 3)
    modelh = ceil(maxi - mini + 3)
    shape_mat = datamatrix(Shape[shape .- mean_shape for shape in shapes_aligned])
    shape_pca = fit(PCA, shape_mat)
    pc = projection(shape_pca)
    
    s0 = flatten(mean_shape)    
    s_star, S = global_shape_transform(s0, pc)
    
    aam.s0 = s0
    aam.s_star = s_star
    aam.S = S
end





function train(m::AAModel, imgs::Vector{Matrix{Float64}}, shapes::Vector{Shape})
    @assert length(imgs) == length(shapes) "Different number of images and landmark sets"
    @assert(maximum(imgs) <= 1 && minimum(imgs) >= 0, "Images should be in Float64 format " +
            "with values in [0..1]")
    ns = length(shapes)                                      # number of shapes
    np = size(shapes[1], 1)                                  # number of points in each shape
    nc = length(size(imgs[1])) == 3 ? size(imgs[1], 3) : 1   # number of colors
    m.np = np
    init_shape_model!(m, shapes)




end



function test_train()
    imgs = read_images(IMG_DIR, 1000)
    shapes = read_landmarks(LM_DIR, 1000)
    m = AAModel(68)
    # train(m, imgs, all_lms)
end
