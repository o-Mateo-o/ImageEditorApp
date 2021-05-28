#####################
# auxiliary functions
#####################

"""
Function which calculate value of new pixel.

# Arguments
- `copied`::Array{Float, 2}` full-size matrix of one color.
- `mask`: mask used in transition
*param x: first coordinate of left-upper corner of copied
*param y: second coordinate of left-upper corner of copied

*Return new value of a pixel.
"""
function layingMask(copied, mask, x,y)
    dimM = size(mask)
    return sum(copied[x:x+dimM[2]-1, y:y+dimM[1]-1].*mask)/sum(mask)
end


function minimumValue(copied, mask, x,y)
    """
    Function which calculate value of new pixel.
    *Return new value of a pixel.
    *param copied: copy of an R or G or B 
    *param mask: mask used in transition
    *param x: first coordinate of left-upper corner of copied
    *param y: second coordinate of left-upper corner of copied
    
    """
    dimM = size(mask)
    return minimum(copied[x:x+dimM[2]-1, y:y+dimM[1]-1])
end


function maximumValue(copied, mask, x,y)
    """
    Function which calculate value of new pixel.
    *Return new value of a pixel.
    *param copied: copy of an R or G or B 
    *param mask: mask used in transition
    *param x: first coordinate of left-upper corner of copied
    *param y: second coordinate of left-upper corner of copied
    
    """
    dimM = size(mask)
    return maximum(copied[x:x+dimM[2]-1, y:y+dimM[1]-1])
end


function converting(picture, typeofmask)
    """
    Function which convert a given picture with mask. At first it copies every RGB matrix and reproduces extreme pixels.
    Then it creates new matrix filled with values calculated in layingMask function.
    
    *Return list consisted of of new R G and B values.
    
    *param picture: tuple of R G and B matrices of a picture which is supposed to be converted
    *param typeofmask: mask which is a result of typeofmask function
    
    """
    mask = typeofmask
    
    dimR = size(picture[1])
    dimM = size(mask)

    R = copy(picture[1])
    G = copy(picture[2])
    B = copy(picture[3])
                
    newColorList = Array([])
    
    @simd for matrix in [R, G, B]
    
        copied = matrix
        
        
        helpHorizontal = copy(copied[1,:])    #kolumna o długości równej liczbie kolumn(długości wiersza) macierzy koloru

        for n in 1:((dimM[1]-1)/2)
            copied = [helpHorizontal';copied;helpHorizontal']    #dodaję wiersze z zerami na górze i na dole ((i-1)/2) razy
        end #dodawanie wierszy                                   #transpozycja zamienia mi kolumnę na wiersz


        helpVertical = copy(copied[:,1])  #kolumna długości równej liczbie wierszy (długości kolumny) macierzy
                                                                 #sopiowanej po przejściu przez pierwszą pętlę

        for i in 1:((dimM[2]-1)/2)
            copied = [helpVertical  copied  helpVertical]  #dodaję kolumny z zerami z lewej i prawej ((j-1)/2) razy
        end #dodawanie kolumn
        
        dimC = size(copied)

        newPixelValues = Array{Float64}(undef, dimR[1], dimR[2])  #rezerwuję miejsce w pamięci
        
        
        matrix = collect(layingMask(copied, mask, x,y) for x in 1:Int64(dimC[1] - dimM[1] + 1 ), y in 1:Int64(dimC[2] - dimM[2] + 1))
        
        push!(newColorList,matrix)
        
    end #przejście w pętli po skokpiowanych macierzach kolorów 
        #mam już 3 zmienione macierze
    
    
    return newColorList
end #fucntion


######################
#Filtry dolnoprzepustowe
######################

function average(dim)
    """
    Function which generate mask to blur the picture.
    *Return mask filled with 1.
    *param dim: Int64 length of side of a mask 
    """
    mask = ones(Float64,dim, dim)
    return mask
end


function circle(dim)
    """
    Function which generate mask to blur the picture.
    *Return mask filled with 1 and zero in the centre.
    *param dim: Int64 length of side of a mask 
    """
    mask = ones(Float64,dim, dim)
    mask[1,1] = mask[1,dim] = mask[dim,1] = mask[dim,dim] = 0
    return mask
end


function LP3(dim, k)
    """
    Function which generate mask to blur the picture.
    *Return mask filled with 1 and one other value in the middle.
    *param dim: Int64 length of side of a mask 
    *param k: Int64 value of central pixel
    """
    mask = ones(Float64,dim, dim)
    mask[Int64((dim-1)/2 +1),Int64((dim-1)/2 +1)] = k
    return mask
end

######################
#Filtry górnoprzepustowe
######################


function meanRemoval(dim,k)
    """
    Function which generate mask to sharpen a picture.
    *Return mask filled with -1 and one other value in the middle.
    *param dim: Int64 length of side of a mask 
    *param k: Int64 value of central pixel
    """
    mask = -1(ones(Float64,dim, dim))
    mask[Int64((dim-1)/2 +1),Int64((dim-1)/2 +1)] = k
    return mask
end


function HP1(dim,k)
    """
    Function which generate mask to sharpen a picture.
    *Return mask filled with -1, 0 in corners and one other value in the middle.
    *param dim: Int64 length of side of a mask 
    *param k: Int64 value of central pixel
    """
    mask = -1(ones(Float64,dim, dim))
    mask[1,1] = mask[1,dim] = mask[dim,1] = mask[dim,dim] = 0
    mask[Int64((dim-1)/2 +1),Int64((dim-1)/2 +1)] = k
    return mask
end

#HP2?
function HP2(dim,k)
    """
   Function which generate mask to sharpen a picture.
   *Return mask filled with -2, 1 in corners and one other value in the middle.
   *param dim: Int64 length of side of a mask 
   *param k: Int64 value of central pixel
   """
   mask = -2(ones(Float64,dim, dim))
   mask[1,1] = mask[1,dim] = mask[dim,1] = mask[dim,dim] = 1
   mask[Int64((dim-1)/2 +1),Int64((dim-1)/2 +1)] = k
   return mask
end


#####
# WYKRYWANIE KRAWĘDZI
#####

function detectingEdges(dim,direction)
    """
   Function which generate mask to detect edges on the picture.
   *Return mask depending on the value of parameter direction.
   *param dim: Int64 length of side of a mask 
   *param direction: abbreviation of the name of direction.
                     "h" horizontal edges
                     "v" vertical edges
                     "d" diagonal edges
   """
   mask = (zeros(Float64,dim, dim))
   mask[Int64((dim-1)/2 +1),Int64((dim-1)/2 +1)] = 1
   
   if direction == "h"
       mask[1,Int64((dim-1)/2 +1)] = -1
   elseif direction == "v"
       mask[Int64((dim-1)/2 +1),1] = -1
   elseif direction == "d"
       mask[1,1] = -1
   end
   
   return mask
   
end


function mini(picture, dimension)
    
    """
    Function which convert a given picture with mask. At first it copies every RGB matrix and reproduces extreme pixels.
    Then it creates new matrix filled with values calculated in minimumValue function.
    
    *Return list consisted of of new R G and B values.
    
    *param picture: tuple of R G and B matrices of a picture which is supposed to be converted
    *param dimension: Int64 length of side of a mask
    
    """
    
    dimR = size(picture[1])
    dimM = dimension
    mask = zeros(dimM,dimM)
    R = copy(picture[1])
    G = copy(picture[2])
    B = copy(picture[3])
                
    newColorList = Array([])
    
    @simd for matrix in [R, G, B]
    
        copied = matrix
        
        
        helpHorizontal = copy(copied[1,:])    #kolumna o długości równej liczbie kolumn(długości wiersza) macierzy koloru

        for n in 1:((dimM-1)/2)
            copied = [helpHorizontal';copied;helpHorizontal']    #dodaję wiersze z zerami na górze i na dole ((i-1)/2) razy
        end #dodawanie wierszy                                   #transpozycja zamienia mi kolumnę na wiersz


        helpVertical = copy(copied[:,1])  #kolumna długości równej liczbie wierszy (długości kolumny) macierzy
                                                                 #sopiowanej po przejściu przez pierwszą pętlę

        for i in 1:((dimM-1)/2)
            copied = [helpVertical  copied  helpVertical]  #dodaję kolumny z zerami z lewej i prawej ((j-1)/2) razy
        end #dodawanie kolumn
        
        dimC = size(copied)

        newPixelValues = Array{Float64}(undef, dimR[1], dimR[2])  #rezerwuję miejsce w pamięci
        
        
        matrix = collect(minimumValue(copied, mask, x,y) for x in 1:Int64(dimC[1] - dimM + 1 ), y in 1:Int64(dimC[2] - dimM + 1))
        
        push!(newColorList,matrix)
        
    end #przejście w pętli po skokpiowanych macierzach kolorów 
        #mam już 3 zmienione macierze
    
    
    return newColorList
end #fucntion


function maxi(picture, dimension)
    
    """
    Function which convert a given picture with mask. At first it copies every RGB matrix and reproduces extreme pixels.
    Then it creates new matrix filled with values calculated in maximumValue function.
    
    *Return list consisted of of new R G and B values.
    
    *param picture: tuple of R G and B matrices of a picture which is supposed to be converted
    *param dimension: Int64 length of side of a mask
    
    """
    
    
    dimR = size(picture[1])
    dimM = dimension
    mask = zeros(dimM,dimM)
    R = copy(picture[1])
    G = copy(picture[2])
    B = copy(picture[3])
                
    newColorList = Array([])
    
    @simd for matrix in [R, G, B]
    
        copied = matrix
        
        
        helpHorizontal = copy(copied[1,:])    #kolumna o długości równej liczbie kolumn(długości wiersza) macierzy koloru

        for n in 1:((dimM-1)/2)
            copied = [helpHorizontal';copied;helpHorizontal']    #dodaję wiersze z zerami na górze i na dole ((i-1)/2) razy
        end #dodawanie wierszy                                   #transpozycja zamienia mi kolumnę na wiersz


        helpVertical = copy(copied[:,1])  #kolumna długości równej liczbie wierszy (długości kolumny) macierzy
                                                                 #sopiowanej po przejściu przez pierwszą pętlę

        for i in 1:((dimM-1)/2)
            copied = [helpVertical  copied  helpVertical]  #dodaję kolumny z zerami z lewej i prawej ((j-1)/2) razy
        end #dodawanie kolumn
        
        dimC = size(copied)

        newPixelValues = Array{Float64}(undef, dimR[1], dimR[2])  #rezerwuję miejsce w pamięci
        
        
        matrix = collect(maximumValue(copied, mask, x,y) for x in 1:Int64(dimC[1] - dimM + 1 ), y in 1:Int64(dimC[2] - dimM + 1))
        
        push!(newColorList,matrix)
        
    end #przejście w pętli po skokpiowanych macierzach kolorów 
        #mam już 3 zmienione macierze
    
    
    return newColorList
end #fucntion


function whatIfJustBlue(picture, typeofmask)
    """
    Function which convert blue matrice of a given picture with mask. At first it copies every RGB matrix and reproduces extreme pixels.
    Then it creates new matrix filled with values calculated in layingMask function.
    
    *Return list consisted of of R G and new B values.
    
    *param picture: tuple of R G and B matrices of a picture which is supposed to be converted
    *param typeofmask: mask which is a result of typeofmask function
    
    """
    mask = typeofmask
    
    dimR = size(picture[1])
    dimM = size(mask)

    R = copy(picture[1])
    G = copy(picture[2])
    B = copy(picture[3])
                
    newColorList = [R,G]
    
    copied = B
      
    
    
    helpHorizontal = copy(copied[1,:])    #kolumna o długości równej liczbie kolumn(długości wiersza) macierzy koloru

    for n in 1:((dimM[1]-1)/2)
        copied = [helpHorizontal';copied;helpHorizontal']    #dodaję wiersze z zerami na górze i na dole ((i-1)/2) razy
    end #dodawanie wierszy                                   #transpozycja zamienia mi kolumnę na wiersz


    helpVertical = copy(copied[:,1])  #kolumna długości równej liczbie wierszy (długości kolumny) macierzy
                                                                 #sopiowanej po przejściu przez pierwszą pętlę

    for i in 1:((dimM[2]-1)/2)
        copied = [helpVertical  copied  helpVertical]  #dodaję kolumny z zerami z lewej i prawej ((j-1)/2) razy
    end #dodawanie kolumn
        
    
    dimC = size(copied)

    newPixelValues = Array{Float64}(undef, dimR[1], dimR[2])  #rezerwuję miejsce w pamięci
        
        
    B = collect(layingMask(copied, mask, x,y) for x in 1:Int64(dimC[1] - dimM[1] + 1 ), y in 1:Int64(dimC[2] - dimM[2] + 1))
     
    push!(newColorList,B)
    
    return newColorList
end #fucntion