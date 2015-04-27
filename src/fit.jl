
function fit{N}(m::AAModel, img::Array{Float64, N},
                init_shape::Shape, max_it::Int)    
    @assert size(m.s0, 1) == size(init_shape, 1) * 2 "Shape has wrong size!"
    cur_shape = init_shape
    mean_shape = reshape(m.s0, m.np, 2)
    comp_warp = zeros(size(init_shape))
    iter = 1
    while iter <= max_it
        # println("Current shape: \n$(cur_shape[1:2, 1:end])")
        warped = warp_to_mean_shape(m, img, cur_shape)
        error_img = flatten(warped) .- m.A0
        # if iter == 4
        #     view(reshape(error_img, m.frame.h, m.frame.w, 3))
        #     error("stop")
        # end
        println("SSE: $(sum(error_img .^ 2))")     
        if iter > 5 || max_it < 10
            delta_qp = m.R * error_img
            A, trans = q_params_to_affine(m, -delta_qp[1:4])            
            d_s0_ = reshape(m.s0 - m.S * delta_qp[5:end], m.np, 2)            
            d_s0 = d_s0_ * A + repmat(trans, m.np, 1)
            comp_warp = compose_warps(m, cur_shape, d_s0)
        else
            delta_q = m.R[1:4, :] * error_img
            A, trans = q_params_to_affine(m, -delta_q)
            d_s0_ = reshape(m.s0, m.np, 2)
            d_s0 = (d_s0_ * A + repmat(trans, m.np, 1)) - d_s0_
            comp_warp = cur_shape + d_s0
        end
        iter += 1
        cur_shape = comp_warp
    end
    fitted_shape = cur_shape
    # wrp = pa_warp(img, cur_shape, mean_shape, m.trigs)
    warped = warp_to_mean_shape(m, img, cur_shape)
    error_img = flatten(warped) - m.A0
    fitted_app = reshape(m.A0 + m.A * (m.A' * error_img),
                         m.frame.h, m.frame.w, m.nc)
    return fitted_shape, fitted_app
end


