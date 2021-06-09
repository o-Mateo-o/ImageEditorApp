
function rgb2hsl(rgb)
    r = rgb[1]
    g = rgb[2]
    b = rgb[3]
    siz = size(r)
    h = zeros(Float64,siz[1],siz[2])
    s = zeros(Float64,siz[1],siz[2])
    l = zeros(Float64,siz[1],siz[2])

    for i in 1:siz[1], j in 1:siz[2]
        Cmax = max(r[i,j], g[i,j], b[i,j])
        Cmin = min(r[i,j], g[i,j], b[i,j])
        Δ = Cmax - Cmin
        
        # L
        lum = round(((Cmax.+Cmin)./2), digits = 3)
        l[i,j] = lum
    
        # H
        if Δ == 0
            h[i,j] = 0
        elseif Cmax == r[i,j]
            h[i,j] = round(60*(((g[i,j]-b[i,j])./Δ).%6))
        elseif Cmax == g[i,j]
            h[i,j] = round(60*(((g[i,j]-b[i,j])./Δ).+2))
        else
            h[i,j] = round(60*(((r[i,j]-g[i,j])./Δ).+4))
        end
        
        #S
        if Δ == 0
            s[i,j] = 0
        else
            s[i,j] = round(Δ./(1-abs(2*lum-1)), digits = 3)
        end
    end
    return [h,s,l]
end
#_______________________________________________________________

function hsl2rgb(hsl)
    h = hsl[1]
    s = hsl[2]
    l = hsl[3]
    siz = size(h)
    r = zeros(Float64,siz[1],siz[2])
    g = zeros(Float64,siz[1],siz[2])
    b = zeros(Float64,siz[1],siz[2])
    
    for i in 1:siz[1], j in 1:siz[2]
        C = (1-abs(2l[i,j]-1)).*s[i,j]
        X = round(C.*(1-abs((h[i,j]./60)%2 - 1)), digits = 3)
        m = round(l[i,j] - C./2, digits = 3)
            
        if h[i,j]>=0 && h[i,j]<60
            r[i,j] = C+m
            g[i,j] = X+m
            b[i,j] = m
        elseif h[i,j]>=60 && h[i,j]<120
            r[i,j] = X+m
            g[i,j] = C+m
            b[i,j] = m
        elseif h[i,j]>=120 && h[i,j]<180
            r[i,j] = m
            g[i,j] = m+C
            b[i,j] = m+X
        elseif h[i,j]>=180 && h[i,j]<240
            r[i,j] = m
            g[i,j] = X+m
            b[i,j] = C+m
        elseif h[i,j]>=240 && h[i,j]<300
            r[i,j] = X+m
            g[i,j] = 0+m
            b[i,j] = C+m
        else
            r[i,j] = C+m
            g[i,j] = m
            b[i,j] = X+m
        end
    end
    return [r,g,b]
end 
#_______________________________________________________________

function lightness(rgb)
    r = rgb[1]
    g = rgb[2]
    b = rgb[3]
    siz = size(r)
    l = zeros(Float64,siz[1],siz[2])

    for i in 1:siz[1], j in 1:siz[2]
        Cmax = max(r[i,j], g[i,j], b[i,j])
        Cmin = min(r[i,j], g[i,j], b[i,j])
        Δ = Cmax - Cmin
        
        l[i,j] = round(((Cmax.+Cmin)./2), digits = 3)
    end
   return l
end
#_______________________________________________________________

function getHMLValue(rgb) # getHighestMiddleLowestValue
    r = rgb[1]
    g = rgb[2]
    b = rgb[3]    
    siz = size(r)
    highest = Array{Tuple{Any, Any},2}(undef, siz[1], siz[2])
    middle = Array{Tuple{Any, Any},2}(undef, siz[1], siz[2])
    lowest = Array{Tuple{Any, Any},2}(undef, siz[1], siz[2])
    for i in 1:siz[1], j in 1:siz[2]
        high = max(r[i,j], g[i,j], b[i,j])
        low = min(r[i,j], g[i,j], b[i,j])
        
        # maksymalne wartości
        if high == r[i,j]
            highest[i,j] = ("r", r[i,j])
        elseif high == g[i,j]
            highest[i,j] = ("g", g[i,j])
        else
            highest[i,j] = ("b", b[i,j])
        end
            
        # najmniejsze wartości
        if low == r[i,j]
            lowest[i,j] = ("r", r[i,j])
        elseif low == g[i,j]
            lowest[i,j] = ("g", g[i,j])
        else
            lowest[i,j] = ("b", b[i,j])
        end
                
        #średnie wartości
        if low != r[i,j] && high != r[i,j]
            middle[i,j] = ("r", r[i,j])
        elseif low != g[i,j] && high != g[i,j]
            middle[i,j] = ("g", g[i,j])
        else
            middle[i,j] = ("b", b[i,j])
        end        
    end
    return [highest, middle, lowest]
end
#_______________________________________________________________  

function avarage(rgb)
    r = rgb[1]
    g = rgb[2]
    b = rgb[3]
    siz = size(r)
    average = zeros(Float64,siz[1],siz[2]) 
    for i in 1:siz[1], j in 1:siz[2]
        average[i,j] = (r[i,j] + g[i,j] + b[i,j])./3
    end
    return average
end
#_______________________________________________________________

function contrastStretching(rgb, parameter::Int64) # wartość contrast powinna być z przedziału (-255,255) i być liczbą całkowitą
    if parameter > -255 && parameter < 255
        factor = (260*(parameter + 255))./(255*(260 - parameter))
        println(factor)
        r = rgb[1]
        g = rgb[2]
        b = rgb[3]    
        siz = size(r)
        newRed = zeros(Float64,siz[1],siz[2])
        newGreen = zeros(Float64,siz[1],siz[2])
        newBlue = zeros(Float64,siz[1],siz[2])
        
        for i in 1:siz[1], j in 1:siz[2]
            newRed[i,j] = factor*(r[i,j]-0.5) + 0.5
            newGreen[i,j] = factor*(g[i,j]-0.5) + 0.5
            newBlue[i,j] = factor*(b[i,j]-0.5) + 0.5
        end
    end
    return [newRed, newGreen, newBlue]
end
#_______________________________________________________________

# Próba implementacji rozjaśniwnia
function lighten(rgb)
    r = rgb[1]
    siz = size(r)
    NewRed = zeros(Float64,siz[1],siz[2])
    NewGreen = zeros(Float64,siz[1],siz[2])
    NewBlue = zeros(Float64,siz[1],siz[2])
    
    highColor, middleColor, lowColor = getHMLValue(rgb)  # odwołanie się do funkcji pomocniczej
    println(highColor)

    for i in 1:siz[1], j in 1:siz[2]
        newLowColor = lowColor[i,j] # newColor to krotka która zawiera ("rodzaj koloru", wartośćtego koloru w formie rgb/255)
        newMiddleColor = middleColor[i,j]
        newHighColor = highColor[i,j]
        
        if newLowColor[1] == "r"
            NewRed[i,j] = newLowColor[2] + minimum(1-newLowColor[2], 0.1)
            
            diff = 1 - newLowColor[2]
            increase = NewRed[i,j] - newLowColor[2]
            fraction = increase./diff
            
            if newMiddleColor[1] == "g"
                NewGreen[i,j] = round(newMiddleColor[2] + (1-newMiddleColor[2])*fraction, digits = 3)
                NewBlue[i,j] = round(newHighColor[2] + (1-newHighColor[2])*fraction, digits = 3)
            else
                NewBlue[i,j] = round(newMiddleColor[2] + (1-newMiddleColor[2])*fraction, digits = 3)
                NewGreen[i,j] = round(newHighColor[2] + (1-newHighColor[2])*fraction, digits = 3)
            end
            
            
        elseif newLowColor[1] == "g"
            NewGreen[i,j] = newLowColor[2] + minimum(1-newLowColor[2], 0.1)
            
            diff = 1 - newLowColor[2]
            increase = NewGreen[i,j] - newLowColor[2]
            fraction = increase./diff
                
            if newMiddleColor[1] == "r"
                NewRed[i,j] = round(newMiddleColor[2] + (1-newMiddleColor[2])*fraction, digits = 3)
                NewBlue[i,j] = round(newHighColor[2] + (1-newHighColor[2])*fraction, digits = 3)
            else
                NewBlue[i,j] = round(newMiddleColor[2] + (1-newMiddleColor[2])*fraction, digits = 3)
                NewRed[i,j] = round(newHighColor[2] + (1-newHighColor[2])*fraction, digits = 3)
            end
            
        else
            NewBlue[i,j] = newLowColor[2] + minimum(1-newLowColor[2], 0.1)
            
            diff = 1 - newLowColor[2]
            increase = NewBlue[i,j] - newLowColor[2]
            fraction = increase./diff
                
            if newMiddleColor[1] == "r"
                NewRed[i,j] = round(newMiddleColor[2] + (1-newMiddleColor[2])*fraction, digits = 3)
                NewGreen[i,j] = round(newHighColor[2] + (1-newHighColor[2])*fraction, digits = 3)
            else
                NewGreen[i,j] = round(newMiddleColor[2] + (1-newMiddleColor[2])*fraction, digits = 3)
                NewRed[i,j] = round(newHighColor[2] + (1-newHighColor[2])*fraction, digits = 3)
            end
        end
    end
    return [newRed, newGreen, newBlue]
end
#_______________________________________________________________

# Implementacja sepii
function sepia(rgb)
    r = rgb[1]
    g = rgb[2]
    b = rgb[3]    
    siz = size(r)
    newRed = zeros(Float64,siz[1],siz[2])
    newGreen = zeros(Float64,siz[1],siz[2])
    newBlue = zeros(Float64,siz[1],siz[2])
    for i in 1:siz[1]
        for j in 1:siz[2]
            newRed[i,j] = 0.4*r[i,j] + 0.8*g[i,j] * 0.1*b[i,j]
            newGreen[i,j] = 0.3*r[i,j] + 0.7*g[i,j] * 0.15*b[i,j]
            newBlue[i,j] = 0.3*r[i,j] + 0.5*g[i,j] * 0.1*b[i,j]
        end
    end
    return [newRed, newGreen, newBlue]
end












