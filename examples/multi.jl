
using ActiveAppearanceModels
using PiecewiseAffineTransforms
using FaceDatasets

imgs = load_images(:cootes)
shapes = load_shapes(:cootes)

println("Number of images: $(length(imgs))")
println("Dimensions of images: $(size(imgs[1]))")

@time m = train(AAModel(), imgs, shapes)
for i=1:10
    try
        img_idx = rand(1:length(imgs))
        shape_idx = rand(1:length(imgs))        
        # triplot(img, init_shape, m.trigs)
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
