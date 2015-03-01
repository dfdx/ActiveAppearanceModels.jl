
VERSION < v"0.4-" && using Docile
using StatsBase

include("utils.jl")
include("model.jl")
include("triang.jl")
include("polyline.jl")
include("procrustes.jl")
include("data.jl")
include("pwa.jl")
include("gradient2d.jl")
include("train.jl")
include("fit.jl")
include("view.jl")


function test_fit2d()    
    isdefined(:imgs) || (imgs = read_images(IMG_DIR, 1000))
    isdefined(:shapes) || (shapes = read_landmarks(LM_DIR, 1000))
    m = AAModel()
    @time train(m, imgs, shapes)
    img = imgs[1]
    init_shape = shapes[1] + 5
    @time fitted_shape, fitted_app = fit2d(m, img, init_shape, 10)
end
