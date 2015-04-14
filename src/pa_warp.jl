
# TODO: merge with pwa.jl
# TODO: handle the case where dst_shape is a base_shape

function pa_warp{N}(src_img::Array{Float64, N}, 
                    src_shape::Shape, dst_shape::Shape,
                    trigs::Matrix{Int}, h::Int, w::Int)
    # nt = size(m.trigs, 1)
    nc = size(img, 3)
    # assuming destination shape is NOT base shape, computing warp maps for it
    warp_map, alpha_coords, beta_coords =
        warp_maps(dst_shape, trigs, h, w)
    dst_img = zeros(Float64, h, w, nc)
    for j=1:w
        for i=1:h
            t = warp_map[i, j]
            # if t <= 0, pixel is out of destination image
            if t > 0
                # index of first vertex of the triangle
                v1 = trigs[t, 1]
                i1 = src_shape[v1, 1]
                j1 = src_shape[v1, 2]

                v2 = trigs[t, 2]
                i2 = src_shape[v2, 1]
                j2 = dst_shape[v2, 2]
                
                v3 = trigs[t, 3]
                i3 = src_shape[v3, 1]
                j3 = dst_shape[v3, 2]

                wi = (i1 +
                      alpha_coords[i, j] * (i2 - i1) +
                      beta_coords[i, j] * (i3 - i1))
                wj = (j1 +
                      alpha_coords[i, j] * (j2 - j1) +
                      beta_coords[i, j] * (j3 - j1))

                if wi < 1 || wi > h || wj < 1 || wj > w
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

                offset = w * h * nc
                for c=1:nc
                    if true # INTERP
                        # TODO: use multidimentional indexes instead
                        interpolated = (src_img[lli + h * (llj) + offset] * f0 +
                                        src_img[uri + h * (llj) + offset] * f1 +
                                        src_img[lli + h * (urj) + offset] * f2 +
                                        src_img[uri + h * (urj) + offset] * f3)
                        
                        dst_img[i, j, c] = interpolated
                    else
                        dst_img[i, j, c] = src_img[convert(Int, wi) + h * convert(Int, wj) + offset];
                    end
                end                
                return dst_img                
            end
        end
    end
    
    
    
    
end
