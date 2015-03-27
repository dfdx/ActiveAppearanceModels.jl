
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

## function test_fit2d()    
##     # isdefined(:imgs) || (imgs = load_images(1000))
##     # isdefined(:shapes) || (shapes = load_shapes(1000))
##     imgs = Cootes.load_images()
##     shapes = Cootes.load_shapes()
##     m = AAModel()
##     @time train(m, imgs, shapes)
##     img = imgs[1]
##     init_shape = shapes[1] - 20
##     viewshape(img, init_shape)
##     @time fitted_shape, fitted_app = fit2d(m, img, init_shape, 10)
##     viewshape(img, fitted_shape)
## end


function test_fit2d()    
    imgs = Cootes.load_images()
    shapes = Cootes.load_shapes()    
    test_img_idx = 2
    one_out = [1:test_img_idx-1; test_img_idx+1:length(imgs)]
    m = AAModel()
    @time train(m, imgs[one_out], shapes[one_out])
    for i=1:5
        init_shape = shapes[rand(one_out)] .- 5
        viewtri(img, init_shape, m.trigs)    
        @time fitted_shape, fitted_app = fit2d(m, img, init_shape, 20)
        viewtri(img, fitted_shape, m.trigs)        
        readline(STDIN)
    end
end

