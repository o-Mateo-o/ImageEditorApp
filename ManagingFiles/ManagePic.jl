#ManagePic.jl
module ManagePic

using FileIO, Images, ImageShow

export generate_matrices_RGB, save_pictures

function generate_matrices_RGB(filename)
    img = load(filename)
    global r = (Float64.(red.(img)))
    global g = (Float64.(green.(img)))
    global b = (Float64.(blue.(img)))
    
end #RGB

function save_pictures(new_filename, r, g, b)
    aa = ([RGB(r[i,j],g[i, j],b[i,j]) for i in 1:size(r)[1], j in 1:size(r)[2] ]) #z powrotem do RGB
    save(new_filename, aa)
end #save

function generate_matrices_HSL(filename)
    #wzory needed, będzie działało jak RGB
end #HSL


end #ManagePic