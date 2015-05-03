
function viewshape(img::Image, shape::Shape)
    imgc, img2 = ImageView.view(img)
    for i=1:size(shape, 1)
        annotate!(imgc, img2, AnnotationPoint(shape[i, 2], shape[i, 1], shape='.',
                                              size=4, color=RGB(1, 0, 0)))
    end
    imgc, img2
end
viewshape{N}(mat::Array{Float64, N}, shape::Shape) = viewshape(convert(Image, mat), shape)
