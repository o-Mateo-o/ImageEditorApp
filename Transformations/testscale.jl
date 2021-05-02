include(raw"C:\Users\cp\pakiety grafika proj\ManagingFiles\ManagePic.jl")
using .ManagePic, Images # Images - to load the picture into screen

initValues = generate_matrices_RGB(raw"C:\Users\cp\pakiety grafika proj\obrazki\mona.jpeg")

# Input data
ORIGIN = (500, 700)
LD = (600, 550)
RU = (300, 750)
RATIO = (1.5, 1.5)

function validity(ld, ru, tab)
    vals = [ld..., ru...]
    if ! all((typeof.(vals) ) .<: Number)
        return false
    elseif any(vals .< 1)
    return false
  elseif ld[1] > size(tab[1], 1) || ru[2] > size(tab[1], 2)
    return false
  elseif ld[1] <= ru[1] || ld[2] >= ru[2]
    print("DUPA")
    return false
  else
    return true
    end
end
# TODO: make exceptions of it

function sclX(Mat, i, k)
    point = (k - ORIGIN[2]) / RATIO[2] + ORIGIN[2]
    j = Int(floor(point))
    delta = point - j # POKAZAĆ ŻE NIE DZIAŁA NAJBLIŻSZE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    return  Mat[i, j + 1] + (Mat[i, j + 2] - Mat[i,j + 1]) * delta
end

function sclY(MatIx, k, j)
    point = (k - ORIGIN[1]) / RATIO[1] + ORIGIN[1] - RU[1]
    i = Int(floor(point))
    delta = point - i
    return MatIx[i + 1, j] + (MatIx[i + 2, j] - MatIx[i + 1,j]) * delta
end


function kRange(dim)
    sgn = dim == 2 ? (-1, 1) : (1, -1)
  bound1 = (LD[dim] + sgn[1] * 0.5 - ORIGIN[dim]) * RATIO[dim] + ORIGIN[dim]
  bound2 = (RU[dim] + sgn[2] * 0.5 - ORIGIN[dim]) * RATIO[dim] + ORIGIN[dim]
  return max(1, Int(floor(min(bound1, bound2))) + 1):min(
            size(initValues[1], dim), Int(floor(max(bound1, bound2))))
end


    @time begin
  if validity(LD, RU, initValues)
    final =  Array{Array{Float64,2},1}(undef, 3)

    kRange1 = kRange(1)
    kRange2 = kRange(2)

    @simd  for col in 1:3
      fixedInit = hcat(initValues[col][1:end, 1], initValues[col], initValues[col][1:end, end])
      xInterpol = [sclX(fixedInit, i, k) for i in RU[1]:LD[1], k in kRange2]
      fixedXInterpol = vcat(xInterpol[1,1:end]', xInterpol, xInterpol[end,1:end]')
      horizRange = 1:size(fixedXInterpol, 2)
      sectScaled = [sclY(fixedXInterpol, k, j) for k in kRange1, j in horizRange]
      final[col] = initValues[col]
      final[col][RU[1]:LD[1], LD[2]:RU[2]] .= 0
      final[col][kRange1, kRange2] = sectScaled
    end
  else
    print("ERROR")
  end
end



save_pictures(raw"C:\Users\cp\pakiety grafika proj\obrazki\na.png", final...)
load(raw"C:\Users\cp\pakiety grafika proj\obrazki\na.png")
