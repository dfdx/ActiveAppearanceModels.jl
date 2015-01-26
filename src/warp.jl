

function poly2mask(xx, yy, m, n)
    mask = zeros(Uint8, m, n)
    # close polygon
    if xx[1] != xx[end] || yy[1] != y[end]
        xx = [xx, xx[1]]
        yy = [yy, yy[1]]
    end
    x = xx'
    y = yy'
    # make edges between points as a matrix of size (2, npoints)
    # where 1st row is a source and 2nd row is a destination vertex
    ex = [x[1, 1:end-1], x[1, 2:end]]  
    ey = [y[1, 1:end-1], y[1, 2:end]]
    # eliminate horizontal edges
    idx = find(ey[1, :] .!= ey[2, :])
    ex = ex[:, idx]
    ey = ey[:, idx]
    eminy, eminyidx = findmin(ey)
    emaxy, emaxyidx = findmax(ey)
    exminy = ex[eminyidx]
    exmaxy = ex[emaxyidx]
    eminy = eminy'
    emaxy = emaxy'
    m_inv = (exmaxy - exminy) ./ (emaxy - eminy)
    # global edge table
    ge = sortrows([emaxy eminy exmaxy m_inv], [1, 3])
end



function warp(base_texture::Matrix{Float64}, base_shape::Shape,
              texture::Matrix{Float64}, shape::Shape,
              trigs::Matrix{Int64})
    
    A = zeros(1, 6)   # affine transformation parameters
    
    

end
