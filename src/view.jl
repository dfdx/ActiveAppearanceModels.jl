
using Images, ImageView
using VoronoiDelaunay

function viewshape(img::Image, lms::Shape)
    imgc, img2 = view(img)
    for i=1:size(lms, 1)
        annotate!(imgc, img2, AnnotationPoint(lms[i, 2], lms[i, 1], shape='.', size=4,
                                              color=RGB(1, 0, 0)))
    end
    return imgc, img2
end
viewshape(mat::Matrix{Float64}, lms::Shape) = viewshape(convert(Image, mat), lms)


function viewtri(img::Image, shape::Shape, trigs::Matrix{Int64})
    imgc, img2 = view(img)
    for i=1:size(trigs, 1)
        println(i)
        a = (shape[trigs[i, 1], 2], shape[trigs[i, 1], 1])
        b = (shape[trigs[i, 2], 2], shape[trigs[i, 2], 1])
        c = (shape[trigs[i, 3], 2], shape[trigs[i, 3], 1])
        annotate!(imgc, img2, AnnotationLine(a, b))
        annotate!(imgc, img2, AnnotationLine(b, c))
        annotate!(imgc, img2, AnnotationLine(c, a))
    end
end

viewtri(mat::Matrix{Float64}, shape::Shape, trigs::Matrix{Int64}) =
    viewtri(convert(Image, mat), shape, trigs)



function test_viewtri()
    n = 100
    imgs = read_images(IMG_DIR, 200)
    shapes = read_landmarks(LM_DIR, 200)
    trigs = delaunayindexes(shapes[n])
    viewtri(imgs[n], shapes[n], trigs)
end
