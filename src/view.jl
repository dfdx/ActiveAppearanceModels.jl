
# import Gadfly: plot, Geom

function viewshape(img::Image, lms::Shape)
    imgc, img2 = view(img)
    for i=1:size(lms, 1)
        annotate!(imgc, img2, AnnotationPoint(lms[i, 2], lms[i, 1], shape='.',
                                              size=4, color=RGB(1, 0, 0)))
    end
    imgc, img2
end
viewshape(mat::Matrix{Float64}, lms::Shape) = viewshape(convert(Image, mat), lms)


histogram{T,N}(A::Array{T,N}) = plot(x=flatten(A), Geom.histogram)

function nview{N}(img::Array{Float64, N})
    mn, mx = minimum(img), maximum(img)
    view((img - mn) / (mx - mn))
end
