
# this file contains function for working with shapes and shape model
# for definition of corresponding types see `model.jl`

using MultivariateStats


function create_shape_model(shapes::Vector{Shape})
    shapes_aligned = align_shapes(shapes)
    s0 = mean(shapes_aligned)
    shape_mat = datamatrix(Shape[s .- s0 for s in shapes_aligned])
    shape_pca = fit(PCA, shape_mat)   # may need shape_pca in future
    S = projection(shape_pca)
    return ShapeModel(s0, S)
end
