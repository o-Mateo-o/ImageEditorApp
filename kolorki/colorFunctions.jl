include("auxiliaryFunctions.jl")


"""
Change contrast.

# Arguments
- `rgb`::Array{Array{Float64,2},1}`: r, g, b matrices tuple
- `parameter`::Float64`: in range [-100, 100], negative values create image with lower contrast
"""
function changeContrast(rgb, parameter::Float64)
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
Change lightness.
# Arguments
- `rgb`::Array{Array{Float64,2},1}`: r, g, b matrices tuple
- `parameter`::Float64`: in range [-100, 100]; negative value create image with lower lightness
"""
function changeLightness(rgb, parameter) # watrość parametru jest w zakresie [-100, 100], gdy wartość jest > 0 wtedy jest rozjaśnianie, a gdy < 0 przyciemnianie

    r, g, b = rgb
    
    Cmax, middleValue, Cmin = getValues(rgb)
    
    value = parameter / 100
    
    if value > 0 && value <= 1
        # rozjaśnianie bo współczynnik dodatni
        diff = 1 .- Cmin
        newLowValue = Cmin .+ min.(diff, value)
        increase = newLowValue .- Cmin
        fraction = increase ./ diff
        newHighValue = Cmax .+ ((1 .- Cmax) .* fraction)
        newMiddleValue = middleValue .+ ((1 .- middleValue) .* fraction)
    
        nR, nG, nB = setValuesLighten(rgb, newHighValue, newMiddleValue, newLowValue)
        return [nR, nG, nB] 
    elseif value < 0 && value >= -1
        value = abs(value)
        # przyciemnianie bo współczynnik ujemny
        newHighValue = Cmax .- min.(Cmax, value)
        fraction = (Cmax .- newHighValue) ./ (Cmax)
        newMiddleValue = middleValue .- (middleValue .* fraction)
        newLowValue = Cmin .- (Cmin .* fraction)
    
        nR, nG, nB = setValuesDarken(rgb, newHighValue, newMiddleValue, newLowValue)
        return [nR, nG, nB]
        
    elseif value == 0
        return [r, g, b]
    end
end    

"""
Change saturation.

#Arguments
- `rgb`::Array{Array{Float64,2},1}`: r, g, b matrices tuple
- `parameter`::Float64`: in range [-100, 100], negative value create image with lower saturation
"""
function changeSaturation(rgb, parameter)

    r, g, b = rgb
    gray = lightness(rgb)
    
    Cmax, middleValue, Cmin = getValues(rgb)
    
    value = parameter / 100
    saturationRange = min.(1 .- gray, gray)
    
    if value > 0 && value <= 1
        # zwiększenie nasycenia
        maxChange = min.(1 .- Cmax, Cmin)
        change = min.(saturationRange .* value, maxChange)
        newHighValue = Cmax .+ change
        newLowValue = Cmin .- change
        middleRatio = (gray .- middleValue) ./ (gray .- Cmax)
        newMiddleValue = gray .+ ((newHighValue .- gray) .* middleRatio)
    
        nR, nG, nB = setValuesSaturation(rgb, newHighValue, newMiddleValue, newLowValue)
        return [nR, nG, nB]

    elseif value < 0 && value >= -1
        # zmniejszenie nasycenia
        value = abs(value)
        maxChange = gray .- Cmin
        change = min.(saturationRange .* value, maxChange)    
        newLowValue = Cmin .+ change
        newHighValue = Cmax .- change
        middleRatio = (gray .- middleValue) ./ (gray .- Cmax)
        newMiddleValue = gray .+ ((newHighValue .- gray) .* middleRatio)
    
        nR, nG, nB = setValuesSaturation(rgb, newHighValue, newMiddleValue, newLowValue)
        return [nR, nG, nB]
        
    elseif value == 0
        return [r, g, b]
    end  
end


##################################################################################
# FILTERS
##################################################################################

# GRAYSCALES

"""
Count average value of each pixel.

# Arguments
- `rgb`::Array{Array{Float64,2},1}`: r, g, b matrices tuple
"""
function average(rgb) # as a average value of pixel

    r, g, b = rgb
    average = (r .+ g .+ b) ./ 3
    return [average, average, average]
end

"""
Get Lightness from HSL and set as a grayscale.

# Arguments
- `rgb`::Array{Array{Float64,2},1}`: r, g, b matrices tuple
"""
function grayscaleLightness(rgb) # as HSL lightness

    l = lightness(rgb)
    return [l, l, l]
end

"""
Gets grayscale by using some ratio.

# Arguments
- `rgb`::Array{Array{Float64,2},1}`: r, g, b matrices tuple
"""
function grayscaleLuminosity(rgb) # calculated by ratio

    r, g, b = rgb
    luminosity = 0.25 .* r .+ 0.75 .* g .+ 0.07 .* b
    return [luminosity, luminosity, luminosity]
end

# OTHER

"""
Create a negative of a image.
- `rgb`::Array{Array{Float64,2},1}`: r, g, b matrices tuple
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
    return [red, average, average]
end

function onlyBlueAndGrayscale(rgb)
    red, green, blue = rgb
    average = (red .+ green .+ blue) ./ 3
    return [red, average, average]
end

# Double rainbow? what is tHAT? :o

function changeColors(rgb, point) # point is in range [0,360]
    if point <= 360 && point >= 0
        r, g, b = rgb
        h, s, l = rgb2hsl(rgb)
        # newH = h
        Hue = h .+ point
        trypletHSL = Hue, s, l
        newRGB = hsl2rgb(trypletHSL)
        return newRGB
    end
end