
using Images
using ImageView
using Color
using FixedPointNumbers

# TODO: write full description
# Separate submodules for each dataset + common utilities for reading data
# Each submodule should provide 2 function:
#    load_images(n=-1)  -- load first n images from a dataset
#    load_shapes(n=-1)  -- load first n shapes from a dataset
# if n=-1 (default), load full dataset
# TODO: where and how to store data itself? maybe download from web?


module DataUtils

using Reexport
@reexport using Images
@reexport using ImageView
@reexport using Color
@reexport using FixedPointNumbers

export rawdata

rawdata{T<:FixedPoint}(img::Array{Gray{T}, 2}) = convert(Array{Float64, 2}, img)
rawdata(img::Image) = rawdata(data(img)')

end


# Cohn-Kanade+ dataset
module CK
export load_images
export load_shapes

using DataUtils

const DATA_DIR = expanduser("~/data/CK")
const IMG_DIR = joinpath(DATA_DIR, "images")
const LM_DIR = joinpath(DATA_DIR, "landmarks")

function readlms(filename::String)
    open(filename) do file
        readdlm(file)
    end
end


function load_shapes(n=-1)    
    lm_files = sort(readdir(LM_DIR))
    lm_paths = [joinpath(LM_DIR, lm_file) for lm_file in lm_files]
    n_use = n > 0 ? n : length(lm_paths)
    all_lms = Array(Matrix{Float64}, n_use)
    for i=1:n_use
        lms_xy = readlms(lm_paths[i])
        lms_ij = hcat(lms_xy[:, 2], lms_xy[:, 1])
        all_lms[i] = lms_ij
    end
    return all_lms
end


function load_images(n=-1)
    img_files = sort(readdir(IMG_DIR))
    img_paths = [joinpath(IMG_DIR, img_file) for img_file in img_files]
    n_use = n > 0 ? n : length(img_paths)
    all_imgs = Array(Matrix{Float64}, n_use)    
    for i=1:n_use
        all_imgs[i] = rawdata(imread(img_paths[i]))
        if i % 100 == 0
            info("$i images read")
        end
    end    
    return all_imgs
end


end


# images from original work by Cootes
module Cootes
export load_images
export load_shapes

using DataUtils
using MAT


const COOTES_DATA_DIR = "../matlab/icaam/datasets/cootes/data"
const IMG_HEIGHT = 480

function load_shape_from_mat(path::String)
    return matread(path)["annotations"]
end

function load_shapes(n=-1) 
    files = sort(filter(x -> endswith(x, ".mat"), readdir(COOTES_DATA_DIR)))
    paths = map(x->joinpath(COOTES_DATA_DIR, x), files)
    n_use = n > 0 ? n : length(paths)
    shapes = Array(Matrix{Float64}, n_use)
    for k=1:n_use
        shape_xy = load_shape_from_mat(paths[k])
        shape_ij = [IMG_HEIGHT .- shape_xy[:, 2] shape_xy[:, 1]]
        shapes[k] = shape_ij
        
    end
    return shapes
end

function load_images(n=-1)    
    files = sort(filter(x->endswith(x, ".bmp"), readdir(COOTES_DATA_DIR)))
    paths = map(x->joinpath(COOTES_DATA_DIR, x), files)
    n_use = n > 0 ? n : length(paths)
    imgs = Array(Matrix{Float64}, n_use)    
    for i=1:n_use
        img_rgb = imread(paths[i])
        imgs[i] = rawdata(convert(Array{Gray}, img_rgb))                
    end    
    return imgs
end



end
