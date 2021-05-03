# testscale.jl - scale.jl file with presentation features 
using Images # Images - to load the picture into screen (for presentation purposes)
###################################################################################


include(raw"C:\Users\cp\pakiety grafika proj\ManagingFiles\ManagePic.jl")
using .ManagePic

"""
Scale the specified area of RGB image by a given ratio and origin point.
Return the whole image (as RGB matrices tuple) with transformed area.

# Arguments
- `initValuesS::Tuple{Array{Float64, 2}, Array{Float64, 2}, Array{Float64, 2}}`:
   tuple (r, g, b) of initial color matrices.
- `ldS::Tuple{Integer, Integer}`: lower-left scaling area corner coordinates as (y, x).
- `ruS::Tuple{Integer, Integer}`: upper-right scaling area corner coordinates as (y, x). 
- `originS::Tuple{Number, Number}`: scaling origin point as (y, x).
- `ratioS::Tuple{Number, Number}`: scaling ratio as (y, x).
"""
function scale(initValuesS, ldS, ruS, originS, ratioS)
    final =  Array{Array{Float64,2},1}(undef, 3)

    kRange1 = kRange(1, initValuesS[1], ldS, ruS, originS, ratioS)
    kRange2 = kRange(2, initValuesS[1], ldS, ruS, originS, ratioS)

    @simd  for col in 1:3
        fixedInit = hcat(initValuesS[col][1:end, 1], initValuesS[col], initValuesS[col][1:end, end])
        xInterpol = [sclX(fixedInit, i, k, originS, ratioS) for i in ruS[1]:ldS[1], k in kRange2]
        fixedXInterpol = vcat(xInterpol[1,1:end]', xInterpol, xInterpol[end,1:end]')
        horizRange = 1:size(fixedXInterpol, 2)
        sectScaled = [sclY(fixedXInterpol, k, j, ruS, originS, ratioS) for k in kRange1, j in horizRange]
        final[col] = initValuesS[col]
        final[col][ruS[1]:ldS[1], ldS[2]:ruS[2]] .= 0
        final[col][kRange1, kRange2] = sectScaled
    end

    return final
end


"""
Evaluate the color for the point of interpolated and scaled in x axis
extract of monochromatic matrix.

# Arguments
- `Mat::Array{Float64, 2}`: initial color matrix.
- `i::Integer`: row index.
- `k::Integer`: colum index from range after scaling.
- `originF::Tuple{Number, Number}`: scaling origin point as (y, x).
- `ratioF::Tuple{Number, Number}`: scaling ratio as (y, x).
"""
function sclX(Mat, i, k, originF, ratioF)
    # coordinate of the point before scaling
    point = (k - originF[2]) / ratioF[2] + originF[2]
    j = Int(floor(point))
    delta = point - j
    # standard linear interpolation formula
    return  Mat[i, j + 1] + (Mat[i, j + 2] - Mat[i,j + 1]) * delta
end


"""
Evaluate the color for the point of interpolated and scaled in y axis
exctact of already x-scaled monochromatic matrix.

# Arguments
- `MatIx::Array{Float64, 2}`: extract of color matrix already interpolated by the x axis.
- `k::Integer`: row from range after scaling.
- `j::Integer`: colum index.
- `ruF::Tuple{Integer, Integer}`: upper-right scaling area corner coordinates as (y, x). 
- `originF::Tuple{Number, Number}`: scaling origin point as (y, x).
- `ratioF::Tuple{Number, Number}`: scaling ratio as (y, x).
"""
function sclY(MatIx, k, j, ruF, originF, ratioF)
    # coordinate of the point before scaling
    point = (k - originF[1]) / ratioF[1] + originF[1] - ruF[1]
    i = Int(floor(point))
    delta = point - i
    # standard linear interpolation formula
    return MatIx[i + 1, j] + (MatIx[i + 2, j] - MatIx[i + 1,j]) * delta
end


"""
Prepare a range of all pixels in scaled area and given axis.

# Arguments
- `dim::Integer`: expected dimension (axis) - 1 or 2.
- `colorMatrix::Array{Float64, 2}`: initial monochromatic color matrix.
- `ldR::Tuple{Integer, Integer}`: lower-left scaling area corner coordinates as (y, x).
- `ruR::Tuple{Integer, Integer}`: upper-right scaling area corner coordinates as (y, x). 
- `originR::Tuple{Number, Number}`: scaling origin point as (y, x).
- `ratioR::Tuple{Number, Number}`: scaling ratio as (y, x).
"""
function kRange(dim, colorMatrix, ldR, ruR, originR, ratioR)
    sgn = dim == 2 ? (-1, 1) : (1, -1)
  bound1 = (ldR[dim] + sgn[1] * 0.5 - originR[dim]) * ratioR[dim] + originR[dim]
  bound2 = (ruR[dim] + sgn[2] * 0.5 - originR[dim]) * ratioR[dim] + originR[dim]
  return max(1, Int(floor(min(bound1, bound2))) + 1):min(
            size(colorMatrix, dim), Int(floor(max(bound1, bound2))))
end


"""
Check the validity of corner values given on input. Return true if correct.

# Arguments
- `initValuesV::Tuple{Array{Float64, 2}, Array{Float64, 2}, Array{Float64, 2}}`:
   tuple (r, g, b) of initial color matrices.
- `ldV::Tuple{Integer, Integer}`: lower-left scaling area corner coordinates as (y, x). 
- `ruV::Tuple{Integer, Integer}`: upper-right scaling area corner coordinates as (y, x). 
"""
function validity(initValuesV, ldV, ruV)
    vals = [ldV..., ruV...]
    if ! all((typeof.(vals) ) .<: Number)
        return false
    elseif any(vals .< 1)
    return false
  elseif ldV[1] > size(initValuesV[1], 1) || ruV[2] > size(initValuesV[1], 2)
    return false
  elseif ldV[1] <= ruV[1] || ldV[2] >= ruV[2]
    return false
  else
    return true
    end
end
# TODO: make exceptions of it


###################################################################################

# Input data
origin = (500, 700) # origin point
ld = (600, 550) # lower-left corner of the area
ru = (300, 750) # upper-right corner of the area
ratio = (1.5, 1.5) # scaling ratio
imagePath = raw"C:\Users\cp\pakiety grafika proj\obrazki\mona.jpeg"

initValues = generate_matrices_RGB(imagePath)

if validity(initValues, ld, ru)
  scaledImage = scale(initValues, ld, ru, origin, ratio)
  save_pictures(raw"C:\Users\cp\pakiety grafika proj\obrazki\generated.png", scaledImage...)
  load(raw"C:\Users\cp\pakiety grafika proj\obrazki\generated.png")
else
  print("ERROR")
end
