
VERSION < v"0.4-" && using Docile

include("utils.jl")
include("model.jl")
include("triang.jl")
include("polyline.jl")
include("procrustes.jl")
include("warp.jl")
include("data.jl")
include("view.jl")




function train(m::AAModel, imgs::Vector{Matrix{Float64}}, shapes::Vector{Shape})
    @assert length(imgs) == length(shapes) "Different number of images and landmark sets"
    n_scales = length(m.scales)
    n_samples = length(imgs)
    
    # triangulating
    
    
    
end



function test_train()
    imgs = read_images(IMG_DIR, 1000)
    shapes = read_landmarks(LM_DIR, 1000)
    m = AAModel(68, [1, 2])
    train(m, imgs, all_lms)
end
