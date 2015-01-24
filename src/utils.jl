
flatten{T}(x::Vector{T}) = x
flatten(X) = reshape(X, prod(size(X)))

# convert vector of data samples into a single data matrix, flatten samples if needed
datamatrix{T,N}(samples::Vector{Array{T,N}}) =
    hcat([flatten(sample) for sample in samples]...)

# convert single data matrix into a vector of samples
samplevec{T}(datamat::Matrix{T}, sampledims::(Int...)) =
    Matrix{T}[reshape(datamat[:, i], sampledims) for i=1:size(datamat, 2)]
