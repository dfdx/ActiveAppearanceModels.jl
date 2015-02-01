


function warp(img::Matrix{Float64}, src::Shape, trg::Shape, trigs::Matrix{Int})    
    A = zeros(1, 6)   # affine transformation parameters    
    warped = zeros(eltype(img), size(img))
    for t=1:size(trigs, 1)
        # compute warp parameters (A) for translation from *target to source* 
        # then get pixel values from source and copy them back to target
        U = trg[squeeze(trigs[t, :], 1), 1] - 1
        V = trg[squeeze(trigs[t, :], 1), 2] - 1       
        
        X = src[squeeze(trigs[t, :], 1), 1] - 1
        Y = src[squeeze(trigs[t, :], 1), 2] - 1
        
        denom = (U[2] - U[1]) * (V[3] - V[1]) - (V[2] - V[1]) * (U[3] - U[1])

        A[1] = X[1] + ((V[1] * (U[3] - U[1]) - U[1]*(V[3] - V[1])) * (X[2] - X[1])
                       + (U[1] * (V[2] - V[1]) - V[1]*(U[2] - U[1])) * (X[3] - X[1])) / denom
        A[2] = ((V[3] - V[1]) * (X[2] - X[1]) - (V[2] - V[1]) * (X[3] - X[1])) / denom
        A[3] = ((U[2] - U[1]) * (X[3] - X[1]) - (U[3] - U[1]) * (X[2] - X[1])) / denom
        
        A[4] = Y[1] + ((V[1] * (U[3] - U[1]) - U[1] * (V[3] - V[1])) * (Y[2] - Y[1])
                       + (U[1] * (V[2] - V[1]) - V[1]*(U[2] - U[1])) * (Y[3] - Y[1])) / denom
        A[5] = ((V[3] - V[1]) * (Y[2] - Y[1]) - (V[2] - V[1]) * (Y[3] - Y[1])) / denom
        A[6] = ((U[2] - U[1]) * (Y[3] - Y[1]) - (U[3] - U[1]) * (Y[2] - Y[1])) / denom

        mask = poly2mask(V, U, size(img)...)
        v, u = findn(mask)     # or u, v = ...?

        # ind_base = v + (u - 1) * resolution

        v = v - 1
        u = u - 1
        wx = A[1] + A[2] .* u + A[3] .* v + 1
        wy = A[4] + A[5] .* u + A[6] .* v + 1
        
        # ind_warped = int(wy) + (int(wx) - 1) * image_size

        # warped[ind_base] = img[ind_warped]

        for i=1:length(v)
            if wy[i] <= size(img, 1) && wx[i] <= size(img, 2)
                warped[v[i], u[i]] = img[int(wy[i]), int(wx[i])]
            end
        end       
    end
    viewtri(img, src, trigs)
    view(warped)
    return warped
end


function viewfilled(v, u, sz)
    v = int(v)
    u = int(u)
    m = zeros(sz)
    for i=1:length(v)
        m[v[i], u[i]] = 1       
    end
    view(m)
end


function test_warp()
    # imgs = read_images(IMG_DIR, 200)
    # shapes = read_landmarks(LM_DIR, 200)
    src_k = 200
    trg_k = 190
    trigs = delaunayindexes(shapes[src_k])
    wimg = warp(imgs[src_k], shapes[src_k], shapes[trg_k], trigs)
    view(wimg)
end
