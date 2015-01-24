
using VoronoiDelaunay


## function triangle_as_matrix(delaunaytri)
##     a = geta(delaunaytri); xa, ya = getx(a), gety(a)
##     b = getb(delaunaytri); xb, yb = getx(b), gety(b)
##     c = getc(delaunaytri); xc, yc = getx(c), gety(c)
##     return Float64[ya xa;
##             yb xb;
##             yc xc]
## end


## function triangulate(shape::Shape)
##     npoints = size(shape, 1)
##     shape_min = minimum(shape)
##     scale = (maximum(shape) - minimum(shape)) / (max_coord - min_coord)
##     shape_scaled = (shape .- shape_min) / scale + min_coord
##     tess = DelaunayTessellation(npoints)
##     a = Point2D[Point(shape_scaled[i, 1], shape_scaled[i, 2]) for i in 1:npoints] 
##     push!(tess, a)
##     trimats = Matrix{Float64}[triangle_as_matrix(tri) for tri in collect(tess)[1:end]]
##     trimats = Matrix{Float64}[(trimat .- min_coord) .* scale .+ shape_min
##                               for trimat in trimats]
##     return trimats
## end





function delaunayindexes(shape::Shape)
    npoints = size(shape, 1)
    shape_min = minimum(shape)
    scale = (maximum(shape) - minimum(shape)) / (max_coord - min_coord)
    shape_scaled = (shape .- shape_min) / scale + min_coord
    tess = DelaunayTessellation(npoints)
    a = Point2D[Point(shape_scaled[i, 1], shape_scaled[i, 2]) for i in 1:npoints] 
    push!(tess, a)
    trigs = (Int64, Int64, Int64)[(tr._neighbour_a, tr._neighbour_b, tr._neighbour_c)
                                  for tr in collect(tess)]
    return trigs
end
