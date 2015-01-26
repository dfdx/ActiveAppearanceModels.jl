
include("utils.jl")
include("model.jl")
include("triang.jl")
include("procrustes.jl")
include("warp.jl")
include("data.jl")
include("view.jl")

using MultivariateStats


function train(m::AAModel, imgs::Vector{Matrix{Float64}}, shapes::Vector{Shape})
    @assert length(imgs) == length(shapes) "Different number of images and landmark sets"
    n_scales = length(m.scales)
    n_samples = length(imgs)
    shapes_aligned = align_shapes(shapes)
    m.s0 = mean(shapes_aligned)
    shape_mat = datamatrix(Shape[s .- m.s0 for s in shapes_aligned])
    S_PCA = fit(PCA, shape_mat)
    S = projection(S_PCA)
    # triangulating
    
    
    
end



function test_train()
    imgs = read_images(IMG_DIR, 1000)
    shapes = read_landmarks(LM_DIR, 1000)
    m = AAModel(68, [1, 2])
    train(m, imgs, all_lms)
end
