##################################################################################
# AFFINE TRANSITION
##################################################################################

"""
Convert a tuple of coordinates to a "vector" format.

# Arguments
- `tuple`::Tuple{Float, Float}`: point coordinate (y, x). 
"""
function tupleToVector(tuple)
    return [elem for elem in tuple]
end

"""
Create a transition matrix for a series of operations.
Each parameter in input list defines a type (scaling or rotation) of operation and its ratio/angle.

# Arguments
- `parameters`::Array{Tuple{Char, Float/Tuple{Float, Float}}, 1}`: point coordinate (y, x). 
"""
function mapMatrix(parameters)
    matrix = [1 0; 0 1]
    for trans in parameters
        if trans[1] == 's'
            matrix = [trans[2][1] 0; 0 trans[2][2]] * matrix
        elseif trans[1] == 'r'
            angleRad = - trans[2] / 180 * pi
            matrix = [cos(angleRad) -sin(angleRad); sin(angleRad) cos(angleRad)] * matrix
        end
    end
    return matrix
end

"""
Find coordinates of a point after transition by a given matrix.

# Arguments
- `y`::Float` y coordinate of a point.
- `x`::Float` x coordinate of a point.
- `originCnvrtd`::Array{Float, 1}` origin point as a "vector".
- `mapMtrx`::Array{Float, 2}` transition matrix.
"""
function mappedCoords(y, x, originCnvrtd, mapMtrx)
    return reverse(mapMtrx * ([x; y] .- reverse(originCnvrtd)) .+ reverse(originCnvrtd))
end

"""
Find ranges of selection area after a transition by a matrix.
Available both transformation and its inversion evaluation.

# Arguments
- `colorMatrix`::Array{Float, 2}` full-size matrix of one color.
- `ld::Tuple{Integer, Integer}`: lower-left selection area corner coordinates as (y, x).
- `ru::Tuple{Integer, Integer}`: upper-right selection area corner coordinates as (y, x). 
- `origin::Tuple{Number, Number}`: transition origin point as (y, x).
- `mapMtrx`::Array{Float, 2}` transition matrix.
- `translVector`::Array{Float, 1}` translation vector to move floating area by.
- `rever`::Bool` information about straight or reversed checking.
"""
function tRange(colorMatrix, ld, ru, origin, mapMtrx, translVector, rever=false)
    sizeOfM = size(colorMatrix)
    crnrs = tupleToVector.([ld, ru, (ld[1], ru[2]), (ru[1], ld[2])])
    crnrsMapped = [mappedCoords(corner[1] - translVector[1] * (rever), corner[2] - translVector[2] * (rever), origin, mapMtrx) .+ translVector .* (!rever) for corner in crnrs]
    choiceY = [corner[1] for corner in crnrsMapped]
    choiceX = [corner[2] for corner in crnrsMapped]

    boundsPreY = Int.([floor(minimum(choiceY)), ceil(maximum(choiceY))])
    boundsPreX = Int.([floor(minimum(choiceX)), ceil(maximum(choiceX))])
    if rever == false
        ldNew = (minimum([sizeOfM[1], boundsPreY[2]]), maximum([1, boundsPreX[1]]))
        ruNew = (maximum([1, boundsPreY[1]]), minimum([sizeOfM[2], boundsPreX[2]]))

        return [[ruNew[1], ldNew[1]], [ldNew[2], ruNew[2]]]
    else
        ldNew = (boundsPreY[2], boundsPreX[1])
        ruNew = (boundsPreY[1], boundsPreX[2])
        return [[ruNew[1], ldNew[1]], [ldNew[2], ruNew[2]]]
    end
end

"""
Find the extra frame dimensions.
They are used to avoid trying to evaluate pixels from out of a initial selection range.

# Arguments
- `tRepRangeBnds1`::Array{Integer, 2}` vertical boundaries after inverted ranges evaluation.
- `tRepRangeBnds2`::Array{Integer, 2}` horizontal boundaries after inverted ranges evaluation.
- `ld::Tuple{Integer, Integer}`: lower-left selection area corner coordinates as (y, x).
- `ru::Tuple{Integer, Integer}`: upper-right selection area corner coordinates as (y, x). 
"""
function mtrxExtensionRngs(tRepRangeBnds1, tRepRangeBnds2, ld, ru)
    extRanges = [[max(ru[1] - tRepRangeBnds1[1] - 1, 0), max(tRepRangeBnds1[2] - ld[1] - 1, 0) + 1],
        [max(ld[2] - tRepRangeBnds2[1] - 1, 0), max(tRepRangeBnds2[2] - ru[2] - 1, 0) + 1]]
    return extRanges
end

"""
Prepare matrices of selections extented by a proper frame.

# Arguments
- `extRngs`::Array{Array{Integer, 1}, 1}` vertical boundaries after inverted ranges evaluation.
- `colorMatrix`::Array{Float, 2}` selection from a matrix of one color.
- `mode::Integer` color mode is 3; mask (artificial-alpha) mode is 1.
"""
function extendedInitialMatrix(extRngs, colorMatrix, mode)
    noneValue = 1
    if mode == 1
        edgeValue = 1
        sizeYOfM = size(colorMatrix, 1)
        horizontal = hcat(fill(noneValue, (sizeYOfM, extRngs[2][1])), fill(edgeValue, (sizeYOfM, 1)),
        colorMatrix, fill(edgeValue, (sizeYOfM, 1)), fill(noneValue, (sizeYOfM, extRngs[2][2])))
        sizeXOfH = size(horizontal, 2)
        return vcat(fill(noneValue, (extRngs[1][1], sizeXOfH)), fill(edgeValue, (1, sizeXOfH)),
            horizontal, fill(edgeValue, (1, sizeXOfH)), fill(noneValue, (extRngs[1][2], sizeXOfH)))
        
    else
        sizeYOfM = size(colorMatrix, 1)
        horizontal = hcat(fill(noneValue, (sizeYOfM, extRngs[2][1])), colorMatrix[1:end, 1],
        colorMatrix, colorMatrix[1:end, end], fill(noneValue, (sizeYOfM, extRngs[2][2])))
        sizeXOfH = size(horizontal, 2)
        return vcat(fill(noneValue, (extRngs[1][1], sizeXOfH)), horizontal[1, 1:end]',
            horizontal, horizontal[end, 1:end]', fill(noneValue, (extRngs[1][2], sizeXOfH)))
    end 
end

"""
Calculate (by bilinear interpolation) the value for pixel which coordinates of origin are given.
Theese coordinates are not integer, so the calculation is inevitable.

# Arguments
- `y`::Float` y coordinate of a point.
- `x`::Float` x coordinate of a point.
- `colorMatrix`::Array{Float, 2}` (extended) selection from a matrix of one color.
"""
function evaluate(y, x, colorMatrix)
    xFloor = Int(floor(x))
    yFloor = Int(floor(y))
    
    difs = [[1 - y + yFloor, -yFloor + y], [1 - x + xFloor, -xFloor + x]]
    return sum([difs[1][1] * difs[2][1] * colorMatrix[yFloor, xFloor],
                difs[1][1] * difs[2][2] * colorMatrix[yFloor, xFloor + 1],
                difs[1][2] * difs[2][1] * colorMatrix[yFloor + 1, xFloor],
                difs[1][2] * difs[2][2] * colorMatrix[yFloor + 1, xFloor + 1]])
end

"""
Get the selection and its position after a series of given transformations on RGB image.

# Arguments
- `initValues::Array{Array{Float, 2}, 1}` series of input color or mask matrices in.
- `ld::Tuple{Integer, Integer}`: lower-left selection area corner coordinates as (y, x).
- `ru::Tuple{Integer, Integer}`: upper-right selection area corner coordinates as (y, x). 
- `origin::Tuple{Number, Number}`: transition origin point as (y, x).
- `parameters::Array{Tuple{Char, Float/Tuple{Float, Float}}, 1}`: point coordinate (y, x). 
- `translVectorTpl`::Tuple{Float, Float}` raw translation vector to move floating area by.
"""
function transform(initValues, ld, ru, origin, parameters, translVectorTpl)
    translVector = [translVectorTpl[1]; translVectorTpl[2]]
    final =  Array{Array{Float64,2},1}(undef, length(initValues))
    
    mapMtrx = mapMatrix(parameters)
    invMapMtrx = zeros(2, 2)
    try
        invMapMtrx = inv(mapMtrx)
    catch
        throw(ErrorException("Cannot scale by 0 value."))
    end
    
    
    originCnvrtd = tupleToVector(origin)

    acqrRanges = tRange(initValues[1], ld, ru, origin, mapMtrx, translVector)
    tRange1 = acqrRanges[1][1]:acqrRanges[1][2]
    tRange2 = acqrRanges[2][1]:acqrRanges[2][2]
    repLd = (acqrRanges[1][2], acqrRanges[2][1])
    repRu = (acqrRanges[1][1], acqrRanges[2][2])
    acqrRepRanges = tRange(initValues[1][ru[1]:ld[1], ld[2]:ru[2]], repLd, repRu, origin, invMapMtrx, translVector, true)
    extRngs = mtrxExtensionRngs([acqrRepRanges[1][1], acqrRepRanges[1][2]],
             [acqrRepRanges[2][1], acqrRepRanges[2][2]], ld, ru)

    if length(tRange1) == 0 || length(tRange2) == 0
        @simd  for col in 1:length(initValues)
            final[col] = ones(size(initValues[col]))
        end
        return (final, ((0, 0), (0, 0)))
    
    else
        @simd  for col in 1:length(initValues)
            extndMatrix = extendedInitialMatrix(extRngs, initValues[col][ru[1]:ld[1], ld[2]:ru[2]], length(initValues))
            sectTransformed = [evaluate((mappedCoords(i - translVector[1], j - translVector[2], originCnvrtd, invMapMtrx) 
            .+ [extRngs[1][1] + 1, extRngs[2][1] + 1] .- [ru[1] - 1, ld[2] - 1])..., extndMatrix) for i in tRange1, j in tRange2]
            final[col] = ones(size(initValues[col]))
            final[col][tRange1, tRange2] = sectTransformed 
        end
    end
    return (final, ((tRange1[end], tRange2[1]), (tRange1[1], tRange2[end])))
end

##################################################################################
# GENERAL TRANSFORMATION FUNCTIONS
##################################################################################

"""
Give a deafult origin point - at the center of selection.

# Arguments
- `ld::Tuple{Integer, Integer}`: lower-left scaling area corner coordinates as (y, x). 
- `ru::Tuple{Integer, Integer}`: upper-right scaling area corner coordinates as (y, x). 
"""
function defaultOrigin(ld, ru)
    return (ru[1]+(ld[1]-ru[1])/2, ld[2]+(ru[2]-ld[2])/2)
end

"""
Check the validity of corner values given on input. Return true if correct.

# Arguments
- `initValues::Array{Array{Float64,2},1}`: r, g, b matrices list.
- `ld::Tuple{Integer, Integer}`: lower-left scaling area corner coordinates as (y, x). 
- `ru::Tuple{Integer, Integer}`: upper-right scaling area corner coordinates as (y, x). 
"""
function validity(initValues, ld, ru)
    vals = [ld..., ru...]
    if ! all((typeof.(vals) ) .<: Number)
        return false
    elseif any(vals .< 1)
    return false
  elseif ld[1] > size(initValues[1], 1) || ru[2] > size(initValues[1], 2)
    return false
  elseif ld[1] < ru[1] || ld[2] > ru[2]
    return false
  else
    return true
    end
end

"""
Paste transformed selection into the image.

# Arguments
- `colorMatrices::Array{Array{Float, 2}, 1}`: previous color matrices.
- `transformedMatrices::Array{Array{Float, 1}, 1}`: image selection after a series of transformation.
- `transformedMask::Array{Array{Float, 1}, 1}`: mask selection after a series of transformation.
- `ld::Tuple{Integer, Integer}`: lower-left scaling area corner coordinates as (y, x). 
- `ru::Tuple{Integer, Integer}`: upper-right scaling area corner coordinates as (y, x). 
"""
function merge(colorMatrices, transformedMatrices, transformedMask, ld, ru)
    outImage = Array{Array{Float64,2},1}(undef, 3)
    @simd for col in 1:3
        outImage[col] = colorMatrices[col]
        outImage[col][ru[1]:ld[1], ld[2]:ru[2]] .= 1
        outImage[col] =  transformedMatrices[col] .* (1 .- transformedMask[1]) + transformedMask[1] .* outImage[col]
    end
    return outImage
end

"""
Conduct transformations.

# Arguments
- `initValues::Array{Array{Float, 2}, 1}`: previous color matrices.
- `ld::Tuple{Integer, Integer}`: lower-left scaling area corner coordinates as (y, x). 
- `ru::Tuple{Integer, Integer}`: upper-right scaling area corner coordinates as (y, x).
- `transfList::Array{Tuple{Tuple{Float, Float}, /parameters/, Tuple{Float, Float}}, 1}`:
array of operations on image, each containing origin, parameters(described previously), translation vector.

# Example
selectionTransform(initValues, (400, 300), (200, 700),
 [ ((300, 500), [('r', 100), ('s', (2, 1))], (20.4, -40)) ])

Does the transformations on initValues matrices, where selecion is defined by LD = (400, 300), RU = (200, 700) 
and the origin point is (300, 500). Image is translated by (20.4, -40), rotated by 100 degrees and scaled with ratios 2, 1.
"""
function selectionTransform(initValues, ld, ru, transfList)
    if ! validity(initValues, ld, ru)
        throw(ErrorException("Selection range error. Check LD and RU coordinates."))
    end
    mask = [zeros(size(initValues[1]))]
    floating = initValues
    floatingLd = ld
    floatingRu = ru
    for operation in transfList
        floating = transform(floating, floatingLd, floatingRu, operation[1], operation[2], operation[3])[1]      
        tempData = transform(mask, floatingLd, floatingRu, operation[1], operation[2], operation[3])
        mask = tempData[1]
        floatingLd = tempData[2][1]
        floatingRu = tempData[2][2]
        if floatingLd == (0, 0) || floatingRu == (0, 0)
            throw(ErrorException("Cannot transform by given parameters. Range error."))
        end
    end
    return merge(initValues, floating, mask, ld, ru)
end
    
##################################################################################
# SYMMETRY
##################################################################################
function mirror(RGB, ax)
    if ax == :x 
        dim = 1 
    elseif ax == :y 
        dim = 2 
    else
        return
    end
    newRGB = reverse.(RGB, dims=dim)
    return newRGB 
end
