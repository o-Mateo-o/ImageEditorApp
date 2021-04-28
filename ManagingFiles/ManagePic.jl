#ManagePic.jl
module ManagePic

using FileIO, Images, ImageShow

export generate_matrices_RGB, save_pictures

<<<<<<< HEAD
function generate_matrices_RGB(filename)
    img = load(filename)
    global r = (Float64.(red.(img)))
    global g = (Float64.(green.(img)))
    global b = (Float64.(blue.(img)))
=======
function RGBconv(filename)
    img = FileIO.load(filename)
    r = (Float64.(red.(img)))
    g = (Float64.(green.(img)))
    b = (Float64.(blue.(img)))
>>>>>>> 9fb52ec19a380fde8df1830c90b2bf56cca4e1f4
    
end #RGB

<<<<<<< HEAD
function save_pictures(new_filename, r, g, b)
=======
function savefile(filename, r, g, b)
>>>>>>> 9fb52ec19a380fde8df1830c90b2bf56cca4e1f4
    aa = ([RGB(r[i,j],g[i, j],b[i,j]) for i in 1:size(r)[1], j in 1:size(r)[2] ]) #z powrotem do RGB
    save(new_filename, aa)
end #save

function generate_matrices_HSL(filename)
    #wzory needed, będzie działało jak RGB
end #HSL


end #ManagePic