#ManagePic.jl
module ManagePic

using FileIO, Images, ImageShow

export generateMatricesRGB, matriceRGB, savePicture, savePictureRGB


function generateMatricesRGB(filename)
    img = load(filename)
    r = (Float64.(red.(img)))
    g = (Float64.(green.(img)))
    b = (Float64.(blue.(img)))
    return(r,g,b)
end #RGB

function matriceRGB(r,g,b)
    return ([RGB(r[i,j],g[i, j],b[i,j]) for i in 1:size(r)[1], j in 1:size(r)[2] ])
end #matriceRGB

function savePicture(newFilename, r, g, b)
    aa = matriceRGB(r,g,b) #z powrotem do RGB
    save(newFilename, aa)
end #save

function savePictureRGB(newFilename, RGB)
    savePicture(newFilename, RGB[1], RGB[2], RGB[3])
end #save2

function generateMatricesHSL(filename)
    #wzory needed, będzie działało jak RGB
end #HSL


end #ManagePic