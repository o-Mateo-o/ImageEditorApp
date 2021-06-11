
# colorFunctions.jl
include("ManagePic.jl")

# auxiliary functions

"""
Get maximum, middle and minimum values of each color.

# Arguments
- `rgb::Array{Array{Float64,2},1}`: r, g, b matrices list.
"""
function getValues(rgb)

    r, g, b = rgb
    Cmax = max.(r, g, b)
    Cmin = min.(r, g, b)
    sum = r .+ g .+ b
    middleValue = sum .- Cmax .- Cmin
    return [Cmax, middleValue, Cmin]
end
"""
Change contrast.

# Arguments
- `rgb::Array{Array{Float64,2},1}`: r, g, b matrices list.
- `parameter::Float64`: in range [-100, 100], negative values create image with lower contrast.
"""
function changeContrast(rgb, parameter)
    if parameter >= -100 && parameter <= 100
        factor = (102 * (parameter + 100)) ./ (100 * (102 - parameter))
        r, g, b = rgb   
        arraySize = size(r)
        newRed = zeros(Float64, arraySize[1], arraySize[2])
        newGreen = zeros(Float64, arraySize[1], arraySize[2])
        newBlue = zeros(Float64, arraySize[1], arraySize[2])
        
        newRed = factor .* (r .- 0.5) .+ 0.5
        newGreen = factor .* (g .- 0.5) .+ 0.5
        newBlue = factor .* (b .- 0.5) .+ 0.5
    else
        println("Error")
    end
    return [newRed, newGreen, newBlue]
end

"""
Change brightness.

# Arguments
- `rgb::Array{Array{Float64,2},1}`: r, g, b matrices list.
- `parameter::Float64`: in range [-100, 100]; negative value create image with lower brightness.
"""
function changeBrightness(rgb, value) # wartosc [-100,100]
    if value <= 100 && value >= -100 && (typeof(value) == Float64 || typeof(value) == Int64)
        point = value / 100
        r, g, b = rgb
        newR = min.(max.(0.5* point .+ r, 0), 1)
        newG =  min.(max.(0.5* point .+ g, 0), 1)
        newB = min.(max.(0.5*point .+ b, 0), 1)
            return [newR, newG,newB]
    else
        return ("Error")
    end
end    


"""
Change lightness.

# Arguments
- `rgb::Array{Array{Float64,2},1}`: r, g, b matrices list.
- `parameter::Float64`: in range [-100, 100]; negative value create image with lower lightness.
"""
function changeLightness(rgb, value) # wartosc [-100,100]
    if value <= 100 && value >= -100 && (typeof(value) == Float64 || typeof(value) == Int64)
        point = value / 100

        h, s, l = rgb2hsl(rgb)
        newL = l .+ l .* point
        tryplet = h, s, newL
        newR, newG, newB = hsl2rgb(tryplet)
        return [newR, newG,newB]

    else
        return ("Error")
    end
end    

"""
Change saturation.

#Arguments
- `rgb::Array{Array{Float64,2},1}`: r, g, b matrices list.
- `parameter::Float64`: in range [-100, 100], negative value create image with lower saturation.
"""
function changeSaturation(rgb, value)
    if value <= 100 && value >= -100 && (typeof(value) == Float64 || typeof(value) == Int64)
        point = value / 100
        h, s, l = rgb2hsl(rgb)
        if value >= 0
            complementS = 1 .- s
            newS = complementS .* point .+ s
        else
            newS = s .+ s .* point
        end
        tryplet = h, newS, l
        r, g, b = hsl2rgb(tryplet)
        return [r,g,b]
    else
        return ("Error")
    end
end


##################################################################################
# FILTERS
##################################################################################

# GRAYSCALES

"""
Count average value of each pixel.

# Arguments
- `rgb::Array{Array{Float64,2},1}`: r, g, b matrices list.
"""
function average(rgb) # as a average value of pixel

    r, g, b = rgb
    average = (r .+ g .+ b) ./ 3
    return [average, average, average]
end

"""
Get Lightness from HSL and set as a grayscale.

# Arguments
- `rgb::Array{Array{Float64,2},1}`: r, g, b matrices list.
"""
function grayscaleLightness(rgb) # as HSL lightness

    l = lightness(rgb)
    return [l, l, l]
end

"""
Gets grayscale by using some ratio.

# Arguments
- `rgb::Array{Array{Float64,2},1}`: r, g, b matrices list.
"""
function grayscaleLuminosity(rgb) # calculated by ratio

    r, g, b = rgb
    luminosity = 0.25 .* r .+ 0.75 .* g .+ 0.07 .* b
    return [luminosity, luminosity, luminosity]
end

# OTHER

"""
Create a negative of a image.
- `rgb::Array{Array{Float64,2},1}`: r, g, b matrices list.
"""
function negative(rgb)
    r, g, b = rgb
    newRed = 1 .- r
    newGreen = 1 .- g
    newBlue = 1 .- b
    return [newRed, newGreen, newBlue]
end

# Only
function onlyRed(rgb)
    r, g, b = rgb
    arraySize = size(g)
    g = zeros(Float64, arraySize[1], arraySize[2])
    b = zeros(Float64, arraySize[1], arraySize[2])
    return [r, g, b]
end

function onlyGreen(rgb)
    r, g, b = rgb
    arraySize = size(g)
    r = zeros(Float64, arraySize[1], arraySize[2])
    b = zeros(Float64, arraySize[1], arraySize[2])
    return [r, g, b]
end

function onlyBlue(rgb)
    r, g, b = rgb
    arraySize = size(g)
    g = zeros(Float64, arraySize[1], arraySize[2])
    r = zeros(Float64, arraySize[1], arraySize[2])
    return [r, g, b]
end

# Without
function withoutRed(rgb)
    r, g, b = rgb
    arraySize = size(g)
    r = zeros(Float64, arraySize[1], arraySize[2])
    return [r, g, b]
end

function withoutGreen(rgb)
    r, g, b = rgb
    arraySize = size(g)
    g = zeros(Float64, arraySize[1], arraySize[2])
    return [r, g, b]
end

function withoutBlue(rgb)
    r, g, b = rgb
    arraySize = size(b)
    b = zeros(Float64, arraySize[1], arraySize[2])
    return [r, g, b]
end

# AsGray
function redAsAGrayscale(rgb)
    red, green, blue = rgb
    average = (red .+ green .+ blue) ./ 3
    return [average, green, blue]
end

function greenAsAGrayscale(rgb)
    red, green, blue = rgb
    average = (red .+ green .+ blue) ./ 3
    return [red, average, blue]
end

function blueAsAGrayscale(rgb)
    red, green, blue = rgb
    average = (red .+ green .+ blue) ./ 3
    return [red, green, average]
end

function onlyRedAndGrayscale(rgb)
    red, green, blue = rgb
    average = (red .+ green .+ blue) ./ 3
    return [red, average, average]
end

function onlyGreenAndGrayscale(rgb)
    red, green, blue = rgb
    average = (red .+ green .+ blue) ./ 3
    return [average, green, average]
end

function onlyBlueAndGrayscale(rgb)
    red, green, blue = rgb
    average = (red .+ green .+ blue) ./ 3
    return [average, average, blue]
end

# Double rainbow? what is tHAT? :o

function changeColors(rgb, point) # point is in range [0,360]
    if point <= 360 && point >= 0
        h, s, l = rgb2hsl(rgb)
        Hue = h .+ point
        trypletHSL = Hue, s, l
        newRGB = hsl2rgb(trypletHSL)
        return newRGB
    end
end
