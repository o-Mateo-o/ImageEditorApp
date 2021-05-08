using FileIO, Images, ImageShow

function generate_matrices_RGB(filename)
    img = load(filename)
    r = (Float64.(red.(img)))
    g = (Float64.(green.(img)))
    b = (Float64.(blue.(img)))
    return(r,g,b)
end #RGB

function matriceRGB(r,g,b)
    return ([RGB(r[i,j],g[i,j],b[i,j]) for i in 1:size(r)[1], j in 1:size(r)[2]])
end

img = load("HARRYPOTTER.png")

picture = generate_matrices_RGB("HARRYPOTTER.png")

function converting(filename,mask)
    
    
    picture = generate_matrices_RGB(filename)
    
    dimR = size(picture[1])
    dimM = size(mask)

    R = copy(picture[1])
    G = copy(picture[2])
    B = copy(picture[3])
                
    newColorList = Array([])
    
    for matrix in [R, G, B]
    
        copied = copy(matrix)
        
        
        helpHorizontal = zeros(Float64,dimR[2])    #kolumna o długości równej liczbie kolumn(długości wiersza) macierzy koloru

        for n in 1:((dimM[1]-1)/2)
            copied = [helpHorizontal';copied;helpHorizontal']    #dodaję wiersze z zerami na górze i na dole ((i-1)/2) razy
        end #dodawanie wierszy                                   #transpozycja zamienia mi kolumnę na wiersz


        helpVertical = help =zeros(Float64,size(copied)[1])  #kolumna długości równej liczbie wierszy (długości kolumny) macierzy
                                                                 #sopiowanej po przejściu przez pierwszą pętlę

        for i in 1:((dimM[2]-1)/2)
            copied = [helpVertical  copied  helpVertical]  #dodaję kolumny z zerami z lewej i prawej ((j-1)/2) razy
        end #dodawanie kolumn
        

        newPixelValues = Array{Float64}(undef, dimR[1], dimR[2])  #rezerwuję miejsce w pamięci
        
        
        
        for x in 1:Int64(dimR[1] - ((dimM[1]-1)/2 +1) ), y in 1:Int64(dimR[2] - ((dimM[2]-1)/2 +1))

            extractFromColor = copied[x:x+dimM[2]-1, y:y+dimM[1]-1]
            pixel = sum((extractFromColor.*mask))/sum(mask)

            newPixelValues[x,y] = pixel

        end #wpisywanie nowych wartości do macierzy kolorów

        matrix = newPixelValues
        
        push!(newColorList,matrix)
        
    end #przejście w pętli po skokpiowanych macierzach kolorów 
        #mam już 3 zmienione macierze
    
        newR = newColorList[1] |> display
        newG = newColorList[2] |> display
        newB = newColorList[3] |> display
        #return matrix
    matriceRGB(newR, newG, newB)
    #newB|>display
end #fucntion

mask = [1 1 1 ; 1 1 1 ; 1 1 1]

@time converting("HARRYPOTTER.png", mask) 

dimR = size(picture[1])
dimM = size(mask)
R = copy(picture[1])

#### próba zoptymalizowania pętli 

copied = copy(R)
        
        
        helpHorizontal = zeros(Float64,dimR[2])    #kolumna o długości równej liczbie kolumn(długości wiersza) macierzy koloru

        for n in 1:((dimM[1]-1)/2)
            copied = [helpHorizontal';copied;helpHorizontal']    #dodaję wiersze z zerami na górze i na dole ((i-1)/2) razy
        end #dodawanie wierszy                                   #transpozycja zamienia mi kolumnę na wiersz


        helpVertical = help =zeros(Float64,size(copied)[1])  #kolumna długości równej liczbie wierszy (długości kolumny) macierzy
                                                                 #sopiowanej po przejściu przez pierwszą pętlę

        for i in 1:((dimM[2]-1)/2)
            copied = [helpVertical  copied  helpVertical]  #dodaję kolumny z zerami z lewej i prawej ((j-1)/2) razy
        end #dodawanie kolumn
        

        newPixelValues = Array{Float64}(undef, dimR[1], dimR[2])  #rezerwuję miejsce w pamięci
        

function nakładanie_maski(copied, mask, newPixelValues, x,y)
    newPixelValues[x,y] = sum((copy(copied[x:x+dimM[2]-1, y:y+dimM[1]-1]).*mask))/sum(mask)
    return newPixelValues
end

(nakładanie_maski(copiedR, mask, newPixelValuesR, x,y) for x in 1:Int64(dimR[1] - ((dimM[1]-1)/2 +1) ), y in 1:Int64(dimR[2] - ((dimM[2]-1)/2 +1)))


