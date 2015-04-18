
VERSION < v"0.4-" && using Docile
using StatsBase

include("utils.jl")
include("model.jl")
include("triang.jl")
include("polyline.jl")
include("procrustes.jl")
include("data.jl")
include("warp_maps.jl")
include("pwa.jl")
include("pa_warp.jl")
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
    test_img_idx = 2 # rand(1:length(imgs))
    one_out = [1:test_img_idx-1; test_img_idx+1:length(imgs)]
    m = AAModel()
    @time train(m, imgs[one_out], shapes[one_out])
    img = imgs[test_img_idx]
    for i=1:1
        # init_shape = shapes[rand(one_out)] .- 5
        init_shape = shapes[18]
        # triplot(img, init_shape, m.trigs)    
        @time fitted_shape, fitted_app = fit2d(m, img, init_shape, 20);
        triplot(img, fitted_shape, m.trigs)        
        # readline(STDIN)
    end
end

function test_pa_warp()
    imgs = Cootes.load_images()
    shapes = Cootes.load_shapes()        
    m = AAModel()
    @time train(m, imgs, shapes);
    base_shape = reshape(m.s0, m.np, 2)
    r = pa_warp(imgs[18], (m.frame.h, m.frame.w), shapes[18], base_shape,
                m.trigs, m.warp_map, m.alpha_coords, m.beta_coords);
    view(r)
end

