

function procrustes(X::Shape, Y::Shape)
    @assert size(X) == size(Y)
    n, m = size(X)
    mu_x = mean(X, 1)
    mu_y = mean(Y, 1)

    X0 = X .- mu_x
    Y0 = Y .- mu_y

    ss_x = sum(X0.^2)
    ss_y = sum(Y0.^2)

    norm_x = sqrt(ss_x)
    norm_y = sqrt(ss_y)

    X0 ./= norm_x
    Y0 ./= norm_y
    
    A = X0'Y0
    U, s, Vt = svd(A)
    V = Vt'
    T = V*U'

    traceTA = sum(s)
    
    b = traceTA * norm_x / norm_y    
    d = 1 - traceTA ^ 2
    Z = norm_x * traceTA * (Y0 * T) .+ mu_x

    c = mu_x - b * (mu_y * T)
    
    tform = ["rotation" => T, "scale" => b, "translation" => c]
    return d, Z, tform
    
end



function align_shapes(shapes::Vector{Shape}; n_iter=50)
    shapes = copy(shapes)       # copy shape array to avoid modification or original array    
    for it=1:n_iter
        mean_shape = mean(shapes)
        for i=1:length(shapes)
            _, shapes[i], _ = procrustes(mean_shape, shapes[i])
        end
    end
    return shapes
end
