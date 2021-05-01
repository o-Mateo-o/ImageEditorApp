using Images # for presentation purposes
include(raw"C:\Users\cp\pakiety grafika proj\ManagingFiles\ManagePic.jl")
using .ManagePic 


initValues = generate_matrices_RGB(raw"C:\Users\cp\pakiety grafika proj\Skrypty\j.jpg")[1]

canvasDims = size(initValues)
canvasIdcs = zeros(Float16, canvasDims)

canvasIdcs = [(i, j) for i in 1:canvasDims[1], j in 1:canvasDims[2]]

# Input data
ORIGIN = (1, 1)
LD = (500, 10)
RU = (1, 500)
RATIO = (2.4, 5)

#TODO: check validity of LD, RU and ORIGIN(can b3e +- 1 -edges)
areaValues = initValues[RU[1]:LD[1], LD[2]:RU[2]]
@time scaledIdsc = [((y-ORIGIN[1])*RATIO[1]+ORIGIN[1], (x-ORIGIN[2])*RATIO[2]+ORIGIN[2])
                for y in RU[1]:LD[1], x in LD[2]:RU[2]] # TODO: clear;speedup
scaledBounds = [((pt[1]-ORIGIN[1])*RATIO[1]+ORIGIN[1], (pt[2]-ORIGIN[2])*RATIO[2]+ORIGIN[2]) for pt in [LD, RU]]
                 # TODO

xInterpol = Array{Float16, 2}(undef, Int.(floor.((size(scaledIdsc).-1).*RATIO))...)
yInterpol = Array{Float16, 2}(undef, Int.(floor.((size(scaledIdsc).-1).*RATIO))...)
@time begin
for i in 1:size(areaValues, 1)#WEIRD /2 
    j = 1
    for k in 1:size(xInterpol)[2]# zamiast 1 dać wartość początkową (real)
        #print(i,"---",j,"---",k,'\n')
        if ceil(scaledBounds[1][2])+k > scaledIdsc[i,j][2]# previous def???
            
            j += 1
        end#!!!!!!!!!!!!!!o jedno w prawo
        #for k in #to kreotki ceil(scaledIdsc[i,j]):floor(scaledIdsc[i,j+1])
        if j == 0
            xInterpol[i, k] = areaValues[i, j]
        else
            xInterpol[i, k] = areaValues[i, j-1] + (areaValues[i, j]-areaValues[i, j-1])
            *(scaledBounds[1][2]+k-scaledIdsc[i, j-1][2])/(scaledIdsc[i,j][2]-scaledIdsc[i,j-1][2])
           #xInterpol[i, k] = areaValues[i, j-1]
        end
          
    end
end
print("First")
for j in 1:Int(floor(size(xInterpol, 2)/1))

for k in 1:size(xInterpol, 1)
    i = 1
    if ceil(scaledBounds[2][1])+k > scaledIdsc[i,1][1]# previous def???
     #   print("Dupa")
        i += 1
    end#!!!!!!!!!!!!!!o jedno w prawo
    #for k in #to kreotki ceil(scaledIdsc[i,j]):floor(scaledIdsc[i,j+1])
    if i == 1
        yInterpol[k, j] = xInterpol[i, j]
    else
        yInterpol[k, j] = xInterpol[i-1, j] + (xInterpol[i, j]-xInterpol[i-1, j])
        *(scaledBounds[2][1]+k - scaledIdsc[i-1, 1][1])/(scaledIdsc[i,1][1] - scaledIdsc[i-1,1][1])
       #xInterpol[i, k] = areaValues[i, j-1]
    end
end
end

    
end


Gray.(Float32.(yInterpol))|>display
yInterpol|>display