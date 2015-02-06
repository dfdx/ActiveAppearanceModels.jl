
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


function viewfilled(v, u, sz)
    v = int(v)
    u = int(u)
    m = zeros(sz)
    for i=1:length(v)
        if v[i] <= sz[1] && u[i] <= sz[2]
            m[v[i], u[i]] = 1       # BoundsError!
        end
    end
    view(m)
end


isdefined(:imgs) || (imgs = read_images(IMG_DIR, 200))
isdefined(:shapes) || (shapes = read_landmarks(LM_DIR, 200))



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




function test_warp()
    img = rawdata(imread(expanduser("~/Downloads/face.png")))
    src = Float64[86 37; 76 217; 158 136]
    trg = Float64[86 37; 76 217; 240 136]
    trigs = delaunayindexes(src)
    view(img)
    wimg = warp(img, src, trg, trigs)    
    view(wimg)
end



function test_warp_real()
    src_k = 200
    trg_k = 1
    src = shapes[src_k]
    trg = shapes[trg_k]
    trigs = delaunayindexes(shapes[src_k])
    wimg = warp(imgs[src_k], shapes[src_k], shapes[trg_k], trigs)    
    view(img)
    view(imgs[trg_k])
    view(wimg)
end
