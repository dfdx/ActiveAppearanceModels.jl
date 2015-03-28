
flatten{T}(x::Vector{T}) = x
flatten(X) = reshape(X, prod(size(X)))

# convert vector of data samples into a single data matrix, flatten samples if needed
datamatrix{T,N}(samples::Vector{Array{T,N}}) =
    hcat([flatten(sample) for sample in samples]...)

# convert single data matrix into a vector of samples
samplevec{T}(datamat::Matrix{T}, sampledims::(Int...)) =
    Matrix{T}[reshape(datamat[:, i], sampledims) for i=1:size(datamat, 2)]



function gs_orthonorm(M)
    O = zeros(eltype(M), size(M))
    ncol = size(M, 2)
    tol = 100*eps(Float64)
    k = 1
    for i=1:ncol
        v = M[:, i]   # column to orthonormalize
        # subtract projections over previous vectors
        for j=1:k-1
            v = v - dot(O[:,j], v) * O[:,j]
        end
        # only keep nonzero vectors
        n = norm(v)
        if n > tol
            O[:, k] = v / n
            k = k + 1
        end
    end
    return O[:, 1:k-1]
end    


function StatsBase.describe{T,N}(A::Array{T,N})
    println("size   : $(size(A))")
    println("min    : $(minimum(A))")
    println("mean   : $(mean(A))")
    println("median : $(median(A))")
    println("max    : $(maximum(A))")
    println("sum    : $(sum(A))")    
end
