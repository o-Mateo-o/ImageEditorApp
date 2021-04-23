
module ManagePic

using FileIO, Images

export RGB

function RGB(filename)
    img = FileIO.load(filename)
    r = (Float64.(red.(img)))
    g = (Float64.(green.(img)))
    b = (Float64.(blue.(img)))
    
    return [r, g, b]
end #RGB

function save()
end

function HSL()
end
end #ManagePic