
using StatsBase
using Compat
using Images
using ImageView
using Color
using FixedPointNumbers
using VoronoiDelaunay
using MultivariateStats
using MAT
using PiecewiseAffineTransforms

include("utils.jl")
include("model.jl")
include("procrustes.jl")
include("warps.jl")
include("gradient2d.jl")
include("train.jl")
include("fit.jl")

