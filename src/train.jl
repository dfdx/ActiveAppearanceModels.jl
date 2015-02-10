


function train(m::AAModel, imgs::Vector{Matrix{Float64}}, shapes::Vector{Shape})
    @assert length(imgs) == length(shapes) "Different number of images and landmark sets"
    @assert(maximum(imgs) <= 1 && minimum(imgs) >= 0, "Images should be in Float64 format " +
            "with values in [0..1]")
    ns = length(shapes)      # number of shapes
    np = size(shapes[1], 1)  # number of points in each shape
    nc = length(size(imgs[1])) == 3 ? size(imgs[1], 3) : 1    
    shape_model = create_shape_model(shapes)
    
    
    
    
end



function test_train()
    imgs = read_images(IMG_DIR, 1000)
    shapes = read_landmarks(LM_DIR, 1000)
    m = AAModel(68, [1, 2])
    train(m, imgs, all_lms)
end
