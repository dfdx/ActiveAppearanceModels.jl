
# TODO: merge with pwa.jl

function pa_warp{N}(src_img::Array{Float64, N}, dst_size::(Int, Int),
                    src_shape::Shape, dst_shape::Shape,
                    trigs::Matrix{Int}, warp_map::Matrix{Int},
                    alpha_coords::Matrix{Float64}, beta_coords::Matrix{Float64};
                    interp=:bilinear)
    nc = N
    h, w = dst_size
    ## # assuming destination shape is NOT base shape, computing warp maps for it
    ## warp_map, alpha_coords, beta_coords =
    ##     warp_maps(dst_shape, trigs, h, w)
    dst_img = zeros(Float64, h, w, nc)
    for j=1:w
        for i=1:h            
            t = warp_map[i, j]
            # if t <= 0, pixel is out of destination shape
            if t > 0                
                # index of first vertex of the triangle
                v1 = trigs[t, 1]
                i1 = src_shape[v1, 1]
                j1 = src_shape[v1, 2]

                v2 = trigs[t, 2]
                i2 = src_shape[v2, 1]
                j2 = src_shape[v2, 2]
                
                v3 = trigs[t, 3]
                i3 = src_shape[v3, 1]
                j3 = src_shape[v3, 2]

                wi = (i1 +
                      alpha_coords[i, j] * (i2 - i1) +
                      beta_coords[i, j] * (i3 - i1))
                wj = (j1 +
                      alpha_coords[i, j] * (j2 - j1) +
                      beta_coords[i, j] * (j3 - j1))

                if wi < 1 || wi > size(src_img, 1) ||
                    wj < 1 || wj > size(src_img, 2)
                    # throw(BoundsError("Warp pixel is out of bounds"))
                    println("wi=$wi, wj=$wj")
                end

                lli = convert(Int, floor(wi))
                llj = convert(Int, floor(wj))
                uri = lli + 1
                urj = llj + 1

                f0 = (uri - wi) * (urj - wj)
                f1 = (wi - lli) * (urj - wj)
                f2 = (uri - wi) * (wj - llj)
                f3 = (wi - lli) * (wj - llj)
                
                for c=1:nc
                    if interp == :bilinear
                        interpolated = (src_img[lli, llj, c] * f0 +
                                        src_img[uri, llj, c] * f1 +
                                        src_img[lli, urj, c] * f2 +
                                        src_img[uri, urj, c] * f3)
                        dst_img[i, j, c] = interpolated
                    elseif interp == :nearest
                        dst_img[i, j, c] =
                            src_img[convert(Int, wi), convert(Int, wj), c]
                    else
                        throw("Unknown interpolation type: $interp")
                    end
                end 
            end            
        end
    end
    return dst_img
end


# shortcut for warping shape to the mean shape
pa_warp{N}(m::AAModel, img::Array{Float64, N}, src_shape::Shape) = 
    pa_warp(img, (m.frame.h, m.frame.w), src_shape, reshape(m.s0, m.np, 2),
            m.trigs, m.warp_map, m.alpha_coords, m.beta_coords)

