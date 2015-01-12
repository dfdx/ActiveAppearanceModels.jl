
function viewlms(img::Image, lms::Landmarks)
    imgc, img2 = view(img)
    for i=1:size(lms, 1)
        annotate!(imgc, img2, AnnotationPoint(lms[i, 2], lms[i, 1], shape='.', size=4,
                                              color=RGB(1, 0, 0)))
    end
    return imgc, img2
end
viewlms(mat::Matrix{Float64}, lms::Landmarks) = viewlms(convert(Image, mat), lms)



function test_viewlms()
    all_imgs = read_images(IMG_DIR, n=200)
    img = all_imgs[200]
    all_lms = read_landmarks(LM_DIR, n=200)
    lms = all_lms[200]
    viewlms(img, lms)
end
