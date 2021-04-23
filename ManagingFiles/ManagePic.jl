
module ManagePic

using Images, ImageShow, FileIO 

export RGB

function RGB(filename)
    img = FileIO.load(filename)
    r = (Float64.(red.(img)))
    g = (Float64.(green.(img)))
    b = (Float64.(blue.(img)))
    
    return [r, g, b]
end #RGB

function save(filename, r, g, b)
    aa = ([RGB(r[i,j],g[i, j],b[i,j]) for i in 1:size(r)[1], j in 1:size(r)[2] ]) #z powrotem do RGB
    save(filename,aa)
end

function HSL()
end
end #ManagePic