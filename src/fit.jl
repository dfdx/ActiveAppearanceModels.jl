
function fit2d(m::AAModel, img::Matrix{Float64}, init_shape::Shape, max_it::Int)
    @assert size(m.s0, 1) == size(init_shape, 1) * 2 "Shape has wrong size!"
    cur_shape = init_shape
    mean_shape = reshape(m.s0, m.np, 2)
    iter = 1
    while iter <= max_it
        wrp = warp(img, cur_shape, mean_shape, m.trigs)
        error_img = flatten(wrp[1:m.frame.h, 1:m.frame.w]) .- m.A0
        if iter > 5 || max_it < 10
            delta_qp = m.R * error_img
            d_s0 = reshape(m.s0 - sum(m.S * delta_qp[5:end], 2), m.np, 2)
            A, trans = global_params_to_affine(m, -delta_qp[1:4])
        end
    end
end






function test_fit2d()    
    isdefined(:imgs) || (imgs = read_images(IMG_DIR, 200))
    isdefined(:shapes) || (shapes = read_landmarks(LM_DIR, 200))
    m = AAModel()
    train(m, imgs, shapes)
    img = imgs[1]
    init_shape = shapes[1]
    # fit2d
end
