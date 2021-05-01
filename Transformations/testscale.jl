using Images, StaticArrays# for presentation purposes
include(raw"C:\Users\cp\pakiety grafika proj\ManagingFiles\ManagePic.jl")
using Main.ManagePic 


initValues = generate_matrices_RGB(raw"C:\Users\cp\pakiety grafika proj\Skrypty\n.jpg")

# Input data
ORIGIN = (0, 100)
LD = (100, 1)
RU = (1, 100)
RATIO = (2.3, 5)

scaledBounds = [((pt[1]-ORIGIN[1])*RATIO[1]+ORIGIN[1], (pt[2]-ORIGIN[2])*RATIO[2]+ORIGIN[2]) for pt in [LD, RU]]

function sclX(Mat, i, k)
    af = (k - ORIGIN[2])/RATIO[2] + ORIGIN[2]
    if af < 1 # nie! ma być że jeśli nie ma indeksu/ogarnąć zaogrąglanie rang lub dodatki do macierzy
      return Mat[i, 1]
    end
    j = Int(floor(af))
    delta = af-j # POKAZAĆ ŻE NIE DZIAŁA NAJBLIŻSZE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    return  Mat[i, j] + (Mat[i, j+1] - Mat[i,j])*delta
end

function sclY(MatIx, k, j)
    af = (k - ORIGIN[1])/RATIO[1] + ORIGIN[1]
    if af < 1 # nie! ma być że jeśli nie ma indeksu/ogarnąć zaogrąglanie rang lub dodatki do macierzy
      return MatIx[1, j]
    end
    i = Int(floor(af))
    delta = af-i
    return MatIx[i, j] + (MatIx[i+1, j] - MatIx[i,j])*delta
end


#div można
N1 = 300

pr = [sclX(initValues[1], i, k) for i in 1:100, k in 1:N1]#źle
pg = [sclX(initValues[2], i, k) for i in 1:100, k in 1:N1]
pb = [sclX(initValues[3], i, k) for i in 1:100, k in 1:N1]





nr = [sclY(pr, k, j) for k in 1:222, j in 1:N1]
ng = [sclY(pg, k, j) for k in 1:222, j in 1:N1]
nb = [sclY(pb, k, j) for k in 1:222, j in 1:N1]

print("la")
aaasd = ([RGB(nr[i,j],ng[i, j],nb[i,j]) for i in 1:size(nr)[1], j in 1:size(nr)[2] ])
#save_pictures(raw"C:\Users\cp\pakiety grafika proj\Skrypty\na.png",nr, ng, nb)
#load(raw"C:\Users\cp\pakiety grafika proj\Skrypty\na.png")

#Gray.(Float32.(xInter)) |> display 
#scl1(initValues, 8, 400) |> display