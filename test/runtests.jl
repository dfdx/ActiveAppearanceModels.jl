
using ActiveAppearanceModels
using FaceDatasets
# using PiecewiseAffineTransforms

function smoke_cootes()
    imgs = load_images(:cootes)
    shapes = load_shapes(:cootes)    
    test_img_idx = 8
    one_out = [1:test_img_idx-1; test_img_idx+1:length(imgs)]
    m = AAModel()
    @time train(m, imgs[one_out], shapes[one_out])
    img = imgs[test_img_idx]
    init_shape = shapes[18]   
    @time fitted_shape, fitted_app = fit(m, img, init_shape, 50);
    # triplot(img, fitted_shape, m.wparams.trigs)
end

smoke_cootes()
