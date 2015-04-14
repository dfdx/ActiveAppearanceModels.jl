
## function warp_maps(m::AAModel)
##     modelh, modelw = m.frame.h, m.frame.w
##     warp_map = zeros(Int, modelh, modelw)
##     alpha_coords = zeros(modelh, modelw)
##     beta_coords = zeros(modelh, modelw)
##     for j=1:modelw
##         for i=1:modelh
##             for k=1:size(m.trigs, 1)
##                 t = m.trigs[k, :]
##                 i1 = m.s0[t[1]]
##                 j1 = m.s0[m.np + t[1]]
##                 i2 = m.s0[t[2]]
##                 j2 = m.s0[m.np + t[2]]
##                 i3 = m.s0[t[3]]
##                 j3 = m.s0[m.np + t[3]]

##                 den = (i2 - i1) * (j3 - j1) - (j2 - j1) * (i3 - i1)
##                 alpha = ((i - i1) * (j3 - j1) - (j - j1) * (i3 - i1)) / den
##                 beta = ((j - j1) * (i2 - i1) - (i - i1) * (j2 - j1)) / den

##                 if alpha >= 0 && beta >= 0 && (alpha + beta) <= 1
##                     # found the triangle, save data to the bitmaps and break
##                     warp_map[i, j] = k
##                     alpha_coords[i, j] = alpha
##                     beta_coords[i,j] = beta
##                     break;
##                 end
##             end
##         end
##     end
##     return warp_map, alpha_coords, beta_coords
## end


function warp_maps(shape::Shape, trigs::Matrix{Int}, modelh::Int, modelw::Int)
    warp_map = zeros(Int, modelh, modelw)
    alpha_coords = zeros(modelh, modelw)
    beta_coords = zeros(modelh, modelw)
    for j=1:modelw
        for i=1:modelh
            for k=1:size(m.trigs, 1)
                t = trigs[k, :]
                i1 = shape[t[1], 1]
                j1 = shape[t[1], 2]
                i2 = shape[t[2], 1]
                j2 = shape[t[2], 2]
                i3 = shape[t[3], 1]
                j3 = shape[t[3], 2]

                den = (i2 - i1) * (j3 - j1) - (j2 - j1) * (i3 - i1)
                alpha = ((i - i1) * (j3 - j1) - (j - j1) * (i3 - i1)) / den
                beta = ((j - j1) * (i2 - i1) - (i - i1) * (j2 - j1)) / den

                if alpha >= 0 && beta >= 0 && (alpha + beta) <= 1
                    # found the triangle, save data to the bitmaps and break
                    warp_map[i, j] = k
                    alpha_coords[i, j] = alpha
                    beta_coords[i,j] = beta
                    break;
                end
            end
        end
    end
    return warp_map, alpha_coords, beta_coords
end

function warp_maps(m::AAModel)
    return warp_maps(reshape(m.s0, m.np, 2), m.trigs, m.frame.h, m.frame.w);
end
