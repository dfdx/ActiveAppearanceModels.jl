
using ActiveAppearanceModels
using PiecewiseAffineTransforms
using FaceDatasets

imgs = load_images(:cootes)
# remove additional dimension (see https://github.com/dfdx/ActiveAppearanceModels.jl/issues/1)
imgs = Array{Float64, 3}[img[:, :, 1:3] for img in imgs]
shapes = load_shapes(:cootes)
@time m = train(AAModel(), imgs, shapes)
for i=1:10
    try
        img_idx = rand(1:length(imgs))
        shape_idx = rand(1:length(imgs))        
        triplot(imgs[img_idx], shapes[shape_idx], m.wparams.trigs)
        @time fitted_shape, fitted_app = fit(m, imgs[img_idx], shapes[shape_idx], 30);
        triplot(imgs[img_idx], fitted_shape, m.wparams.trigs)
        println("Image #$img_idx; shape #$shape_idx")
        readline(STDIN)
    catch e
        if isa(e, BoundsError)
            println("Fitting diverged")
            readline(STDIN)
        else
            rethrow()
        end
    end
end
