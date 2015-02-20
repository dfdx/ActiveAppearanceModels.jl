
function fit(m::AAModel, img::Matrix{Float64}, init_shape::Matrix{Float64}, max_it::Int)
    @assert size(m.s0) == size(init_shape, 1) * 2 "Shape has wrong size!"
    cur_shape = init_shape
    mean_shape = reshape(m.s0, m.np, 2)
    iter = 1
    while iter <= max_it
        error_img = flatten(warp(img, cur_shape, mean_shape, m.trigs)) .- m.A0
        
    end
end
