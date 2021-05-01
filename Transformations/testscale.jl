using Images# for presentation purposes
include(raw"C:\Users\cp\pakiety grafika proj\ManagingFiles\ManagePic.jl")
using .ManagePic 


initValues = generate_matrices_RGB(raw"C:\Users\cp\pakiety grafika proj\Skrypty\j.jpg")

# Input data
ORIGIN = (1,1)
LD = (300, 1)
RU = (1, 500)
RATIO = (2, 1)

function sclX(Mat, i, k)
    af = (k - ORIGIN[2]-0.5)/RATIO[2] + ORIGIN[2]
    j = Int(floor(af))
    delta = af-j # POKAZAĆ ŻE NIE DZIAŁA NAJBLIŻSZE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    return  Mat[i, j+1] + (Mat[i, j+2] - Mat[i,j+1])*delta
end

function sclY(MatIx, k, j)
    af = (k - ORIGIN[1]-0.5)/RATIO[1] + ORIGIN[1]
    
    i = Int(floor(af))
    delta = af-i
    return MatIx[i+1, j] + (MatIx[i+2, j] - MatIx[i+1,j])*delta
end


function kRange(dim)
  b1 = (LD[dim]-0.5-ORIGIN[dim])*RATIO[dim]+ORIGIN[dim]
  b2 = (RU[dim]+0.5-ORIGIN[dim])*RATIO[dim]+ORIGIN[dim]
  return Int(floor(min(b1, b2)))+1:Int(floor(max(b1, b2)))
end

function kRange2(dim)
  b1 = (LD[dim]+0.5-ORIGIN[dim])*RATIO[dim]+ORIGIN[dim]
  b2 = (RU[dim]-0.5-ORIGIN[dim])*RATIO[dim]+ORIGIN[dim]
  return Int(floor(min(b1, b2)))+1:Int(floor(max(b1, b2)))
end


println((LD[1]+0.5-ORIGIN[1])*RATIO[1]+ORIGIN[1])
println((RU[1]-0.5-ORIGIN[1])*RATIO[1]+ORIGIN[1])
println(kRange2(1))

@time begin

"""
rrr = hcat(initValues[1][1:end, 1],initValues[1], initValues[1][1:end, end])
ggg = hcat(initValues[2][1:end, 1],initValues[2], initValues[2][1:end, end])
bbb = hcat(initValues[3][1:end, 1],initValues[3], initValues[3][1:end, end])
ppr = [sclX(rrr, i, k) for i in RU[1]:LD[1], k in kRange(2)]#źle
pr = vcat(ppr[1,1:end]',ppr,ppr[end,1:end]')
ppg = [sclX(ggg, i, k) for i in RU[1]:LD[1], k in kRange(2)]
pg = vcat(ppg[1,1:end]',ppg,ppg[end,1:end]')
ppb = [sclX(bbb, i, k) for i in RU[1]:LD[1], k in kRange(2)]
pb = vcat(ppb[1,1:end]',ppb,ppb[end,1:end]')

rng2 = 1:size(pr, 2)
nr = [sclY(pr, k, j) for k in kRange2(1), j in rng2]
ng = [sclY(pg, k, j) for k in kRange2(1), j in rng2]
nb = [sclY(pb, k, j) for k in kRange2(1), j in rng2]
"""
done = Array{Array{Float64, 2},1}(undef, 3)
@simd  for col in 1:3
  rrr = hcat(initValues[col][1:end, 1],initValues[col], initValues[col][1:end, end])
  ppr = [sclX(rrr, i, k) for i in RU[1]:LD[1], k in kRange(2)]#źle
  pr = vcat(ppr[1,1:end]',ppr,ppr[end,1:end]')
  rng2 = 1:size(pr, 2)
  nr = [sclY(pr, k, j) for k in kRange2(1), j in rng2]
  done[col] = nr
end


end

save_pictures(raw"C:\Users\cp\pakiety grafika proj\Skrypty\na.png", done...)
load(raw"C:\Users\cp\pakiety grafika proj\Skrypty\na.png")
