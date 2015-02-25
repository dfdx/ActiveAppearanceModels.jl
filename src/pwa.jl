
# u ~ x ~ j
# v ~ y ~ i

function source_point_mat(X, Y)
    x1, x2, x3 = X
    y1, y2, y3 = Y    
    F = [x1 x2 x3; y1 y2 y3; 1 1 1]
    F
end

function target_point_mat(U, V)
    u1, u2, u3 = U
    v1, v2, v3 = V
    T = [u1 u2 u3; v1 v2 v3]
    T
end


function affine_params(X, Y, U, V)
    F = source_point_mat(X, Y)
    T = target_point_mat(U, V)
    M = T * inv(F)
    M
end


warp_pixel(M, x::Float64, y::Float64) = M * [x, y, 1]

function warp(img::Matrix{Float64}, src::Shape, trg::Shape, trigs::Matrix{Int})
    warped = zeros(eltype(img), size(img))    
    for t=1:size(trigs, 1)    
        tr = squeeze(trigs[t, :], 1)
        Y = src[tr, 1]
        X = src[tr, 2]
        
        V = trg[tr, 1]
        U = trg[tr, 2]
               
        # warp parameters from target (U, V) to source (X, Y)
        M = affine_params(U, V, X, Y)
        
        mask = poly2mask(U, V, size(img)...)
        vs, us = findn(mask)
        
        # for every pixel in target triangle we find corresponding pixel in source
        # and copy its value
        for i=1:length(vs)
            u, v = us[i], vs[i]
            x, y = warp_pixel(M, float64(u), float64(v))
            if 1 <= y && y <= size(img, 1) && 1 <= x && x <= size(img, 2)                
                warped[v, u] = img[int(y), int(x)]
            end
        end
        
    end
    warped
end


# global trasnformation params? q-params?
function global_params_to_affine(m::AAModel, q::Vector{Float64})
    t = m.trigs[1, :]
    base = zeros(2, 3)
    warped = zeros(2, 3)
    for i=1:3
        base[1, i] = m.s0[t[i]] # squeeze?
        base[2, i] = m.s0[m.np+t[i]]
        warped[1, i] = base[1, i] + m.s_star[t[i], :] * q'
        warped[2, i] = base[2, i] + m.s_star[m.np+t[i], :] * q'
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
    ntrigs = size(m.trigs, 1)
    for i=1:ntrigs
        t = m.trigs[i, :]
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


#######################################################################


## function test_warp()
##     img = rawdata(imread(expanduser("~/Downloads/face.png")))
##     src = Float64[86 37; 76 217; 158 136]
##     trg = Float64[86 37; 76 217; 240 136]
##     trigs = delaunayindexes(src)
##     view(img)
##     wimg = warp(img, src, trg, trigs)    
##     view(wimg)
## end



## function test_warp_real()
##     src_k = 200
##     trg_k = 1
##     src = shapes[src_k]
##     trg = shapes[trg_k]
##     trigs = delaunayindexes(shapes[src_k])
##     wimg = warp(imgs[src_k], shapes[src_k], shapes[trg_k], trigs)    
##     view(img)
##     view(imgs[trg_k])
##     view(wimg)
## end


## function viewfilled(v, u, sz)
##     v = int(v)
##     u = int(u)
##     m = zeros(sz)
##     for i=1:length(v)
##         if v[i] <= sz[1] && u[i] <= sz[2]
##             m[v[i], u[i]] = 1       # BoundsError!
##         end
##     end
##     view(m)
## end
