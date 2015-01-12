

# where = '.';
# folder = 'trainset';
# what = 'png';




type Shape

end

type Texture
    
end

type AAModel
    npoints::Int  # number of points in a model
    scales::Vector{Int8} #  = [1, 2]
    shapes::Vector{Shape} # one per scale  #  = Array(Shape, nscales)
    textures::Vector{Texture} # one per scale  # = Array(Texture, nscales)    
end



function AAModel(npoints, scales)
    nscales = length(scales)
    AAModel(npoints, scales, Array(Shape, nscales), Array(Texture, nscales))    
end


Base.show(io::IO, m::AAModel) = print(io, "AAModel($(m.npoints),$(int64(m.scales)))")



function train(m::AAModel)

end

