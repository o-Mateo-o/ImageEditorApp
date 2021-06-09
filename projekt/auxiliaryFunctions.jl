# TO DO: DOCSTRINGS? @Kinga

# auxiliary functions

"""
Get maximum, middle and minimum values of each color.

# Arguments
- `rgb::Array{Array{Float64,2},1}`: r, g, b matrices tuple
"""
function getValues(rgb)

    r, g, b = rgb
    Cmax = max.(r, g, b)
    Cmin = min.(r, g, b)
    sum = r .+ g .+ b
    middleValue = sum .- Cmax .- Cmin
    return [Cmax, middleValue, Cmin]
end