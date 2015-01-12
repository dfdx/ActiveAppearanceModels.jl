
using Images
using ImageView
using Color
using FixedPointNumbers

const DATA_DIR = expanduser("~/data/CK")
const IMG_DIR = joinpath(DATA_DIR, "images")
const LM_DIR = joinpath(DATA_DIR, "landmarks")


typealias Landmarks Matrix{Float64}


function readlms(filename::String)
    open(filename) do file
        readdlm(file)
    end
end

function read_landmarks(lm_dir::String; n=-1)    
    lm_files = sort(readdir(lm_dir))
    lm_paths = [joinpath(lm_dir, lm_file) for lm_file in lm_files]
    n_use = n > 0 ? n : length(lm_paths)
    all_lms = Array(Landmarks, n_use)
    for i=1:n_use
        lms_xy = readlms(lm_paths[i])
        lms_ij = hcat(lms_xy[:, 2], lms_xy[:, 1])
        all_lms[i] = lms_ij
    end
    return all_lms
end


rawdata{T<:FixedPoint}(img::Array{Gray{T}, 2}) = convert(Array{Float64, 2}, img)
rawdata(img::Image) = rawdata(data(img)')


function read_images(img_dir::String; n=-1)
    img_files = sort(readdir(img_dir))
    img_paths = [joinpath(img_dir, img_file) for img_file in img_files]
    n_use = n > 0 ? n : length(lm_paths)
    all_imgs = Array(Matrix{Float64}, n_use)    
    for i=1:n_use
        all_imgs[i] = rawdata(imread(img_paths[i]))
        # TODO: preprocess - resize, convert to gray, etc.
        if i % 100 == 0
            info("$i images read")
        end
    end    
    return all_imgs
end


