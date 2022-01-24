#############################################################
## NOTE: This file is written in the standard GTK convention;
## documentation is not necessary in this particular case.
#############################################################

include("blurrFunctions.jl")
include("colorFunctions.jl")
include("transformationFunctions.jl")

using Gtk, Images, ImageView, FileIO


# GLOBAL VARIABLES AND GENERAL FUNCTIONS

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
        println("ERROR - cant undo")
    end
end

rgb_choice = ""
gray_choice = ""
blur_choice = ""
orig_choice = ""
range_right_val = 0
range_left_val = 0
range_up_val = 0
range_down_val = 0 
selection_ru = (Nothing, Nothing)
selection_ld = (Nothing, Nothing)

# ELEMENTS BUILDING

# main window
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

# brightness and conterast window
brctrW = bld["brctrW"]
b_brctr_cancel = bld["b_brctr_cancel"]
a_brightness = bld["a_brightness"]
a_contrast = bld["a_contrast"]
b_brctr_ok = bld["b_brctr_ok"]
# hue satur light window
hslW = bld["hslW"]
b_hsl_cancel = bld["b_hsl_cancel"]
a_hue = bld["a_hue"]
a_satur = bld["a_satur"]
a_light = bld["a_light"]
b_hsl_ok = bld["b_hsl_ok"]
# rgb components
rgbW = bld["rgbW"]
b_rgb_cancel = bld["b_rgb_cancel"]
rgb_sr = bld["rgb_sr"]
rgb_sg = bld["rgb_sg"]
rgb_sb = bld["rgb_sb"]
rgb_hr = bld["rgb_hr"]
rgb_hg = bld["rgb_hg"]
rgb_hb = bld["rgb_hb"]
b_rgb_ok = bld["b_rgb_ok"]
# grayscale
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
# blur 
blurW = bld["blurW"]
b_blur_cancel = bld["b_blur_cancel"]
a_blur_radius_s = bld["a_blur_radius_s"]
a_blur_intens_s = bld["a_blur_intens_s"]
blur_mask_aver = bld["blur_mask_aver"]
blur_mask_circ = bld["blur_mask_circ"]
blur_mask_lp3 = bld["blur_mask_lp3"]
b_blur_ok = bld["b_blur_ok"]
# sharp 
sharpW = bld["sharpW"]
b_sharp_cancel = bld["b_sharp_cancel"]
a_sharp_radius_s = bld["a_sharp_radius_s"]
a_sharp_intens_s = bld["a_sharp_intens_s"]
b_sharp_ok = bld["b_sharp_ok"]
# transform
transitW = bld["transitW"]
a_transl_vect_x = bld["a_transl_vect_x"]
a_transl_vect_y = bld["a_transl_vect_y"]
a_rotat_angle = bld["a_rotat_angle"]
a_scale_ratio_x = bld["a_scale_ratio_x"]
a_scale_ratio_y = bld["a_scale_ratio_y"]
b_add_transl = bld["b_add_transl"]
b_add_rotat = bld["b_add_rotat"]
b_add_scale = bld["b_add_scale"]

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
orig_c = bld["orig_c"]
orig_l = bld["orig_l"]
orig_r = bld["orig_r"]
orig_u = bld["orig_u"]
orig_d = bld["orig_d"]
orig_ru = bld["orig_ru"]
orig_rd = bld["orig_rd"]
orig_lu = bld["orig_lu"]
orig_ld = bld["orig_ld"]

transitLimitW = bld["transitLimitW"]
b_transit_limit_cancel = bld["b_transit_limit_cancel"]

# CALLBACK FUNCTIONS
function open_fileopen(w)
    path = open_dialog("Pick an image file", GtkNullContainer(), (GtkFileFilter("*.jpg", name="All supported formats"), "*.jpg"))
    if path != ""
        img = load(path)
        new_current_image(img, cnv)
    end
end
function save_filesaveas(w)
    path_raw = save_dialog("Save as...", mainW, ("*.jpg", GtkFileFilter("*.jpg", name="All supported formats")))
    
    if path_raw[end - 3:end] != ".jpg"
        global saving_path = path_raw * ".jpg"
    else
        global saving_path = path_raw
    end
    Images.save(saving_path, current_image)
    global save_flag = true
end
function save_filesave(w)
    if save_flag == true
        Images.save(saving_path, current_image)
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
    set_gtk_property!(a_blur_intens_s, :sensitive, false)
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
    if w == blur_mask_circ || w == blur_mask_aver
        set_gtk_property!(a_blur_intens_s, :sensitive, false)
    else
        set_gtk_property!(a_blur_intens_s, :sensitive, true)
    end
end


function sharp_open(w)
    show(sharpW)
end
sharp_close(w) = hide(sharpW)


function show_selection(image, range_left, range_right, range_up, range_down)   
    
    color_matrices = generateMatricesRGB(image)
    
    img_height = size(color_matrices[1])[1]
    img_width = size(color_matrices[1])[2]
    ru = (max(Int(floor(range_up * img_height / 100)), 1), max(Int(floor((100 - range_right) * img_width / 100)), 1))
    ld = (max(Int(floor((100 - range_down) * img_height / 100)), 1), max(Int(floor(range_left * img_width / 100)), 1))


    for i in 1:3
        original_matrix = copy(color_matrices[i])
       
        color_matrices[i] = original_matrix .* 0.3
        color_matrices[i][ru[1]:ld[1], ld[2]:ru[2]] = original_matrix[ru[1]:ld[1], ld[2]:ru[2]]
    end
    
    global selection_ru = ru
    global selection_ld = ld
    
    selection_image = matriceRGB(color_matrices...)
    imshow(cnv, selection_image)
end # RGB

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
        set_gtk_property!(w, :value, 99 - range_right_val)
    end
    show_selection(current_image, range_left_val, range_right_val, range_up_val, range_down_val)
end
function update_range_right(w)
    global range_right_val = get_gtk_property(w, :value, Int)
    if range_right_val + range_left_val >= 99
        set_gtk_property!(w, :value, 99 - range_left_val)
    end
    show_selection(current_image, range_left_val, range_right_val, range_up_val, range_down_val)
end
function update_range_up(w)
    global range_up_val = get_gtk_property(w, :value, Int)
    if range_up_val + range_down_val >= 99
        set_gtk_property!(w, :value, 99 - range_down_val)
    end
    show_selection(current_image, range_left_val, range_right_val, range_up_val, range_down_val)
end
function update_range_down(w)
    global range_down_val = get_gtk_property(w, :value, Int)
    if range_down_val + range_up_val >= 99
        set_gtk_property!(w, :value, 99 - range_up_val)
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
                string("Translation: (", string(transit_given_reg[i][2]), ", ", string(transit_given_reg[i][3]), ")"))
        elseif transit_given_reg[i][1] == 's'
            set_gtk_property!(transit_list_reg[i][2], :label,
             string("Scaling: (", string(transit_given_reg[i][2]), ", ", string(transit_given_reg[i][3]), ")"))
        elseif transit_given_reg[i][1] == 'r'
            set_gtk_property!(transit_list_reg[i][2], :label,
             string("Rotation: ", string(transit_given_reg[i][2]), "°"))
        end

        show(transit_list_reg[i][1])
    end
    for i in length(transit_given_reg) + 1:5
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
function orig_update(w)
    if get_gtk_property(w, :active, Bool)
        global orig_choice = w
    end
end

function transit_limit_dialog_open(w)
    show(transitLimitW)    
end
transit_limit_dialog_close(w) = hide(transitLimitW)


# BACKEND FUNCTIONS CALL
function call_brctr(w)
    rgb = generateMatricesRGB(current_image)
    brightness_fact = get_gtk_property(a_brightness, :value, Float64)
    contrast_fact = get_gtk_property(a_contrast, :value, Float64)

    if brightness_fact != 0
        rgb = changeBrightness(rgb, brightness_fact)
    end
    if contrast_fact != 0
        rgb = changeContrast(rgb, contrast_fact)
    end

    new_current_image(matriceRGB(rgb...), cnv)
    hide(brctrW)  
end

function call_hsl(w)
    rgb = generateMatricesRGB(current_image)
    hue_fact = get_gtk_property(a_hue, :value, Float64)
    satur_fact = get_gtk_property(a_satur, :value, Float64)
    light_fact =  get_gtk_property(a_light, :value, Float64)
    if hue_fact < 0
        hue_fact += 360
    end
    if hue_fact != 0
        rgb = changeColors(rgb, hue_fact)
    end
    if satur_fact != 0
        rgb = changeSaturation(rgb, satur_fact)
    end
    if light_fact != 0
        rgb = changeLightness(rgb, light_fact)
    end
    
    new_current_image(matriceRGB(rgb...), cnv)
    hide(hslW)  
end

function call_rgb(w)
    rgb = generateMatricesRGB(current_image)
    if rgb_choice == rgb_sr
        rgb = onlyRed(rgb)
    elseif rgb_choice == rgb_sg
        rgb = onlyGreen(rgb)
    elseif rgb_choice == rgb_sb
        rgb = onlyBlue(rgb)
    elseif rgb_choice == rgb_hr
        rgb = withoutRed(rgb)
    elseif rgb_choice == rgb_hg
        rgb = withoutGreen(rgb)
    elseif rgb_choice == rgb_hb
        rgb = withoutBlue(rgb)
    end
    new_current_image(matriceRGB(rgb...), cnv)
    hide(rgbW)  
end

function call_gray(w)
    rgb = generateMatricesRGB(current_image)
    if gray_choice == gray_r
        rgb = redAsAGrayscale(rgb)
    elseif gray_choice == gray_g
        rgb = greenAsAGrayscale(rgb)
    elseif gray_choice == gray_b
        rgb = blueAsAGrayscale(rgb)
    elseif gray_choice == gray_rg
        rgb = onlyBlueAndGrayscale(rgb)
    elseif gray_choice == gray_gb
        rgb = onlyRedAndGrayscale(rgb)
    elseif gray_choice == gray_br
        rgb = withoutGreen(rgb)
    elseif gray_choice == gray_rgb
        rgb = grayscaleLuminosity(rgb)
    end
    new_current_image(matriceRGB(rgb...), cnv)
    hide(grayW)  
end

function call_negative(w)
    rgb = generateMatricesRGB(current_image)
    rgb = negative(rgb)
    new_current_image(matriceRGB(rgb...), cnv)
end

function call_blur(w)
    rgb = generateMatricesRGB(current_image)
    blur_radius = get_gtk_property(a_blur_radius_s, :value, Int)
    blur_intens = get_gtk_property(a_blur_intens_s, :value, Int)
    if blur_radius % 2 == 0
        blur_radius += 1
    end
    if blur_choice == blur_mask_aver
        rgb = converting(rgb, maskAverage(blur_radius))
    elseif blur_choice == blur_mask_circ
        rgb = converting(rgb, circle(blur_radius))
    elseif blur_choice == blur_mask_lp3
        rgb = converting(rgb, LP3(blur_radius, blur_intens))
    end
    new_current_image(matriceRGB(rgb...), cnv)
    hide(blurW)
end

function call_sharp(w)
    rgb = generateMatricesRGB(current_image)
    sharp_radius = get_gtk_property(a_sharp_radius_s, :value, Int)
    sharp_intens = get_gtk_property(a_sharp_intens_s, :value, Int)
    if sharp_radius % 2 == 0
        sharp_radius += 1
    end
    rgb = converting(rgb, meanRemoval(sharp_radius, sharp_intens))

    new_current_image(matriceRGB(rgb...), cnv)
    hide(sharpW)
end

function call_affin(w) 
    rgb = generateMatricesRGB(current_image)
    if length(transit_given_reg) > 0
        origin = (0, 0)
        s_r_list = []
        df_origin = defaultOrigin(selection_ld, selection_ru)
        if orig_choice == orig_c
            origin = df_origin
        elseif orig_choice == orig_l
            origin = (df_origin[1], selection_ld[2])
        elseif orig_choice == orig_r
            origin = (df_origin[1], selection_ru[2])
        elseif orig_choice == orig_u
            origin = (selection_ru[1], df_origin[2])
        elseif orig_choice == orig_d
            origin = (selection_ld[1], df_origin[2])
        elseif orig_choice == orig_ru
            origin = selection_ru
        elseif orig_choice == orig_ld
            origin = selection_ld
        elseif orig_choice == orig_rd
            origin = (selection_ld[1], selection_ru[2])
        elseif orig_choice == orig_lu
            origin = (selection_ru[1], selection_ld[2])
        end
        transl_x = 0
        transl_y = 0
        for i in 1:length(transit_given_reg)
            if transit_given_reg[i][1] == 't'
                transl_x += transit_given_reg[i][2]
                transl_y -= transit_given_reg[i][3]
            elseif transit_given_reg[i][1] == 's'
                push!(s_r_list, ('s', (transit_given_reg[i][3],  transit_given_reg[i][2])))
            elseif transit_given_reg[i][1] == 'r'
                push!(s_r_list, ('r', transit_given_reg[i][2]))
            end
        end
        transl_vect = (transl_y, transl_x)
        rgb = selectionTransform(rgb, selection_ld, selection_ru, [(origin, s_r_list, transl_vect)])
        new_current_image(matriceRGB(rgb...), cnv)
    else
        new_current_image(current_image, cnv)
    end
    hide(transitW)
    
end

function call_xmirr(w)
    rgb = generateMatricesRGB(current_image)
    rgb = mirror(rgb, :x)
    new_current_image(matriceRGB(rgb...), cnv)
end

function call_ymirr(w)
    rgb = generateMatricesRGB(current_image)
    rgb = mirror(rgb, :y)
    new_current_image(matriceRGB(rgb...), cnv)
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
signal_connect(call_blur, b_blur_ok, "clicked")

signal_connect(sharp_open, b_sharp, "clicked")
signal_connect(sharp_close, b_sharp_cancel, "clicked")
signal_connect(call_sharp, b_sharp_ok, "clicked")

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
signal_connect(orig_update, orig_c, "toggled")
signal_connect(orig_update, orig_l, "toggled")
signal_connect(orig_update, orig_r, "toggled")
signal_connect(orig_update, orig_d, "toggled")
signal_connect(orig_update, orig_u, "toggled")
signal_connect(orig_update, orig_ld, "toggled")
signal_connect(orig_update, orig_ru, "toggled")
signal_connect(orig_update, orig_rd, "toggled")
signal_connect(orig_update, orig_lu, "toggled")
signal_connect(transit_del_elem_1, transit_list_reg[1][3], "clicked")
signal_connect(transit_del_elem_2, transit_list_reg[2][3], "clicked")
signal_connect(transit_del_elem_3, transit_list_reg[3][3], "clicked")
signal_connect(transit_del_elem_4, transit_list_reg[4][3], "clicked")
signal_connect(transit_del_elem_5, transit_list_reg[5][3], "clicked")
signal_connect(call_affin, b_transit_ok, "clicked")

signal_connect(transit_limit_dialog_close, b_transit_limit_cancel, "clicked")

signal_connect(call_xmirr, b_xmirr, "clicked")
signal_connect(call_ymirr, b_ymirr, "clicked")

# INITIAL OPERATIONS EXECUTE

global rgb_choice = rgb_sr
global gray_choice = gray_rgb
global blur_choice = blur_mask_aver
global orig_choice = orig_c
showall(mainW)
hide(scale_left)
hide(scale_right)
hide(scale_down)
hide(scale_up)
hide(b_range_cancel)
hide(b_range_ok)
open_fileopen(mainW)
