
# this file contains function for working with shapes and shape model
# for definition of corresponding types see `model.jl`

using MultivariateStats


function create_shape_model(shapes::Vector{Shape})    
    s0, shapes_aligned = align_shapes(shapes)    
    # do we need to move shape center to origin?
    mini = minimum(s0[:, 1])
    minj = minimum(s0[:, 2])
    maxi = maximum(s0[:, 1])
    maxj = maximum(s0[:, 2])
    modelw = ceil(maxj - minj + 3)
    modelh = ceil(maxi - mini + 3)    
    shape_mat = datamatrix(Shape[s .- s0 for s in shapes_aligned])
    shape_pca = fit(PCA, shape_mat)   # may need shape_pca in future
    S = projection(shape_pca)
    
    return ShapeModel(s0, S)
end
