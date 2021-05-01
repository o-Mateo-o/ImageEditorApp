include(raw"C:\Users\cp\pakiety grafika proj\ManagingFiles\ManagePic.jl")
using .ManagePic, Images # Images - to load the picture into screen

initValues = generate_matrices_RGB(raw"C:\Users\cp\pakiety grafika proj\obrazki\j.jpg")

# Input data
ORIGIN = (300, 301)
LD = (300, 1)
RU = (1, 500)
RATIO = (2, 1)

#TODO: check the validity of given input data (ld, ru)

function sclX(Mat, i, k)
    point = (k - ORIGIN[2] - 0.5) / RATIO[2] + ORIGIN[2]
    j = Int(floor(point))
    delta = point - j # POKAZAĆ ŻE NIE DZIAŁA NAJBLIŻSZE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    return  Mat[i, j + 1] + (Mat[i, j + 2] - Mat[i,j + 1]) * delta
end

function sclY(MatIx, k, j)
    point = (k - ORIGIN[1] - 0.5) / RATIO[1] + ORIGIN[1]
    i = Int(floor(point))
    delta = point - i
    return MatIx[i + 1, j] + (MatIx[i + 2, j] - MatIx[i + 1,j]) * delta
end


function kRange(dim)
    sgn = dim == 2 ? (-1, 1) : (1, -1)
  bound1 = (LD[dim] + sgn[1] * 0.5 - ORIGIN[dim]) * RATIO[dim] + ORIGIN[dim]
  bound2 = (RU[dim] + sgn[2] * 0.5 - ORIGIN[dim]) * RATIO[dim] + ORIGIN[dim]
  return Int(floor(min(bound1, bound2))) + 1:Int(floor(max(bound1, bound2)))
end

sectScaled = Array{Array{Float64,2},1}(undef, 3)
@simd  for col in 1:3
  fixedInit = hcat(initValues[col][1:end, 1], initValues[col], initValues[col][1:end, end])
  xInterpol = [sclX(fixedInit, i, k) for i in RU[1]:LD[1], k in kRange(2)]
  fixedXInterpol = vcat(xInterpol[1,1:end]', xInterpol, xInterpol[end,1:end]')
  horizRange = 1:size(fixedXInterpol, 2)
  sectScaled[col] = [sclY(fixedXInterpol, k, j) for k in kRange(1), j in horizRange]
end

#TODO: paste the scaled section into the base image, then save as it is done below

save_pictures(raw"C:\Users\cp\pakiety grafika proj\obrazki\na.png", sectScaled...)
load(raw"C:\Users\cp\pakiety grafika proj\obrazki\na.png")
