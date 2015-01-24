
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

## function viewtri(img::Image, trimats::Vector{Matrix{Float64}})
##     imgc, img2 = view(img)
##     for trimat in trimats
##         ## a = geta(tri); xa, ya = getx(a), gety(a)
##         ## b = geta(tri); xb, yb = getx(b), gety(b)
##         ## c = geta(tri); xc, yc = getx(c), gety(c)
##         a = tuple(trimat[1, :]...)
##         b = tuple(trimat[2, :]...)
##         c = tuple(trimat[3, :]...)
##         annotate!(imgc, img2, AnnotationLine(a, b))
##         annotate!(imgc, img2, AnnotationLine(b, c))
##         annotate!(imgc, img2, AnnotationLine(c, a))
##     end
## end


function viewtri(img::Image, shape::Shape, trigs::Vector{(Int64, Int64, Int64)})
    imgc, img2 = view(img)
    for tr in trigs
        println("hey!")
        ## a = geta(tri); xa, ya = getx(a), gety(a)
        ## b = geta(tri); xb, yb = getx(b), gety(b)
        ## c = geta(tri); xc, yc = getx(c), gety(c)
        a = (shape[tr[1], 1], shape[tr[1], 2])
        b = (shape[tr[2], 1], shape[tr[2], 2])
        c = (shape[tr[3], 1], shape[tr[3], 2])
        annotate!(imgc, img2, AnnotationLine(a, b))
        annotate!(imgc, img2, AnnotationLine(b, c))
        annotate!(imgc, img2, AnnotationLine(c, a))
    end
end

viewtri(mat::Matrix{Float64}, shape::Shape, trigs::Vector{(Int64, Int64, Int64)}) =
    viewtri(convert(Image, mat), shape, trigs)



function test_viewtri()
    n = 170
    imgs = read_images(IMG_DIR, 200)
    shapes = read_landmarks(LM_DIR, 200)
    trigs = delaunayindexes(shapes[n])
    viewtri(imgs[n], shapes[n], trigs)
end
