#####################
# auxiliary functions
#####################

"""
Calculate value of new pixel using mask.

#Arguments
- `copied::Array{Float64,2}`: copy of an R or G or B .
- `mask::Array{Float64,2}`: mask used in transition.
- `x::Int64`: first coordinate of left-upper corner of copied.
- `y::Int64`: second coordinate of left-upper corner of copied.
"""
function layingMask(copied, mask, x,y)
    dimM = size(mask)
    return sum(copied[x:x+dimM[2]-1, y:y+dimM[1]-1].*mask)/sum(mask)
end

"""
Assign to pixel minimum value from the surrounding determined by mask.

#Arguments
- `copied::Array{Float64,2}`: copy of an R or G or B .
- `mask::Array{Float64,2}`: mask used in transition.
- `x::Int64`: first coordinate of left-upper corner of copied.
- `y::Int64`: second coordinate of left-upper corner of copied.  
"""
function minimumValue(copied, mask, x,y)
    dimM = size(mask)
    return minimum(copied[x:x+dimM[2]-1, y:y+dimM[1]-1])
end

"""
Assign to pixel maximum value from the surrounding determined by mask.

#Arguments
- `copied::Array{Float64,2}`: copy of an R or G or B .
- `mask::Array{Float64,2}`: mask used in transition.
- `x::Int64`: first coordinate of left-upper corner of copied.
- `y::Int64`: second coordinate of left-upper corner of copied.  
"""
function maximumValue(copied, mask, x,y)
    dimM = size(mask)
    return maximum(copied[x:x+dimM[2]-1, y:y+dimM[1]-1])
end

"""
Convert a given picture with mask. At first copy every RGB matrix and reproduce extreme pixels.
Then create new matrix filled with values calculated in layingMask function 
and return list consisted of of new R G and B values.

#Arguments
- `picture::Tuple{Array{Float64,2},Array{Float64,2},Array{Float64,2}}`: tuple of R G and B matrices of a picture
   which is supposed to be converted.
- `typeofmask::Array{Float64,2}`: mask which is a result of typeofmask function.
"""
function converting(picture, typeofmask)
    mask = typeofmask
    
    dimR = size(picture[1])
    dimM = size(mask)

    R = copy(picture[1])
    G = copy(picture[2])
    B = copy(picture[3])
                
    newColorList = Array([])
    
    @simd for matrix in [R, G, B]
    
        copied = matrix
        
        
        helpHorizontalTop = copied[1,:]    #first row of matrix

        for n in 1:((dimM[1]-1)/2)
            copied = [helpHorizontalTop';copied] #adding at the begining of matrix first row of matrix ((dimM[1]-1)/2) times
        end #adding rows                                   #transposition transforms column into row

        
        
        helpHorizontalBottom = copied[end,:]    #last row of matrix

        for n in 1:((dimM[1]-1)/2)
            copied = [copied;helpHorizontalBottom'] #adding at the end of matrix last row of matrix ((dimM[1]-1)/2) times
        end #adding rows                            

        
        
        helpVerticalLeft = copied[:,1]  #first column of matrix transformed by for loops above
        for i in 1:((dimM[2]-1)/2)
            copied = [helpVerticalLeft  copied]  #adding at the left side of matrix first column of matrix ((dimM[1]-1)/2) times
        end #adding columns
  
        
        
        helpVerticalRight = copied[:,end]  #last column of matrix transformed by for loops above
                                                                 
        for i in 1:((dimM[2]-1)/2)
            copied = [copied  helpVerticalRight]  #adding at the right side of matrix last column of matrix ((dimM[2]-1)/2) times
        end #adding columns
        
        
        dimC = size(copied)

        newPixelValues = Array{Float64}(undef, dimR[1], dimR[2])  #reserving memory
        
        
        matrix = collect(layingMask(copied, mask, x,y) for x in 1:Int64(dimC[1] - dimM[1] + 1 ), y in 1:Int64(dimC[2] - dimM[2] + 1))
        
        push!(newColorList,matrix)
        
    end #loop for R G B matrices 

    
    return newColorList
end #function


######################
#Filtry dolnoprzepustowe
######################
"""
Generate mask to blur the picture.

#Arguments
- `dim::Int64`: length of side of a mask.
"""
function average(dim)
    mask = ones(Float64,dim, dim)
    return mask
end

"""
Generate mask to blur the picture.

#Arguments
- `dim::Int64`: length of side of a mask.
"""
function circle(dim)
    mask = ones(Float64,dim, dim)
    mask[1,1] = mask[1,dim] = mask[dim,1] = mask[dim,dim] = 0
    return mask
end

"""
Generate mask to blur the picture.

#Arguments
- `dim::Int64`: length of side of a mask.
- `param k::Float64`: value of central pixel.
"""
function LP3(dim, k)
    mask = ones(Float64,dim, dim)
    mask[Int64((dim-1)/2 +1),Int64((dim-1)/2 +1)] = k
    return mask
end

######################
#Filtry górnoprzepustowe
######################

"""
Generate mask to sharpen a picture.

#Arguments
- `dim::Int64`: length of side of a mask. 
- `param k:Float64`: value of central pixel.
"""
function meanRemoval(dim,k)
    mask = -1(ones(Float64,dim, dim))
    mask[Int64((dim-1)/2 +1),Int64((dim-1)/2 +1)] = k
    return mask
end

"""
Generate mask to sharpen a picture.

#Arguments
- `dim::Int64`: length of side of a mask. 
- `param k:Float64`: value of central pixel.
"""
function HP1(dim,k)
    mask = -1(ones(Float64,dim, dim))
    mask[1,1] = mask[1,dim] = mask[dim,1] = mask[dim,dim] = 0
    mask[Int64((dim-1)/2 +1),Int64((dim-1)/2 +1)] = k
    return mask
end

"""
Generate mask to sharpen a picture.

#Arguments
- `dim::Int64`: length of side of a mask. 
- `param k:Float64`: value of central pixel.
"""
#HP2?
function HP2(dim,k)
   mask = -2(ones(Float64,dim, dim))
   mask[1,1] = mask[1,dim] = mask[dim,1] = mask[dim,dim] = 1
   mask[Int64((dim-1)/2 +1),Int64((dim-1)/2 +1)] = k
   return mask
end


#####
# WYKRYWANIE KRAWĘDZI
#####
"""
Generate mask to detect edges on the picture in a given direction.

#Arguments
- `dim::Int64`: length of side of a mask.
- `direction::String`: abbreviation of the name of direction:
                     "h" horizontal edges,
                     "v" vertical edges,
                     "d" diagonal edges.
"""
function detectingEdges(dim,direction)
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

"""
Convert a given picture with mask. At first it copy every RGB matrix and reproduce extreme pixels.
Then create new matrix filled with values calculated in minimumValue function
and return list consisted of of new R G and B values. 

#Arguments
- `picture::`: tuple of R G and B matrices of a picture which is supposed to be converted.
- `dimension::Int64`: length of side of a mask
"""
function mini(picture, dimension)
    dimR = size(picture[1])
    dimM = dimension
    mask = zeros(dimM,dimM)
    R = copy(picture[1])
    G = copy(picture[2])
    B = copy(picture[3])
                
    newColorList = Array([])
    
    @simd for matrix in [R, G, B]
    
        copied = matrix
        
        
        helpHorizontalTop = copied[1,:]    #first row of matrix

        for n in 1:((dimM-1)/2)
            copied = [helpHorizontalTop';copied] #adding at the begining of matrix first row of matrix ((dimM[1]-1)/2) times
        end #adding rows                                   #transposition transforms column into row

        
        
        helpHorizontalBottom = copied[end,:]    #last row of matrix

        for n in 1:((dimM-1)/2)
            copied = [copied;helpHorizontalBottom'] #adding at the end of matrix last row of matrix ((dimM[1]-1)/2) times
        end #adding rows                            

        
        
        helpVerticalLeft = copied[:,1]  #first column of matrix transformed by for loops above
        for i in 1:((dimM-1)/2)
            copied = [helpVerticalLeft  copied]  #adding at the left side of matrix first column of matrix ((dimM[1]-1)/2) times
        end #adding columns
  
        
        
        helpVerticalRight = copied[:,end]  #last column of matrix transformed by for loops above
                                                                 
        for i in 1:((dimM-1)/2)
            copied = [copied  helpVerticalRight]  #adding at the right side of matrix last column of matrix ((dimM[2]-1)/2) times
        end #adding columns
        
        dimC = size(copied)

        newPixelValues = Array{Float64}(undef, dimR[1], dimR[2])  #reserving memory
        
        
        matrix = collect(minimumValue(copied, mask, x,y) for x in 1:Int64(dimC[1] - dimM + 1 ), y in 1:Int64(dimC[2] - dimM + 1))
        
        push!(newColorList,matrix)
        
    end #loop for R G B matrices 
    
    
    return newColorList
end #function

"""
Convert a given picture with mask. At first it copy every RGB matrix and reproduce extreme pixels.
Then create new matrix filled with values calculated in maximumValue function
and return list consisted of of new R G and B values. 

#Arguments
- `picture::Tuple{Array{Float64,2},Array{Float64,2},Array{Float64,2}}`: tuple of R G and B matrices of a picture 
   which is supposed to be converted.
- `dimension::Int64`: length of side of a mask
"""
function maxi(picture, dimension)
    dimR = size(picture[1])
    dimM = dimension
    mask = zeros(dimM,dimM)
    R = copy(picture[1])
    G = copy(picture[2])
    B = copy(picture[3])
                
    newColorList = Array([])
    
    @simd for matrix in [R, G, B]
    
        copied = matrix
        
        
        helpHorizontalTop = copied[1,:]    #first row of matrix

        for n in 1:((dimM-1)/2)
            copied = [helpHorizontalTop';copied] #adding at the begining of matrix first row of matrix ((dimM[1]-1)/2) times
        end #adding rows                                   #transposition transforms column into row

        
        
        helpHorizontalBottom = copied[end,:]    #last row of matrix

        for n in 1:((dimM-1)/2)
            copied = [copied;helpHorizontalBottom'] #adding at the end of matrix last row of matrix ((dimM[1]-1)/2) times
        end #adding rows                            

        
        
        helpVerticalLeft = copied[:,1]  #first column of matrix transformed by for loops above
        for i in 1:((dimM-1)/2)
            copied = [helpVerticalLeft  copied]  #adding at the left side of matrix first column of matrix ((dimM[1]-1)/2) times
        end #adding columns
  
        
        
        
        helpVerticalRight = copied[:,end]  #last column of matrix transformed by for loops above
                                                                 
        for i in 1:((dimM-1)/2)
            copied = [copied  helpVerticalRight]  #adding at the right side of matrix last column of matrix ((dimM[2]-1)/2) times
        end #adding columns
        
        
        dimC = size(copied)

        newPixelValues = Array{Float64}(undef, dimR[1], dimR[2])  #reserving memory
        
        
        matrix = collect(maximumValue(copied, mask, x,y) for x in 1:Int64(dimC[1] - dimM + 1 ), y in 1:Int64(dimC[2] - dimM + 1))
        
        push!(newColorList,matrix)
        
    end #loop for R G B matrices 
    
    
    return newColorList
end #function

"""
Convert blue matrice of a given picture with mask. At first copy every of RGB matrices 
and reproduce extreme pixels of B matrix.
Then create new B matrix filled with values calculated in layingMask function 
and return list consisted of of R G and new B values.

#Arguments
- `picture::Tuple{Array{Float64,2},Array{Float64,2},Array{Float64,2}}`: tuple of R G and B matrices of a picture 
   which is supposed to be converted.
- `typeofmask::Array{Float64,2}`: mask which is a result of typeofmask function.
"""
function whatIfJustBlue(picture, typeofmask)
    mask = typeofmask
    
    dimR = size(picture[1])
    dimM = size(mask)

    R = copy(picture[1])
    G = copy(picture[2])
    B = copy(picture[3])
                
    newColorList = [R,G]
    
    copied = B
      
    
    
    helpHorizontalTop = copied[1,:]    #first row of matrix

        for n in 1:((dimM[1]-1)/2)
            copied = [helpHorizontalTop';copied] #adding at the begining of matrix first row of matrix ((dimM[1]-1)/2) times
        end #adding rows                                   #transposition transforms column into row

        
        
        helpHorizontalBottom = copied[end,:]    #last row of matrix

        for n in 1:((dimM[1]-1)/2)
            copied = [copied;helpHorizontalBottom'] #adding at the end of matrix last row of matrix ((dimM[1]-1)/2) times
        end #adding rows                            

        
        
        helpVerticalLeft = copied[:,1]  #first column of matrix transformed by for loops above
        for i in 1:((dimM[2]-1)/2)
            copied = [helpVerticalLeft  copied]  #adding at the left side of matrix first column of matrix ((dimM[1]-1)/2) times
        end #adding columns
  
        
        
        
        helpVerticalRight = copied[:,end]  #last column of matrix transformed by for loops above
                                                                 
        for i in 1:((dimM[2]-1)/2)
            copied = [copied  helpVerticalRight]  #adding at the right side of matrix last column of matrix ((dimM[2]-1)/2) times
        end #adding columns
        
    
    dimC = size(copied)

    newPixelValues = Array{Float64}(undef, dimR[1], dimR[2]) #reserving memory
        
        
    B = collect(layingMask(copied, mask, x,y) for x in 1:Int64(dimC[1] - dimM[1] + 1 ), y in 1:Int64(dimC[2] - dimM[2] + 1))
     
    push!(newColorList,B)
    
    return newColorList
end #function