
typealias Shape Matrix{Float64}


type AAModel
    np::Int
    s0::Vector{Float64}
    s_star::Matrix{Float64}
    S::Matrix{Float64}        
end


AAModel() = AAModel(-1, zeros(1), zeros(1, 1), zeros(1, 1))

Base.show(io::IO, m::AAModel) = print(io, "AAModel($(m.np))")



