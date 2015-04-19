

using MultivariateStats
using MAT


# add gloabl shape transformation parameters and orthonormalize all vectors
function global_shape_transform(s0, pc)
    npc = size(pc, 2)
    np = int(length(s0) / 2)
    # columns 1:4 - global transform params
    # columns 5:end - shape principal components
    s_star_pc = zeros(2*np, npc+4)
    s_star_pc[:, 1] = s0
    s_star_pc[1:np, 2] = -s0[np+1:end]
    s_star_pc[np+1:end, 2] = s0[1:np]
    s_star_pc[1:np, 3] = ones(np)
    s_star_pc[np+1:end, 3] = zeros(np)
    s_star_pc[1:np, 4] = zeros(np)
    s_star_pc[np+1:2*np, 4] = ones(np)
    s_star_pc[:, 5:end] = pc
    # orthonormalizing all
    s_star_pc = gs_orthonorm(s_star_pc)
    # splitting back into global transformation params and star
    s_star, S = s_star_pc[:, 1:4], s_star_pc[:, 5:end]
    return s_star, S
end


function build_shape_model(m::AAModel, shapes::Vector{Shape})
    mean_shape, shapes_aligned = align_shapes(shapes) 
    mini, minj = minimum(mean_shape[:, 1]), minimum(mean_shape[:, 2])
    maxi, maxj = maximum(mean_shape[:, 1]), maximum(mean_shape[:, 2])
    # move mean shape to upper-left corner
    mean_shape[:, 1] = mean_shape[:, 1] .- (mini - 2)
    mean_shape[:, 2] = mean_shape[:, 2] .- (minj - 2)    
    frame = ModelFrame(int(mini), int(minj), int(maxi), int(maxj))
    shape_mat = datamatrix(Shape[shape .- mean_shape for shape in shapes_aligned])
    shape_pca = fit(PCA, shape_mat)
    pc = projection(shape_pca)
    # base shape, global transform shape and transformation matrix
    s0 = flatten(mean_shape)
    s_star, S = global_shape_transform(s0, pc)
    return frame, s0, s_star, S
end


function import_shape_model(model_dir)
    s0 = squeeze(matread(joinpath(model_dir, "s0.mat"))["s0"], 2)
    s_star = matread(joinpath(model_dir, "s_star.mat"))["s_star"]
    S = matread(joinpath(model_dir, "S.mat"))["S"]
    mean_shape = reshape(s0, int(length(s0) / 2), 2)
    mini, minj = minimum(mean_shape[:, 1]), minimum(mean_shape[:, 2])
    maxi, maxj = maximum(mean_shape[:, 1]), maximum(mean_shape[:, 2])
    mean_shape[:, 1] = mean_shape[:, 1] .- (mini - 2)
    mean_shape[:, 2] = mean_shape[:, 2] .- (minj - 2)    
    frame = ModelFrame(int(mini), int(minj), int(maxi), int(maxj))
    return frame, s0, s_star, S
end

function import_triangulation(model_dir)
    return matread(joinpath(model_dir, "trigs.mat"))["trigs"]
end
                            

function build_app_model{N}(m::AAModel, imgs::Vector{Array{Float64, N}},
                         shapes::Vector{Shape})
    app_mat = zeros(m.frame.h * m.frame.w * m.nc, length(imgs))
    for i=1:length(imgs)
        warped = warp_to_mean_shape(m, imgs[i], shapes[i])
        app_mat[:, i] = flatten(warped)
    end
    A0 = squeeze(mean(app_mat, 2), 2)    
    A = projection(fit(PCA, app_mat .- A0))
    mean_app = reshape(A0, m.frame.h, m.frame.w, m.nc)
    dA0 = Array(Grad2D, 3)
    for i=1:m.nc
        dA0[i] = gradient2d(mean_app[:, :, 1], m.wparams.warp_map)
    end
    return A0, A, dA0
end


function jacobians(m::AAModel)
    # jacobians have form (i, j, axis, param_index)
    dW_dp = zeros(m.frame.h, m.frame.w, 2, size(m.S, 2))
    dN_dq = zeros(m.frame.h, m.frame.w, 2, 4)
    for j=1:m.frame.w
        for i=1:m.frame.h
            if m.wparams.warp_map[i, j] != 0
                t = m.wparams.trigs[m.wparams.warp_map[i, j], :]
                # for each vertex
                for k=1:3
                    dik_dp = m.S[t[k], :]
                    djk_dp = m.S[t[k]+m.np, :]

                    dik_dq = m.s_star[t[k], :]
                    djk_dq = m.s_star[t[k]+m.np, :]

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

                    # compute the two barycentric coordinates
                    den = (i2 - i1) * (j3 - j1) - (j2 - j1) * (i3 - i1)
                    alpha = ((i - i1) * (j3 - j1) - (j - j1) * (i3 - i1)) / den
                    beta = ((j - j1) * (i2 - i1) - (i - i1) * (j2 - j1)) / den

                    dW_dij = 1 - alpha - beta

                    dW_dp[i,j,:,:] = (squeeze(dW_dp[i,j,:,:], (1, 2)) +
                                      dW_dij * [dik_dp; djk_dp])
                    dN_dq[i,j,:,:] = (squeeze(dN_dq[i,j,:,:], (1, 2)) +
                                      dW_dij * [dik_dq; djk_dq])
                end
            end
        end
    end
    return dW_dp, dN_dq
end


function sd_images(m::AAModel)
    app_modes = reshape(m.A, m.frame.h, m.frame.w, m.nc, size(m.A, 2))
    SD = zeros(m.frame.h, m.frame.w, m.nc, 4 + size(m.dW_dp, 4))
    # SD images for 4 global transformation parameters
    for i=1:4
        prj_diff = zeros(m.nc, size(m.A, 2))
        for j=1:size(m.A, 2)
            for c=1:m.nc                
                prj_diff[c, j] = sum(app_modes[:,:,c,j] .*
                                     (m.dA0[c].di .* m.dN_dq[:,:,1,i] +
                                      m.dA0[c].dj .* m.dN_dq[:,:,2,i]))
            end
        end
        for c=1:m.nc
            SD[:,:,c,i] = (m.dA0[c].di .* m.dN_dq[:,:,1,i] +
                           m.dA0[c].dj .* m.dN_dq[:,:,2,i])
        end
        for j=1:size(m.A, 2)
            for c=1:m.nc
                SD[:,:,c,i] = SD[:,:,c,i] - prj_diff[c,j] * app_modes[:,:,c,j]
            end
        end       
    end
    # SD images for shape parameters
    for i=1:size(m.dW_dp, 4)
        prj_diff = zeros(m.nc, size(m.A, 2))
        for j=1:size(m.A, 2)
            for c=1:m.nc       
                prj_diff[c,j] = sum(app_modes[:,:,c,j] .*
                                    (m.dA0[c].di .* m.dW_dp[:,:,1,i] +
                                     m.dA0[c].dj .* m.dW_dp[:,:,2,i]))
            end
        end
        for c=1:m.nc
            SD[:,:,c,i+4] = (m.dA0[c].di .* m.dW_dp[:,:,1,i] +
                             m.dA0[c].dj .* m.dW_dp[:,:,2,i])
        end
        for j=1:size(m.A, 2)
            for c=1:m.nc
                SD[:,:,c,i+4] = SD[:,:,c,i+4] - prj_diff[c,j] * app_modes[:,:,c,j]
            end
        end
    end
    SDf = zeros(size(SD, 4), size(m.A, 1))
    for i=1:size(SD, 4)
        SDf[i,:] = flatten(SD[:,:,:,i])
    end
    return SDf
end


function train{N}(m::AAModel,
                  imgs::Vector{Array{Float64, N}},
                  shapes::Vector{Shape})
    @assert(length(imgs) >=  1, "At least one image is required")
    @assert(length(imgs) == length(shapes),
            "Different number of images and landmark sets")
    @assert(0 <= minimum(imgs[1]) && maximum(imgs[1]) <= 1,
            "Images should be in Float64 format with values in [0..1]")
    m.nc = N
    m.np = size(shapes[1], 1)        
    m.frame, m.s0, m.s_star, m.S = build_shape_model(m, shapes)
    mean_shape = reshape(m.s0, m.np, 2)
    m.wparams = warp_params(mean_shape, delaunayindexes(mean_shape),
                            size(m.frame))    
    m.A0, m.A, m.dA0 = build_app_model(m, imgs, shapes)
    m.dW_dp, m.dN_dq = jacobians(m)
    m.SD = sd_images(m)
    m.H = m.SD * m.SD'
    m.invH = inv(m.H)
    m.R = m.invH * m.SD
    return m
end
