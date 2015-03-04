
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

using Cootes

function test_fit2d()    
    # isdefined(:imgs) || (imgs = load_images(1000))
    # isdefined(:shapes) || (shapes = load_shapes(1000))
    imgs = Cootes.load_images()
    shapes = Cootes.load_shapes()
    m = AAModel()
    @time train(m, imgs, shapes)
    img = imgs[1]
    init_shape = shapes[1] + 5
    @time fitted_shape, fitted_app = fit2d(m, img, init_shape, 10)
end
