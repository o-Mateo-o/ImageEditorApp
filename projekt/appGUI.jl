include("blurrFunctions.jl")
include("colorFunctions.jl")
include("transformationFunctions.jl")
#include("ManagePic.jl")

using Gtk, Images, ImageView

#po otworzeniu pliku jak ktoś zamknie otwieracz to error wypala





bld = GtkBuilder(filename="projekt/GUILayout.glade")
saving_path = ""
save_flag = false
undo_counter = -1
transits_counter = 0
transit_given_reg = []


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
end

rgb_choice = ""
gray_choice = ""
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
b_negative = bld["b_negative"]
b_blur = bld["b_blur"]
b_sharp = bld["b_sharp"]
b_transit = bld["b_transit"]
b_xmirr = bld["b_xmirr"]
b_ymirr = bld["b_ymirr"]

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
gray_r = bld["gray_r"]
gray_g = bld["gray_g"]
gray_b = bld["gray_b"]
gray_rg = bld["gray_rg"]
gray_gb = bld["gray_gb"]
gray_br = bld["gray_br"]
gray_rgb = bld["gray_rgb"]
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
list_transit = bld["list_transit"]
item_transit_1 = bld["item_transit_1"]
item_transit_2 = bld["item_transit_2"]
item_transit_3 = bld["item_transit_3"]
item_transit_4 = bld["item_transit_4"]
item_transit_5 = bld["item_transit_5"]
label_transit_1 = bld["label_transit_1"]
label_transit_2 = bld["label_transit_2"]
label_transit_3 = bld["label_transit_3"]
label_transit_4 = bld["label_transit_4"]
label_transit_5 = bld["label_transit_5"]
b_minus_transit_1 = bld["b_minus_transit_1"]
b_minus_transit_2 = bld["b_minus_transit_2"]
b_minus_transit_3 = bld["b_minus_transit_3"]
b_minus_transit_4 = bld["b_minus_transit_4"]
b_minus_transit_5 = bld["b_minus_transit_5"]
transit_list_reg = [[item_transit_1, label_transit_1, b_minus_transit_1],
                    [item_transit_2, label_transit_2, b_minus_transit_2],
                    [item_transit_3, label_transit_3, b_minus_transit_3],
                    [item_transit_4, label_transit_4, b_minus_transit_4],
                    [item_transit_5, label_transit_5, b_minus_transit_5],]

transitLimitW = bld["transitLimitW"]
b_transit_limit_cancel = bld["b_transit_limit_cancel"]


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
    
    ManagePic.savePictureRGB(saving_path, ManagePic.generateMatricesRGB(current_image))
    println(saving_path)
    global save_flag = true
end
function save_filesave(w)
    if save_flag == true
        ManagePic.savePictureRGB(saving_path, ManagePic.generateMatricesRGB(current_image))
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
function gray_update(w)
    if get_gtk_property(w, :active, Bool)
        global gray_choice = w
    end
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
    
    color_matrices = ManagePic.generateMatricesRGB(image)
    
    img_height = size(color_matrices[1])[1]
    img_width = size(color_matrices[1])[2]
    ru = (max(Int(floor(range_up*img_height/100)),1), max(Int(floor((100-range_right)*img_width/100)),1))
    ld = (max(Int(floor((100-range_down)*img_height/100)),1), max(Int(floor(range_left*img_width/100)),1))


    for i in 1:3
        original_matrix = copy(color_matrices[i])
       
        color_matrices[i] = original_matrix .* 0.3
        color_matrices[i][ru[1]:ld[1], ld[2]:ru[2]] = original_matrix[ru[1]:ld[1], ld[2]:ru[2]]
    end
    
    global selection_ru = ru
    global selection_ld = ld
    
    selection_image = ManagePic.matriceRGB(color_matrices...)
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
    global transits_counter = 0
    for i in 1:5
        hide(transit_list_reg[i][1])
        global transit_given_reg = []
    end
    show(transitW)    
end
transit_close(w) = hide(transitW)

function draw_transit_list()
    for i in 1:length(transit_given_reg)
        if transit_given_reg[i][1] == 't'
            set_gtk_property!(transit_list_reg[i][2], :label,
                string("Translation: (", string( transit_given_reg[i][2]),", ", string( transit_given_reg[i][3]),")"))
        elseif transit_given_reg[i][1] == 's'
            set_gtk_property!(transit_list_reg[i][2], :label,
             string("Scaling: (", string( transit_given_reg[i][2]),", ", string( transit_given_reg[i][3]),")"))
        elseif transit_given_reg[i][1] == 'r'
            set_gtk_property!(transit_list_reg[i][2], :label,
             string("Rotation: ", string( transit_given_reg[i][2]), "°"))
        end

        show(transit_list_reg[i][1])
    end
    for i in length(transit_given_reg)+1:5
        hide(transit_list_reg[i][1])
    end
end

function transl_add(w)
    if transits_counter >= 5
        show(transitLimitW)
    else
        vect_x = get_gtk_property(a_transl_vect_x, :value,  Float32)
        vect_y = get_gtk_property(a_transl_vect_y, :value, Float32)
        if !(vect_x == 0.0 && vect_y == 0.0)
            push!(transit_given_reg, ('t', vect_x, vect_y))
            global transits_counter += 1
        end
    end
    draw_transit_list()
end


function rotat_add(w)
    if transits_counter >= 5
        show(transitLimitW)
    else
        angle = get_gtk_property(a_rotat_angle, :value, Float32)
        if angle != 0
            push!(transit_given_reg, ('r', angle))
            global transits_counter += 1
        end
    end
    draw_transit_list()
end

function scale_add(w)
    if transits_counter >= 5
        show(transitLimitW)
    else
        ratio_x = get_gtk_property(a_scale_ratio_x, :value, Float32)
        ratio_y = get_gtk_property(a_scale_ratio_y, :value,  Float32)
        if !(ratio_x == 1.0 && ratio_y == 1.0)
            push!(transit_given_reg, ('s', ratio_x, ratio_y))
            global transits_counter += 1
        end
    end
    draw_transit_list()
end

function transit_del_elem_1(w)
    global transits_counter -= 1
    hide(transit_list_reg[1][1])
    splice!(transit_given_reg, 1)
    draw_transit_list()
end
function transit_del_elem_2(w)
    global transits_counter -= 1
    hide(transit_list_reg[2][1])
    splice!(transit_given_reg, 2)
    draw_transit_list()
end
function transit_del_elem_3(w)
    global transits_counter -= 1
    hide(transit_list_reg[3][1])
    splice!(transit_given_reg, 3)  
    draw_transit_list() 
end
function transit_del_elem_4(w)
    global transits_counter -= 1
    hide(transit_list_reg[4][1])
    splice!(transit_given_reg, 4)    
    draw_transit_list()
end
function transit_del_elem_5(w)
    global transits_counter -= 1
    hide(transit_list_reg[5][1])
    splice!(transit_given_reg, 5)     
    draw_transit_list()
end






function transit_limit_dialog_open(w)
    show(transitLimitW)    
end
transit_limit_dialog_close(w) = hide(transitLimitW)


# backend functions calls
function call_brctr(w)
    rgb = ManagePic.generateMatricesRGB(current_image)
    brightness_fact = get_gtk_property(a_brightness, :value, Float64)
    contrast_fact = get_gtk_property(a_contrast, :value, Float64)

    if brightness_fact != 0
        rgb = colorFunctions.changeBrightness(rgb, brightness_fact)
    end
    if contrast_fact != 0
        rgb = colorFunctions.changeContrast(rgb, contrast_fact)
    end

    new_current_image(ManagePic.matriceRGB(rgb...), cnv)
    hide(brctrW)  
end

function call_hsl(w)
    rgb = ManagePic.generateMatricesRGB(current_image)
    hue_fact = get_gtk_property(a_hue, :value, Float64)
    satur_fact = get_gtk_property(a_satur, :value, Float64)
    light_fact =  get_gtk_property(a_light, :value, Float64)
    if hue_fact < 0
        hue_fact += 360
    end
    if hue_fact != 0
        rgb = colorFunctions.changeColors(rgb, hue_fact)
    end
    if satur_fact != 0
        rgb = colorFunctions.changeSaturation(rgb, satur_fact)
    end
    if light_fact != 0
        rgb = colorFunctions.changeLightness(rgb, light_fact)
    end
    
    new_current_image(ManagePic.matriceRGB(rgb...), cnv)
    hide(hslW)  
end

function call_rgb(w)
    rgb = ManagePic.generateMatricesRGB(current_image)
    if rgb_choice == rgb_sr
        rgb = colorFunctions.onlyRed(rgb)
    elseif rgb_choice == rgb_sg
        rgb = colorFunctions.onlyGreen(rgb)
    elseif rgb_choice == rgb_sb
        rgb = colorFunctions.onlyBlue(rgb)
    elseif rgb_choice == rgb_hr
        rgb = colorFunctions.withoutRed(rgb)
    elseif rgb_choice == rgb_hg
        rgb = colorFunctions.withoutGreen(rgb)
    elseif rgb_choice == rgb_hb
        rgb = colorFunctions.withoutBlue(rgb)
    end
    new_current_image(ManagePic.matriceRGB(rgb...), cnv)
    hide(rgbW)  
end

function call_gray(w)
    rgb = ManagePic.generateMatricesRGB(current_image)
    if gray_choice == gray_r
        rgb = colorFunctions.redAsAGrayscale(rgb)
    elseif gray_choice == gray_g
        rgb = colorFunctions.greenAsAGrayscale(rgb)
    elseif gray_choice == gray_b
        rgb = colorFunctions.blueAsAGrayscale(rgb)
    elseif gray_choice == gray_rg
        rgb = colorFunctions.onlyBlueAndGrayscale(rgb)
    elseif gray_choice == gray_gb
        rgb = colorFunctions.onlyRedAndGrayscale(rgb)
    elseif gray_choice == gray_br
        rgb = colorFunctions.withoutGreen(rgb)
    elseif gray_choice == gray_rgb
        rgb = colorFunctions.grayscaleLuminosity(rgb)
    end
    new_current_image(ManagePic.matriceRGB(rgb...), cnv)
    hide(grayW)  
end

function call_negative(w)
    rgb = ManagePic.generateMatricesRGB(current_image)
    rgb = colorFunctions.negative(rgb)
    new_current_image(ManagePic.matriceRGB(rgb...), cnv)
end


    



# SIGNAL CONNECTING
signal_connect(open_fileopen, b_open, "activate")
signal_connect(save_filesave, b_save, "activate")
signal_connect(save_filesaveas, b_saveas, "activate")
signal_connect(quit_app, b_quit, "activate")
signal_connect(undo_clb, b_undo, "activate")

signal_connect(brctr_open, b_brctr, "clicked")
signal_connect(brctr_close, b_brctr_cancel, "clicked")
signal_connect(call_brctr, b_brctr_ok, "clicked")

signal_connect(hsl_open, b_hsl, "clicked")
signal_connect(hsl_close, b_hsl_cancel, "clicked")
signal_connect(call_hsl, b_hsl_ok, "clicked")

signal_connect(rgb_open, b_rgb, "clicked")
signal_connect(rgb_close, b_rgb_cancel, "clicked")
signal_connect(rgb_update, rgb_sr, "toggled")
signal_connect(rgb_update, rgb_sg, "toggled")
signal_connect(rgb_update, rgb_sb, "toggled")
signal_connect(rgb_update, rgb_hr, "toggled")
signal_connect(rgb_update, rgb_hg, "toggled")
signal_connect(rgb_update, rgb_hb, "toggled")
signal_connect(call_rgb, b_rgb_ok, "clicked")

signal_connect(gray_open, b_gray, "clicked")
signal_connect(gray_close, b_gray_cancel, "clicked")
signal_connect(gray_update, gray_r, "toggled")
signal_connect(gray_update, gray_g, "toggled")
signal_connect(gray_update, gray_b, "toggled")
signal_connect(gray_update, gray_rg, "toggled")
signal_connect(gray_update, gray_gb, "toggled")
signal_connect(gray_update, gray_br, "toggled")
signal_connect(gray_update, gray_rgb, "toggled")
signal_connect(call_gray, b_gray_ok, "clicked")

signal_connect(call_negative, b_negative, "clicked")

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

signal_connect(transl_add, b_add_transl, "clicked")
signal_connect(rotat_add, b_add_rotat, "clicked")
signal_connect(scale_add, b_add_scale, "clicked")
signal_connect(transit_del_elem_1, transit_list_reg[1][3], "clicked")
signal_connect(transit_del_elem_2, transit_list_reg[2][3], "clicked")
signal_connect(transit_del_elem_3, transit_list_reg[3][3], "clicked")
signal_connect(transit_del_elem_4, transit_list_reg[4][3], "clicked")
signal_connect(transit_del_elem_5, transit_list_reg[5][3], "clicked")

signal_connect(transit_limit_dialog_close, b_transit_limit_cancel, "clicked")



global rgb_choice = rgb_sr
global gray_choice = gray_rgb
showall(mainW)
hide(scale_left)
hide(scale_right)
hide(scale_down)
hide(scale_up)
hide(b_range_cancel)
hide(b_range_ok)
open_fileopen(mainW)

