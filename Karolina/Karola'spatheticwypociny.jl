using Images

include(raw"C:\Users\Asus\Desktop\hożo\grafika-pakiety\ManagingFiles\ManagePic.jl")

function converting(RGB)
    
    #R-macierz koloru czerwonego
    #G-macierz koloru zielonego
    #B-macierz koloru niebieskiego
    
    #M-macierz maski
    
    #i- liczba wierszy maski
    #j- liczba kolumn maski
    
    size = size[R]
    
    for matrix in RGB
        
        help =zeros(Float64,size[2])   #kolumna o długości równej liczbie kolumn(długości wiersza)
        copied = copy(matrix)
        
        for n in 1:((i-1)/2)
            copied = [help';matrix;help']    #dodaję wiersze z zerami na górze i na dole ((i-1)/2) razy
        
        help_again = help =zeros(Float64,size(copied)[1])  #kolumna długości równej liczbie wierszy (długości kolumny)
        
        for i in 1:((j-1)/2)
            copied = [help again copied help_again]  #dodaję kolumny z zerami z lewej i prawej ((j-1)/2) razy
        end
            
        soon_useful = Array{Float64}(undef, size[1], size[2])
        
        for x in 1:(n + (j-1)/2 +1)), y in 1:(m + (i-1)/2 +1 )
                
                piece_to_mask = copy(copied[y:y+1, x:x+1])
                pixel = (E.*M)/sum(M)
                
                soon_useful[x,y] = pixel
                
        end
            
            matrix = soon_useful
            
    end
end
