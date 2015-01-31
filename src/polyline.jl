
function inpolygon{T<:Number}(x:: T, y:: T, vx:: Vector{T}, vy:: Vector{T})
    @assert length(vx) == length(vy)
    c = false
    j = length(vx)
    @inbounds for i=1:length(vx)
        if (((vy[i] <= y && y < vy[j]) || 
            (vy[j] <= y && y < vy[i])) && 
            (x < (vx[j] - vx[i]) * (y - vy[i]) / (vy[j] - vy[i]) + vx[i]))
            c = !c 
        end
        j = i
    end
    return c
end


function poly2mask2{T<:Number}(vx::Vector{T}, vy::Vector{T}, m::Int, n::Int)
    mask = zeros(Int, m, n)
    @inbounds for j=1:m, i=1:n
        mask[i, j] = int(inpolygon(j, i, vx, vy))
    end
    return mask
end

# line intersection != segment intersection
## function line_intersection(a1, b1, a2, b2)
##     x1, y1 = a1
##     x2, y2 = b1
##     x3, y3 = a2
##     x4, y4 = b2
##     denom = (x1 - x2)*(y3 - y4) - (y1 - y2)*(x3 - x4)
##     x = ((x1*y2 - y1*x2)*(x3 - x4) - (x1 - x2)*(x3*y4 - y3*x4)) / denom
##     y = ((x1*y2 - y1*x2)*(y3 - y4) - (y1 - y2)*(x3*y4 - y3*x4)) / denom
##     return (x, y)
## end
    
function fillpoly!{T}(M::Matrix{T}, px::Vector{Int}, py::Vector{Int}, value::T)
    @assert length(px) == length(py)
    left, right = minimum(px), maximum(px)
    top, bottom = minimum(py), maximum(py)
    @inbounds for x=left:right
        ys = Set{Int64}()
        j = length(px)
        for i=1:length(px)            
            if (px[i] <= x && x <= px[j]) || (px[j] <= x && x <= px[i])
                # special case: adding the whole cut to ys                            
                if px[i] == px[j]
                    push!(ys, py[i])
                    push!(ys, py[j])
                else
                    y = py[i] + (x - px[i]) / (px[j] - px[i]) * (py[j] - py[i])
                    push!(ys, int(y))
                end            
            end
            j = i
        end
        ys = sort([y for y in ys])
        # if there's an odd number of intersection points, add one imeginary point
        if length(ys) % 2 == 1
            push!(ys, ys[end])
        end
        for i=1:2:length(ys)
            M[ys[i]:ys[i+1], x] = value
        end
    end
    return M
end

function poly2mask(px::Vector{Int}, py::Vector{Int}, m::Int, n::Int)
    mask = zeros(Bool, m, n)
    fillpoly!(mask, px, py, true)
end


## function poly2mask{T<:Number}(px::Vector{T}, py::Vector{T}, m::Int, n::Int)
##     for i=1:n
        
##     end
## end

M = zeros(Int, 10, 10)
# px = [3, 7, 3]
# py = [1, 1, 5]
px = [1, 4, 4, 2]
py = [1, 3, 5, 6]

fillpoly!(M, px, py, 1)
