include("ManagePic.jl")

using .ManagePic

function mirror(RGB, ax)
    if ax == :x 
        dim = 1 
    elseif ax == :y 
        dim = 2 
    newRGB = reverse.(RGB, dims=dim)
    return newRGB 

    