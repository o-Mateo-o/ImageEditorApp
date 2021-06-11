#####################
# auxiliary functions
#####################

"""
Calculate new value of pixel using mask.

#Arguments
- `copied::Array{Float64,2}`: copy of an color matrice.
- `mask::Array{Float64,2}`: mask used in transition.
- `x::Int64`: first coordinate of left-upper corner of copied.
- `y::Int64`: second coordinate of left-upper corner of copied.
"""
function layingMask(copied, mask, x, y)
    dimM = size(mask)
    return sum(copied[x:x + dimM[2] - 1, y:y + dimM[1] - 1] .* mask) / sum(mask)
end

"""
Assign to the pixel minimum value from surrounding ones, determined by mask.

#Arguments
- `copied::Array{Float64,2}`: copy of an color matrice.
- `mask::Array{Float64,2}`: mask used in transition.
- `x::Int64`: first coordinate of left-upper corner of copied.
- `y::Int64`: second coordinate of left-upper corner of copied.  
"""
function minimumValue(copied, mask, x, y)
    dimM = size(mask)
    return minimum(copied[x:x + dimM[2] - 1, y:y + dimM[1] - 1])
end

"""
Assign to the pixel maximum value from the surrounding ones, determined by mask.

#Arguments
- `copied::Array{Float64,2}`: copy of an color matrice .
- `mask::Array{Float64,2}`: mask used in transition.
- `x::Int64`: first coordinate of left-upper corner of copied.
- `y::Int64`: second coordinate of left-upper corner of copied.  
"""
function maximumValue(copied, mask, x, y)
    dimM = size(mask)
    return maximum(copied[x:x + dimM[2] - 1, y:y + dimM[1] - 1])
end

"""
Convert given picture with specified type of mask. 
Copy every RGB matrix and reproduce extreme pixels. 
Create new matrix with values calculated by layingMask function and return list of new R, G, B matrices.

#Arguments
- `picture::Array{Array{Float64,2},1}`: r, g, b matrices list.
- `typeofmask::Array{Float64,2}`: mask, determined by typeofmask function.
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
        
        helpHorizontalTop = copied[1,:]    # first row of matrix
        for n in 1:((dimM[1] - 1) / 2)
            copied = [helpHorizontalTop';copied] # adding upper bufor ((dimM[1]-1)/2) times
        end 

        helpHorizontalBottom = copied[end,:]    # last row of matrix
        for n in 1:((dimM[1] - 1) / 2)
            copied = [copied;helpHorizontalBottom'] # adding bottom bufor ((dimM[1]-1)/2) times
        end                             

        helpVerticalLeft = copied[:,1]  # first column of matrix 
        for i in 1:((dimM[2] - 1) / 2)
            copied = [helpVerticalLeft  copied]  # adding left bufor ((dimM[1]-1)/2) times
        end
  
        helpVerticalRight = copied[:,end]  # last column of matrix                                                       
        for i in 1:((dimM[2] - 1) / 2)
            copied = [copied  helpVerticalRight]  # adding right bufor ((dimM[2]-1)/2) times
        end
        
        dimC = size(copied)
        newPixelValues = Array{Float64}(undef, dimR[1], dimR[2])  # reserving memory
        matrix = collect(layingMask(copied, mask, x, y) for x in 1:Int64(dimC[1] - dimM[1] + 1), y in 1:Int64(dimC[2] - dimM[2] + 1))
        
        push!(newColorList, matrix)   
    end # loop for R G B matrices 
    return newColorList
end # converting


######################
# Low-pass filters
######################

"""
Generate mask to blurr the picture.

#Arguments
- `dim::Int64`: length of side of a mask.
"""
function maskAverage(dim)
    mask = ones(Float64, dim, dim)
    return mask
end

"""
Generate mask to blurr the picture.

#Arguments
- `dim::Int64`: length of side of a mask.
"""
function circle(dim)
    mask = ones(Float64, dim, dim)
    mask[1,1] = mask[1,dim] = mask[dim,1] = mask[dim,dim] = 0
    return mask
end

"""
Generate mask to blurr the picture.

#Arguments
- `dim::Int64`: length of side of a mask.
- `param k::Float64`: value of central pixel.
"""
function LP3(dim, k)
    mask = ones(Float64, dim, dim)
    mask[Int64((dim - 1) / 2 + 1),Int64((dim - 1) / 2 + 1)] = k
    return mask
end

######################
# High-pass filters
######################

"""
Generate mask to sharpen a picture.

#Arguments
- `dim::Int64`: length of side of a mask. 
- `param k:Float64`: value of central pixel.
"""
function meanRemoval(dim, k)
    mask = -1(ones(Float64, dim, dim))
    mask[Int64((dim - 1) / 2 + 1),Int64((dim - 1) / 2 + 1)] = k
    return mask
end

"""
Generate mask to sharpen a picture.

#Arguments
- `dim::Int64`: length of side of a mask. 
- `param k:Float64`: value of central pixel.
"""
function HP1(dim, k)
    mask = -1(ones(Float64, dim, dim))
    mask[1,1] = mask[1,dim] = mask[dim,1] = mask[dim,dim] = 0
    mask[Int64((dim - 1) / 2 + 1),Int64((dim - 1) / 2 + 1)] = k
    return mask
end

"""
Generate mask to sharpen a picture.

#Arguments
- `dim::Int64`: length of side of a mask. 
- `param k:Float64`: value of central pixel.
"""
function HP2(dim, k)
    mask = -2(ones(Float64, dim, dim))
    mask[1,1] = mask[1,dim] = mask[dim,1] = mask[dim,dim] = 1
    mask[Int64((dim - 1) / 2 + 1),Int64((dim - 1) / 2 + 1)] = k
    return mask
end


#####
# Edge detection
#####
"""
Generate mask to detect edges on the picture in given direction.

#Arguments
- `dim::Int64`: length of side of a mask.
- `direction::String`: abbreviation of the name of direction:
                     "h" horizontal edges,
                     "v" vertical edges,
                     "d" diagonal edges.
"""
function detectingEdges(dim, direction)
    mask = (zeros(Float64, dim, dim))
    mask[Int64((dim - 1) / 2 + 1),Int64((dim - 1) / 2 + 1)] = 1
   
    if direction == "h"
        mask[1,Int64((dim - 1) / 2 + 1)] = -1
    elseif direction == "v"
       mask[Int64((dim - 1) / 2 + 1),1] = -1
    elseif direction == "d"
       mask[1,1] = -1
    end
   
    return mask
end

"""
Convert a given picture with a mask. Copy every RGB matrix and reproduce extreme pixels.
Create new matrix filled with values calculated by minimumValue function
and return list of of new R G and B values. 

#Arguments
- `picture::Array{Array{Float64,2},1}`: r, g, b matrices list.
- `dimension::Int64`: length of side of a mask.
"""
function mini(picture, dimension)
    dimR = size(picture[1])
    dimM = dimension
    mask = zeros(dimM, dimM)
    R = copy(picture[1])
    G = copy(picture[2])
    B = copy(picture[3])          
    newColorList = Array([])
    
    @simd for matrix in [R, G, B]
        copied = matrix
        
        helpHorizontalTop = copied[1,:]    # first row of matrix
        for n in 1:((dimM - 1) / 2)
            copied = [helpHorizontalTop';copied] # adding upper bufor ((dimM[1]-1)/2) times
        end 

        helpHorizontalBottom = copied[end,:]    # last row of matrix
        for n in 1:((dimM - 1) / 2)
            copied = [copied;helpHorizontalBottom'] # adding bottom bufor ((dimM[1]-1)/2) times
        end                             

        helpVerticalLeft = copied[:,1]  # first column of matrix
        for i in 1:((dimM - 1) / 2)
            copied = [helpVerticalLeft  copied]  # adding left bufor ((dimM[1]-1)/2) times
        end
  
        helpVerticalRight = copied[:,end]  # last column of matrix                                                      
        for i in 1:((dimM - 1) / 2)
            copied = [copied  helpVerticalRight]  # adding right bufor ((dimM[2]-1)/2) times
        end
        
        dimC = size(copied)
        newPixelValues = Array{Float64}(undef, dimR[1], dimR[2])  # reserving memory
        matrix = collect(minimumValue(copied, mask, x, y) for x in 1:Int64(dimC[1] - dimM + 1), y in 1:Int64(dimC[2] - dimM + 1))
        
        push!(newColorList, matrix)
    end # loop for R G B matrices 
    return newColorList
end # mini

"""
Convert a given picture with mask. Copy every RGB matrix and reproduce extreme pixels.
Then create new matrix with values calculated by maximumValue function
and return list of new R G and B values. 

#Arguments
- `picture::Array{Array{Float64,2},1}`: r, g, b matrices list.
- `dimension::Int64`: length of a side of the mask.
"""
function maxi(picture, dimension)
    dimR = size(picture[1])
    dimM = dimension
    mask = zeros(dimM, dimM)
    R = copy(picture[1])
    G = copy(picture[2])
    B = copy(picture[3])           
    newColorList = Array([])
    
    @simd for matrix in [R, G, B]
        copied = matrix
        
        helpHorizontalTop = copied[1,:]    # first row of matrix
        for n in 1:((dimM - 1) / 2)
            copied = [helpHorizontalTop';copied] # adding upper bufor ((dimM[1]-1)/2) times
        end

        helpHorizontalBottom = copied[end,:]    # last row of matrix
        for n in 1:((dimM - 1) / 2)
            copied = [copied;helpHorizontalBottom'] # adding bottom bufor ((dimM[1]-1)/2) times
        end

        helpVerticalLeft = copied[:,1]  # first column of matrix
        for i in 1:((dimM - 1) / 2)
            copied = [helpVerticalLeft  copied]  # adding left bufor ((dimM[1]-1)/2) times
        end
  
        helpVerticalRight = copied[:,end]  # last column of matrix                                                      
        for i in 1:((dimM - 1) / 2)
            copied = [copied  helpVerticalRight] # adding right bufor ((dimM[2]-1)/2) times
        end
        
        dimC = size(copied)
        newPixelValues = Array{Float64}(undef, dimR[1], dimR[2])  # reserving memory
        matrix = collect(maximumValue(copied, mask, x, y) for x in 1:Int64(dimC[1] - dimM + 1), y in 1:Int64(dimC[2] - dimM + 1))
        
        push!(newColorList, matrix)  
    end # loop for R G B matrices 
    return newColorList
end # maxi

########
# WHATIF
########
"""
Convert blue matrice of a given picture with mask. Copy every of RGB matrices 
and reproduce extreme pixels of B matrix.
Then create new B matrix with values calculated by layingMask function 
and return list of R G and new B values.

#Arguments
- `picture::Array{Array{Float64,2},1}`: r, g, b matrices list.
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
    
    helpHorizontalTop = copied[1,:]    
    for n in 1:((dimM[1] - 1) / 2)
        copied = [helpHorizontalTop';copied]
    end

    helpHorizontalBottom = copied[end,:]
    for n in 1:((dimM[1] - 1) / 2)
        copied = [copied;helpHorizontalBottom']
    end                          

    helpVerticalLeft = copied[:,1]
    for i in 1:((dimM[2] - 1) / 2)
        copied = [helpVerticalLeft  copied]
    end
     
    helpVerticalRight = copied[:,end] 
    for i in 1:((dimM[2] - 1) / 2)
        copied = [copied  helpVerticalRight]
    end  
    
    dimC = size(copied)
    newPixelValues = Array{Float64}(undef, dimR[1], dimR[2]) # reserving memory 
    B = collect(layingMask(copied, mask, x, y) for x in 1:Int64(dimC[1] - dimM[1] + 1), y in 1:Int64(dimC[2] - dimM[2] + 1))
    push!(newColorList, B)
    
    return newColorList
end # whatIfJustBlue
