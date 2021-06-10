include("ManagePic.jl")

using Gtk, Images, ImageView

#po otworzeniu pliku jak ktoś zamknie otwieracz to error wypala





bld = GtkBuilder(filename="projekt/GUILayout.glade")
saving_path = ""
save_flag = false
undo_counter = -1


current_image = Array{RGB{Normed{UInt8,8}},2}
current_image_u = Array{RGB{Normed{UInt8,8}},2}
current_image_uu = Array{RGB{Normed{UInt8,8}},2}
function new_current_image(new_image, canvas)
    global current_image_uu = current_image_u
    global current_image_u = current_image
    global current_image = new_image
    global undo_counter += 1

    imshow(canvas, new_image)


end
function undo_image(canvas)
    if undo_counter > 0
        global current_image = current_image_u
        global current_image_u = current_image_uu
        global undo_counter -= 1
        imshow(canvas, current_image)
    else
        println("ERROR - cant undo")                                #ogarnąć
    end
    println(undo_counter)
end

rgb_choice = ""
blur_choice = ""
sharp_choice = ""
range_right_val = 0
range_left_val = 0
range_up_val = 0
range_down_val = 0 
selection_ru = (Nothing, Nothing)
selection_ld = (Nothing, Nothing)

# ELEMENTS BUILDING

#main window
mainW = bld["mainW"]
frame, cnv = ImageView.frame_canvas(:auto)
image_grid = bld["image_grid"]
image_grid[2,2] = frame

b_open = bld["b_open"]
b_save = bld["b_save"]
b_saveas = bld["b_saveas"]
b_quit = bld["b_quit"]
b_undo = bld["b_undo"]

b_brctr = bld["b_brctr"]
b_hsl = bld["b_hsl"]
b_rgb = bld["b_rgb"]
b_gray = bld["b_gray"]
b_blur = bld["b_blur"]
b_sharp = bld["b_sharp"]
b_transit = bld["b_transit"]

scale_left = bld["scale_left"]
scale_right = bld["scale_right"]
scale_up = bld["scale_up"]
scale_down = bld["scale_down"]

a_range_up = bld["a_range_up"]
a_range_down = bld["a_range_down"]
a_range_left = bld["a_range_left"]
a_range_right = bld["a_range_right"]
b_range_ok = bld["b_range_ok"]
b_range_cancel = bld["b_range_cancel"]

#brightness and conterast window
brctrW = bld["brctrW"]
b_brctr_cancel = bld["b_brctr_cancel"]
a_brightness = bld["a_brightness"]
a_contrast = bld["a_contrast"]
b_brctr_ok = bld["b_brctr_ok"]
#hue satur light window
hslW = bld["hslW"]
b_hsl_cancel = bld["b_hsl_cancel"]
a_hue = bld["a_hue"]
a_satur = bld["a_satur"]
a_light = bld["a_light"]
b_hsl_ok = bld["b_hsl_ok"]
#rgb components
rgbW = bld["rgbW"]
b_rgb_cancel = bld["b_rgb_cancel"]
rgb_sr = bld["rgb_sr"]
rgb_sg = bld["rgb_sg"]
rgb_sb = bld["rgb_sb"]
rgb_hr = bld["rgb_hr"]
rgb_hg = bld["rgb_hg"]
rgb_hb = bld["rgb_hb"]
b_rgb_ok = bld["b_rgb_ok"]
#grayscale
grayW = bld["grayW"]
b_gray_cancel = bld["b_gray_cancel"]
b_gray_ok = bld["b_gray_ok"]
#blur 
blurW = bld["blurW"]
b_blur_cancel = bld["b_blur_cancel"]
a_blur_radius_s = bld["a_blur_radius_s"]
a_blur_intens_s = bld["a_blur_intens_s"]
blur_mask_aver = bld["blur_mask_aver"]
blur_mask_circ = bld["blur_mask_circ"]
blur_mask_lp3 = bld["blur_mask_lp3"]
b_blur_ok = bld["b_blur_ok"]
#sharp 
sharpW = bld["sharpW"]
b_sharp_cancel = bld["b_sharp_cancel"]
a_sharp_radius_s = bld["a_sharp_radius_s"]
a_sharp_intens_s = bld["a_sharp_intens_s"]
sharp_mask_mean = bld["sharp_mask_mean"]
sharp_mask_hp1 = bld["sharp_mask_hp1"]
sharp_mask_hp2 = bld["sharp_mask_hp2"]
b_sharp_ok = bld["b_sharp_ok"]
#transform
transitW = bld["transitW"]
a_transl_vect_x = bld["a_transl_vect_x"]
a_transl_vect_y = bld["a_transl_vect_y"]
a_rotat_angle = bld["a_rotat_angle"]
a_scale_ratio_x = bld["a_scale_ratio_x"]
a_scale_ratio_y = bld["a_scale_ratio_y"]
b_add_transl = bld["b_add_transl"]
b_add_rotat = bld["b_add_rotat"]
b_add_scale = bld["b_add_scale"]
combo_origin = bld["combo_origin"]
b_transit_cancel = bld["b_transit_cancel"]
b_transit_ok = bld["b_transit_ok"]


"""
a = save_dialog("Save as...", mainW, ("*.jpg", GtkFileFilter("*.jpg", name="All supported formats")))
print(a)
"""

# CALLBACK FUNCTIONS
function open_fileopen(w)
    path = open_dialog("Pick an image file", GtkNullContainer(), (GtkFileFilter("*.jpg", name="All supported formats"), "*.jpg"))
    img = load(path)
    new_current_image(img, cnv)
end
function save_filesaveas(w)
    path_raw = save_dialog("Save as...", mainW, ("*.jpg", GtkFileFilter("*.jpg", name="All supported formats")))
    if path_raw[end-3:end] != ".jpg"
        global saving_path = path_raw * ".jpg"
    else
        global saving_path = path_raw
    end  
    #savefile()
    global save_flag = true
end
function save_filesave(w)
    print(save_flag)
    if save_flag == true
        #savefile()
    else
        save_filesaveas(w)
    end    
end
function quit_app(w)
    destroy(mainW)
end
function undo_clb(w)
    undo_image(cnv)
end


function brctr_open(w)
    show(brctrW)
    set_gtk_property!(a_brightness, :value, 0)
    set_gtk_property!(a_contrast, :value, 0)
end
brctr_close(w) = hide(brctrW)
function hsl_open(w)
    show(hslW)
    set_gtk_property!(a_hue, :value, 0)
    set_gtk_property!(a_satur, :value, 0)
    set_gtk_property!(a_light, :value, 0)
end
hsl_close(w) = hide(hslW)


function rgb_open(w)
    show(rgbW)
end
rgb_close(w) = hide(rgbW)
function rgb_update(w)
    if get_gtk_property(w, :active, Bool)
        global rgb_choice = w
    end
end


function gray_open(w)
    show(grayW)
end
gray_close(w) = hide(grayW)


function blur_open(w)
    show(blurW)
    if get_gtk_property(blur_mask_circ, :active, Bool)
        set_gtk_property!(a_blur_intens_s, :sensitive, false)
    end
end
blur_close(w) = hide(blurW)
function blur_update(w)
    if get_gtk_property(w, :active, Bool)
        global blur_choice = w
    end
    if w == blur_mask_circ
        set_gtk_property!(a_blur_intens_s, :sensitive, false)
    else
        set_gtk_property!(a_blur_intens_s, :sensitive, true)
    end
end


function sharp_open(w)
    show(sharpW)
end
sharp_close(w) = hide(sharpW)
function sharp_update(w)
    if get_gtk_property(w, :active, Bool)
        global sharp_choice = w
    end
end

function show_selection(image, range_left, range_right, range_up, range_down)   
    
    r = (Float64.(red.(image)))
    g = (Float64.(green.(image)))
    b = (Float64.(blue.(image)))

    img_height = size(r)[1]
    img_width = size(r)[2]

    ru = (max(Int(floor(range_up*img_height/100)),1), max(Int(floor((100-range_right)*img_width/100)),1))
    ld = (max(Int(floor((100-range_down)*img_height/100)),1), max(Int(floor(range_left*img_width/100)),1))
    
    color_matrices = [r, g, b]

    for i in 1:3
        original_matrix = copy(color_matrices[i])
       
        color_matrices[i] = original_matrix .* 0.3
        color_matrices[i][ru[1]:ld[1], ld[2]:ru[2]] = original_matrix[ru[1]:ld[1], ld[2]:ru[2]]
    end
    
    global selection_ru = ru
    global selection_ld = ld
    
    selection_image = ManagePic.matriceRGB(color_matrices...)
    println("AAA")
    imshow(cnv, selection_image)
end #RGB

function range_open(w)
    
    global range_left_val = get_gtk_property(a_range_left, :value, Int)
    global range_right_val = get_gtk_property(a_range_right, :value, Int)
    global range_up_val = get_gtk_property(a_range_up, :value, Int)
    global range_down_val = get_gtk_property(a_range_down, :value, Int)
    show_selection(current_image, range_left_val, range_right_val, range_up_val, range_down_val)

    show(scale_left)
    show(scale_right)
    show(scale_down)
    show(scale_up)
    show(b_range_cancel)
    show(b_range_ok)
end




function range_accept(w)
    show(transitW)
end

function range_close(w)
    hide(scale_left)
    hide(scale_right)
    hide(scale_down)
    hide(scale_up)
    hide(b_range_cancel)
    hide(b_range_ok)
    imshow(cnv, current_image)

end

function update_range_left(w)
    global range_left_val = get_gtk_property(w, :value, Int)
    if range_left_val + range_right_val >= 99
        set_gtk_property!(w, :value, 99-range_right_val)
    end
    show_selection(current_image, range_left_val, range_right_val, range_up_val, range_down_val)
end
function update_range_right(w)
    global range_right_val = get_gtk_property(w, :value, Int)
    if range_right_val + range_left_val >= 99
        set_gtk_property!(w, :value, 99-range_left_val)
    end
    show_selection(current_image, range_left_val, range_right_val, range_up_val, range_down_val)
end
function update_range_up(w)
    global range_up_val = get_gtk_property(w, :value, Int)
    if range_up_val + range_down_val >= 99
        set_gtk_property!(w, :value, 99-range_down_val)
    end
    show_selection(current_image, range_left_val, range_right_val, range_up_val, range_down_val)
end
function update_range_down(w)
    global range_down_val = get_gtk_property(w, :value, Int)
    if range_down_val + range_up_val >= 99
        set_gtk_property!(w, :value, 99-range_up_val)
    end
    show_selection(current_image, range_left_val, range_right_val, range_up_val, range_down_val)
end

function transit_open(w)
    show(transitW)    
end
transit_close(w) = hide(transitW)
    



# SIGNAL CONNECTING
signal_connect(open_fileopen, b_open, "activate")
signal_connect(save_filesave, b_save, "activate")
signal_connect(save_filesaveas, b_saveas, "activate")
signal_connect(quit_app, b_quit, "activate")
signal_connect(undo_clb, b_undo, "activate")

signal_connect(brctr_open, b_brctr, "clicked")
signal_connect(brctr_close, b_brctr_cancel, "clicked")

signal_connect(hsl_open, b_hsl, "clicked")
signal_connect(hsl_close, b_hsl_cancel, "clicked")

signal_connect(rgb_open, b_rgb, "clicked")
signal_connect(rgb_close, b_rgb_cancel, "clicked")
signal_connect(rgb_update, rgb_sr, "toggled")
signal_connect(rgb_update, rgb_sg, "toggled")
signal_connect(rgb_update, rgb_sb, "toggled")
signal_connect(rgb_update, rgb_hr, "toggled")
signal_connect(rgb_update, rgb_hg, "toggled")
signal_connect(rgb_update, rgb_hb, "toggled")

signal_connect(gray_open, b_gray, "clicked")
signal_connect(gray_close, b_gray_cancel, "clicked")

signal_connect(blur_open, b_blur, "clicked")
signal_connect(blur_close, b_blur_cancel, "clicked")
signal_connect(blur_update, blur_mask_aver, "toggled")
signal_connect(blur_update, blur_mask_circ, "toggled")
signal_connect(blur_update, blur_mask_lp3, "toggled")

signal_connect(sharp_open, b_sharp, "clicked")
signal_connect(sharp_close, b_sharp_cancel, "clicked")
signal_connect(sharp_update, sharp_mask_mean, "toggled")
signal_connect(sharp_update, sharp_mask_hp1, "toggled")
signal_connect(sharp_update, sharp_mask_hp2, "toggled")

signal_connect(range_open, b_transit, "clicked")
signal_connect(range_accept, b_range_ok, "clicked")
signal_connect(range_close, b_range_cancel, "clicked")

signal_connect(update_range_left, a_range_left, "value-changed")
signal_connect(update_range_right, a_range_right, "value-changed")
signal_connect(update_range_up, a_range_up, "value-changed")
signal_connect(update_range_down, a_range_down, "value-changed")
signal_connect(transit_open, b_range_ok, "clicked")
signal_connect(transit_close, b_transit_cancel, "clicked")


#function f1(w, var)
#    global var = get_gtk_property(w, :active, Bool)
#    println("A", red_sr, "B", red_hr)
#end
#function f2(w)
#    global red_hr = get_gtk_property(w, :active, Bool)
#    println("A", red_sr, "B", red_hr)
#end
#red_sr = ""
#red_sg = ""
#red_sb = ""
#red_hr = ""
#red_hg = ""
#red_hb = ""
#signal_connect(f1, rgb_sr, "toggled", red_sr)
#signal_connect(f1, rgb_hr, "toggled", red_hr)


showall(mainW)
hide(scale_left)
hide(scale_right)
hide(scale_down)
hide(scale_up)
hide(b_range_cancel)
hide(b_range_ok)
open_fileopen(mainW)

