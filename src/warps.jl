

# shortcut for warping shape to the mean shape
warp_to_mean_shape{N}(m::AAModel, img::Array{Float64, N}, src_shape::Shape) = 
    pa_warp(m.wparams, img, src_shape)
            

function q_params_to_affine(m::AAModel, q::Vector{Float64})
    t = m.wparams.trigs[1, :]
    base = zeros(2, 3)
    warped = zeros(2, 3)
    for i=1:3
        base[1, i] = m.s0[t[i]]
        base[2, i] = m.s0[m.np+t[i]]
        warped[1, i] = (base[1, i] + m.s_star[t[i], :] * q)[1]
        warped[2, i] = (base[2, i] + m.s_star[m.np+t[i], :] * q)[1]
    end

    den = ((base[1,2] - base[1,1]) * (base[2,3] - base[2,1]) -
           (base[2,2] - base[2,1]) * (base[1,3] - base[1,1]))
    
    # these are not barycentric coordinates, but are used similarly
    alpha = (-base[1,1] * (base[2,3] - base[2,1]) + base[2,1] * (base[1,3] - base[1,1])) / den
    beta  = (-base[2,1] * (base[1,2] - base[1,1]) + base[1,1] * (base[2,2] - base[2,1])) / den
    
    # we start with the translation component
    a1 = warped[1,1] + (warped[1,2] - warped[1,1]) * alpha + (warped[1,3] - warped[1,1]) * beta
    a4 = warped[2,1] + (warped[2,2] - warped[2,1]) * alpha + (warped[2,3] - warped[2,1]) * beta
    
    alpha = (base[2,3] - base[2,1]) / den
    beta  = (base[2,1] - base[2,2]) / den
    
    # relationships between original x coordinate and warped x and y coordinates
    a2 = (warped[1,2] - warped[1,1]) * alpha + (warped[1,3] - warped[1,1]) * beta
    a5 = (warped[2,2] - warped[2,1]) * alpha + (warped[2,3] - warped[2,1]) * beta
    
    alpha = (base[1,2] - base[1,1]) / den
    beta  = (base[1,1] - base[1,3]) / den
    
    # relationships between original y coordinate and warped x and y coordinates
    a3 = (warped[1,3] - warped[1,1]) * alpha + (warped[1,2] - warped[1,1]) * beta
    a6 = (warped[2,3] - warped[2,1]) * alpha + (warped[2,2] - warped[2,1]) * beta
    
    # store in matrix form
    # to be used in this way: 
    #  shape * A + tr ==> N(shape, q)
    tr = [a1 a4]
    A = [a2 a5; a3 a6]
    return A, tr
end


function compose_warps(m::AAModel, shape::Shape, incr::Shape)
    nt = zeros(m.np)
    comp_warp = zeros(m.np, 2)
    ntrigs = size(m.wparams.trigs, 1)
    for i=1:ntrigs
        t = m.wparams.trigs[i, :]
        nt[t[1]] += 1
        nt[t[2]] += 1
        nt[t[3]] += 1
        for k=1:3
            t2 = copy(t)
            t2[1] = t[k]
            t2[k] = t[1]
            # vertices of the triangle in the mean shape
            i1 = m.s0[t2[1]]
            j1 = m.s0[m.np + t2[1]]
            i2 = m.s0[t2[2]]
            j2 = m.s0[m.np + t2[2]]
            i3 = m.s0[t2[3]]
            j3 = m.s0[m.np + t2[3]]

            i_coord = incr[t2[1], 1]
            j_coord = incr[t2[1], 2]

            den = (i2 - i1) * (j3 - j1) - (j2 - j1) * (i3 - i1)
            alpha = ((i_coord - i1) * (j3 - j1) -
                     (j_coord - j1) * (i3 - i1)) / den
            beta = ((j_coord - j1) * (i2 - i1) -
                    (i_coord - i1) * (j2 - j1)) / den
            comp_warp[t2[1], :] =
                (comp_warp[t2[1],:] + 
                 alpha * (shape[t2[2],:] - shape[t2[1],:]) + 
                 beta * (shape[t2[3],:] - shape[t2[1],:]))
            
        end                
    end
    comp_warp = shape .+ comp_warp ./ repmat(nt, 1, 2)
    return comp_warp
end

