
typealias Shape Matrix{Float64}

type ShapeModel
    s0::Shape
    
end

type TextureModel
    
end

type AAModel
    npoints::Int  # number of points in a model
    scales::Vector{Int8} #  = [1, 2]
    s0::Shape
    shape_models::Vector{ShapeModel} # one per scale  #  = Array(Shape, nscales)
    texture_models::Vector{TextureModel} # one per scale  # = Array(Texture, nscales)    
end

function AAModel(npoints::Int, scales::Vector{Int})
    nscales = length(scales)
    AAModel(npoints, scales, Array(Float64, npoints, 2),
            Array(ShapeModel, nscales), Array(TextureModel, nscales))    
end

Base.show(io::IO, m::AAModel) = print(io, "AAModel($(m.npoints),$(int64(m.scales)))")



