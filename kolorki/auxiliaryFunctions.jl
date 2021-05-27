#TO DO: DOCSTRINGS? @Kinga

#auxiliary functions

"""
Get maximum, middle and minimum values of each color.

# Arguments

- `rgb`::Array{Array{Float64,2},1}`: r, g, b matrices tuple
"""
function getValues(rgb)

    r,g,b = rgb
    Cmax = max.(r,g,b)
    Cmin = min.(r,g,b)
    sum = r .+ g .+ b
    middleValue = sum .- Cmax .- Cmin
    return [Cmax, middleValue, Cmin]
end

#doc?
function setValuesLighten(rgb, newHighValue, newMiddleValue, newLowValue) #wersja do rozjaśniania
    r,g,b = rgb
    arraySize = size(r)
    
    newRed = zeros(Float64,arraySize[1],arraySize[2])
    newGreen = zeros(Float64,arraySize[1],arraySize[2])
    newBlue = zeros(Float64,arraySize[1],arraySize[2])
    
    Cmax = max.(r,g,b)
    Cmin = min.(r,g,b)
    
    for i in 1:arraySize[1], j in 1:arraySize[2]
        
        if Cmax[i,j] == 1 && Cmin[i,j] == 1
            newRed[i,j] = r[i,j]
            newGreen[i,j] = g[i,j]
            newBlue[i,j] = b[i,j]
        else
            if Cmax[i,j] == r[i,j]
                newRed[i,j] = newHighValue[i,j]
                if Cmin[i,j] == g[i,j]
                    newGreen[i,j] = newLowValue[i,j]
                    newBlue[i,j] = newMiddleValue[i,j]
                else
                    newBlue[i,j] = newLowValue[i,j]
                    newGreen[i,j] = newMiddleValue[i,j]    
                end
        
            elseif Cmax[i,j] == g[i,j]
                newGreen[i,j] = newHighValue[i,j]
                if Cmin[i,j] == r[i,j]
                    newRed[i,j] = newLowValue[i,j]
                    newBlue[i,j] = newMiddleValue[i,j]
                else
                    newBlue[i,j] = newLowValue[i,j]
                    newRed[i,j] = newMiddleValue[i,j]  
                end

            else
                newBlue[i,j] = newHighValue[i,j]
                if Cmin[i,j] == g[i,j]
                    newGreen[i,j] = newLowValue[i,j]
                    newRed[i,j] = newMiddleValue[i,j]
                else
                    newRed[i,j] = newLowValue[i,j]
                    newGreen[i,j] = newMiddleValue[i,j]  
                end
            end 
        end
    end   
    return [newRed, newGreen, newBlue]
end

#doc?
function setValuesSaturation(rgb, newHighValue, newMiddleValue, newLowValue)
    r,g,b = rgb
    arraySize = size(r)
    
    newRed = zeros(Float64,arraySize[1],arraySize[2])
    newGreen = zeros(Float64,arraySize[1],arraySize[2])
    newBlue = zeros(Float64,arraySize[1],arraySize[2])
    
    Cmax = max.(r,g,b)
    Cmin = min.(r,g,b)
    
    for i in 1:arraySize[1], j in 1:arraySize[2]
        
        if Cmax[i,j] == Cmin[i,j]
            newRed[i,j] = r[i,j]
            newGreen[i,j] = g[i,j]
            newBlue[i,j] = b[i,j]
        else
            if Cmax[i,j] == r[i,j]
                newRed[i,j] = newHighValue[i,j]
                if Cmin[i,j] == g[i,j]
                    newGreen[i,j] = newLowValue[i,j]
                    newBlue[i,j] = newMiddleValue[i,j]
                else
                    newBlue[i,j] = newLowValue[i,j]
                    newGreen[i,j] = newMiddleValue[i,j]    
                end
        
            elseif Cmax[i,j] == g[i,j]
                newGreen[i,j] = newHighValue[i,j]
                if Cmin[i,j] == r[i,j]
                    newRed[i,j] = newLowValue[i,j]
                    newBlue[i,j] = newMiddleValue[i,j]
                else
                    newBlue[i,j] = newLowValue[i,j]
                    newRed[i,j] = newMiddleValue[i,j]  
                end

            else
                newBlue[i,j] = newHighValue[i,j]
                if Cmin[i,j] == g[i,j]
                    newGreen[i,j] = newLowValue[i,j]
                    newRed[i,j] = newMiddleValue[i,j]
                else
                    newRed[i,j] = newLowValue[i,j]
                    newGreen[i,j] = newMiddleValue[i,j]  
                end
            end 
        end
    end   
    return [newRed, newGreen, newBlue]
end