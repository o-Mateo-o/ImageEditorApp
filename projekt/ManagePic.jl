# ManagePic.jl

using FileIO, Images, ImageShow


"""
Convert a file to color matrices.

# Arguments
- `filename`::String`: name of file to load.
"""
function generateMatricesRGB(filename)
    img = load(filename)
    r = (Float64.(red.(img)))
    g = (Float64.(green.(img)))
    b = (Float64.(blue.(img)))
    return [r,g,b]
end # RGB

"""
Convert a loaded image to color matrices.

# Arguments
- `img`::Array{RGB{Normed{UInt8,8}},2}`: raw image.
"""
function generateMatricesRGB(img)
    r = (Float64.(red.(img)))
    g = (Float64.(green.(img)))
    b = (Float64.(blue.(img)))
    return [r,g,b]
end # RGB

"""
Convert color matrices o RGB matrice.

# Arguments
- `r`::Array{Float, 2}` full-size matrix of red color.
- `g`::Array{Float, 2}` full-size matrix of green color.
- `b`::Array{Float, 2}` full-size matrix of blue color.
"""
function matriceRGB(r, g, b)
    return ([RGB(r[i,j], g[i, j], b[i,j]) for i in 1:size(r)[1], j in 1:size(r)[2] ])
end # matriceRGB

"""
Save a r g b matrices as a picture.

# Arguments
- `newFilename`::String`: name of file.
- `r`::Array{Float, 2}` full-size matrix of red color.
- `g`::Array{Float, 2}` full-size matrix of green color.
- `b`::Array{Float, 2}` full-size matrix of blue color.
"""
function savePicture(newFilename, r, g, b)
    aa = matriceRGB(r, g, b) 
    save(newFilename, aa)
end # save

"""
Save RGB matrice as a picture.

# Arguments
- `newFilename`::String`: name of file.
- `RGB`::Array{Array{Float64,2},1}`: RGB matrices list.
"""
function savePictureRGB(newFilename, RGB)
    savePicture(newFilename, RGB[1], RGB[2], RGB[3])
end # save2

"""
Convert RGB to HSL.
Return image as HSL matrices list.

# Arguments
- `rgb`::Array{Array{Float64,2},1}`: r, g, b matrices list.
"""
function rgb2hsl(rgb)
    r, g, b = rgb

    arraySize = size(r)
    h = zeros(Float64, arraySize[1], arraySize[2])
    s = zeros(Float64, arraySize[1], arraySize[2])
    l = zeros(Float64, arraySize[1], arraySize[2])

    # L:Lightness - value of white light
    l = lightness(rgb)
    
    Cmax = max.(r, g, b)
    Cmin = min.(r, g, b)
    Δ = Cmax .- Cmin
    
    
    for i in 1:arraySize[1], j in 1:arraySize[2]
    
        # H:Hue - value of color
        if Δ[i,j] == 0
            h[i,j] = 0
        elseif Cmax[i,j] == r[i,j]
            h[i,j] = 60 * (((g[i,j] - b[i,j]) ./ Δ[i,j]) .% 6)
        elseif Cmax[i,j] == g[i,j]
            h[i,j] = 60 * (((b[i,j] - r[i,j]) ./ Δ[i,j]) .+ 2)
        else
            h[i,j] = 60 * (((r[i,j] - g[i,j]) ./ Δ[i,j]) .+ 4)
        end
        
        # S:Saturation -  color saturation 
        if Δ[i,j] == 0
            s[i,j] = 0
        else
            s[i,j] = Δ[i,j] ./ (1 - abs(2 * l[i,j] - 1))
        end
    end
    return [h,s,l]
end

"""
Convert HSL to RGB.
Return image as RGB matrices list.

#Arguments
- `hsl`::Array{Array{Float64,2},1}`: HSL matrices list.
"""
function hsl2rgb(hsl)
    h, s, l = hsl
    arraySize = size(h)
    r = zeros(Float64, arraySize[1], arraySize[2])
    g = zeros(Float64, arraySize[1], arraySize[2])
    b = zeros(Float64, arraySize[1], arraySize[2])
    
    for i in 1:arraySize[1], j in 1:arraySize[2]
        C = (1 - abs(2 * l[i,j] - 1)) .* s[i,j]
        X = C .* (1 - abs((h[i,j] ./ 60) % 2 - 1))
        m = l[i,j] - C ./ 2

        if h[i,j] >= 0 && h[i,j] < 60
            r[i,j] = C + m
            g[i,j] = X + m
            b[i,j] = m
        elseif h[i,j] >= 60 && h[i,j] < 120
            r[i,j] = X + m
            g[i,j] = C + m
            b[i,j] = m
        elseif h[i,j] >= 120 && h[i,j] < 180
            r[i,j] = m
            g[i,j] = m + C
            b[i,j] = m + X
        elseif h[i,j] >= 180 && h[i,j] < 240
            r[i,j] = m
            g[i,j] = X + m
            b[i,j] = C + m
        elseif h[i,j] >= 240 && h[i,j] < 300
            r[i,j] = X + m
            g[i,j] = m
            b[i,j] = C + m
        else
            r[i,j] = C + m
            g[i,j] = m
            b[i,j] = X + m
        end
    end
    return [r,g,b]
end 


"""
Count lightness.

Arduments:
- `rgb`::Array{Array{Float64,2},1}`: r, g, b matrices list.
"""
function lightness(rgb)
    r, g, b = rgb
    l = (max.(r, g, b) .+ min.(r, g, b)) ./ 2
    return l
end


