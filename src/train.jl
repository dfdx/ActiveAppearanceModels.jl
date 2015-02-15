

using MultivariateStats


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


function warp_maps(m::AAModel)
    trigs = delaunayindexes(reshape(m.s0, int(length(m.s0) / 2), 2))
    modelh, modelw = m.frame.h, m.frame.w
    warp_map = zeros(Int, modelh, modelw)
    alpha_coords = zeros(modelh, modelw)
    beta_coords = zeros(modelh, modelw)
    for j=1:modelw
        for i=1:modelh
            for k=1:size(trigs, 1)
                t = trigs[k, :]				
                i1 = m.s0[t[1]]
                j1 = m.s0[m.np + t[1]]
                i2 = m.s0[t[2]]
                j2 = m.s0[m.np + t[2]]
                i3 = m.s0[t[3]]
                j3 = m.s0[m.np + t[3]]
                                
                den = (i2 - i1) * (j3 - j1) - (j2 - j1) * (i3 - i1)
                alpha = ((i - i1) * (j3 - j1) - (j - j1) * (i3 - i1)) / den
                beta = ((j - j1) * (i2 - i1) - (i - i1) * (j2 - j1)) / den
                
                if alpha >= 0 && beta >= 0 && (alpha + beta) <= 1
                    # found the triangle, save data to the bitmaps and break
                    warp_map[i, j] = k
                    alpha_coords[i, j] = alpha
                    beta_coords[i,j] = beta
                    break;
                end                
            end
        end
    end
    return warp_map, alpha_coords, beta_coords
end


function init_shape_model!(m::AAModel, shapes::Vector{Shape})
    m.np = size(shapes[1], 1)
    mean_shape, shapes_aligned = align_shapes(shapes)
    # do we need to move shape center to origin?
    m.frame = ModelFrame(int(minimum(mean_shape[:, 1])), int(minimum(mean_shape[:, 2])),
                         int(maximum(mean_shape[:, 1])), int(maximum(mean_shape[:, 2])))    
    shape_mat = datamatrix(Shape[shape .- mean_shape for shape in shapes_aligned])
    shape_pca = fit(PCA, shape_mat)
    pc = projection(shape_pca)
    # base shape, global transform shape and transformation matrix
    m.s0 = flatten(mean_shape)    
    m.s_star, m.S = global_shape_transform(m.s0, pc)
    # precomputed helpers
    m.warp_map, m.alpha_coords, m.beta_coords = warp_maps(m)
end



function init_app_model!(m::AAModel, imgs::Vector{Matrix{Float64}}, shapes::Vector{Shape})
    app_mat = zeros(m.frame.h * m.frame.w, length(imgs))
    trigs = delaunayindexes(shapes[1])
    for i=1:length(imgs)
        warped = warp(imgs[i], shapes[i], reshape(m.s0, m.np, 2), trigs)
        warped_frame = warped[m.frame.mini-1:m.frame.maxi+1, m.frame.minj-1:m.frame.maxj+1]
        app_mat[:, i] = flatten(warped_frame)
    end
    m.A0 = squeeze(mean(app_mat, 2), 2)
    m.A = projection(fit(PCA, app_mat .- m.A0))
    di, dj = gradient2d(reshape(m.A0, m.frame.h, m.frame.w), m.warp_map)
    m.dA0 = Grad2D(di, dj)
end



function train(m::AAModel, imgs::Vector{Matrix{Float64}}, shapes::Vector{Shape})
    @assert length(imgs) == length(shapes) "Different number of images and landmark sets"
    @assert(0 <= minimum(imgs[1]) && maximum(imgs[1]) <= 1,
            "Images should be in Float64 format with values in [0..1]")
    m = AAModel()   
    init_shape_model!(m, shapes)
    init_app_model!(m, imgs, shapes)
    
    



end



function test_train()
    imgs = read_images(IMG_DIR, 1000)
    shapes = read_landmarks(LM_DIR, 1000)
    m = AAModel()
    # train(m, imgs, all_lms)
end
