#____________________________________________________________________________________
#       _____                   _       _   ______
#      |_   _|                 (_)     | | |  ____|
#        | |  _ __  _ __   __ _ _ _ __ | |_| |__ _   _ _ __   ___
#        | | | '_ \| '_ \ / _` | | '_ \| __|  __| | | | '_ \ / __|
#       _| |_| | | | |_) | (_| | | | | | |_| |  | |_| | | | | (__
#      |_____|_| |_| .__/ \__,_|_|_| |_|\__|_|   \__,_|_| |_|\___|
#                  | |
#                  |_|
#_____________________________________________________________________________________



#  InpaintFunc is a new delogo function using AVSInpaint.dll an AviSynth C plugin developed by AMSS.
#See thread : http://forum.doom9.org/showthread.php?t=133682 to download this plugin and get
#more information about it. Just an advertise : AVSInpaint plugin is rather slow so be patient ;-)


#_______________________________________________________________________________________
#
#    History :
#_______________________________________________________________________________________


# Actual revision : InpaintFunc v1.12

# Author          : Reuf Toc

# Requirement     : AVSInpaint.dll


# Changes         :

#Rev 1.00 :  First release 2008/01/30
#Rev 1.01 :  Added debug for "mode". Removed two useless operations.
#Rev 1.02 :  Added "Speed" parameter.
#Rev 1.03 :  Fixed bug in PAR calculation. Fixed bug with non-RGB32 mask.
#Rev 1.10 :  Fixed bug due to overlay. Added post-processing + a lot of things.
#Rev 1.11 :  Added Show parameter and InpaintAssist function. Process in RGB24 instead of RGB32. 
#Rev 1.12 :  Fixed bug in "loc" calculation
#Rev 1.13 :  Fixed bug for .ebmp creation (did not happen in several cases)

#______________________________________________________________________________________
#
#    About Inpainting :
#______________________________________________________________________________________


#  Image Inpainting is the art of restoring destroyed parts of an image by using information
#of valid parts of the image in a way, so that the human eye does not recognize the damaged
#areas (at least not at a first sight). In video processing image inpainting is often applied
#to videos in order to remove TV station logos.


#______________________________________________________________________________________
#
#    Function parameters :
#______________________________________________________________________________________




# =======================================================
#                   InpaintAssist
# =======================================================


# This subfunction can be used to help you in order to set your own crop values to isolate the logo to remove. With HD footage, the delogo
# process is slow due to the resolution (especialy for analysis) and to maximize speed, it is adviced to reduce the size of the cropped clip
# by setting your own crop values.


# If you don't specify a loc value, this function will display your clip divised in 9 parts (the nine loc preset of InpaintFunc) with the crop values for each one in order
# to give you an idea about the values to use.

# After that step, you can enter your own loc values and check they are correct. The selected area will be hightlighted.
# Keep in mind you have to keep a little border around the logo since inpainting use nearby pixels to compute the hidden ones.

# string "loc"    : Select the part of the picture where is the logo to remove. Same as InpaintFunc loc parameter

# String "alignment"   : Alignment of the text. "Top", "Center" and "Bottom" are allowed



# =======================================================
#                   InpaintFunc
# =======================================================



#  Given this function use AVSInpaint.dll and given AVSInpaint is an avisynth C plugin
#don't forget to add loadCplugin("xxx\AVSInpaint.dll") in your script before calling this function !!!




# String "loc"      :  Select the part of the picture where is the logo to remove.
#                     See the table :


#              ______________           ______________
#              | TL | TC |TR |          | X1 | X2 |X3 |
#              |____|____|___|          |____|____|___|
#              | ML | MC |MR |    or    | Y1 | Y2 |Y3 |
#              |____|____|___|          |____|____|___|
#              | BL | BC |BR |          | Z1 | Z2 |Z3 |
#              |____|____|___|          |____|____|___|


#                      If the logo you want to remove is in the top right corner, then you can choose
#                     either loc="TR" or loc="x3".

#                      If you don't want to use one of these preset, you can enter manually the crop values to isolate the logo.
#                     example : loc = "0,300,-440,-20". Spaces are not allowed in "loc" parameter. You can use function 
#                     InpaintAssist to help you to set crop values. 




# String "mask"     :  Path to the mask of the logo. The mask is a black and white picture. Parties where the logo
#                     is are white, the others are black.

#                     example : mask="C:\my_mask.bmp"



# String "mode"     :  3 Choices (default both) :

#                     -Deblend : If the logo is transparent, use this mode.
#                     -Inpaint : If the logo is opaque, use this mode.
#                     -Both    : If the logo is both opaque and transparent, use this mode.



# Float "AR"        :  The Sample Aspect Ratio of your video. E.g. : 16/9, 4/3...  (Default 1.0).
#                     This value is used to calculate the PAR of your video. If you don't set this parameter, then
#                     PAR will be set to 1:1. It's not really important if you don't set this value.
#                     When you set the AR, take care to add ".0" to your values if you use exact value (16/9 or 4/3).
#                     example : AR=16.0/9.0 or AR=4.0/3.0



# Int "Speed"       :  With this parameter you can speed up this function by trimming the clip analyzed by
#                     AnalyseLogo. A value of 20 means that 100% of clip will be analyzed. With a value of
#                     1, only 5% will be analyzed. (min value 1, max value 20, default 5)


# Int "PPMode"      :  If you want to apply post-processing, 3 modes are available. Default is 0 (disabled)
#                     -Mode 1 : Blur all the area where logo was present.
#                     -Mode 2 : Blur all the area where logo was present using TemporalSoften and SpatialSoften.
#                     -Mode 3 : Blur only the edge of logo area using TemporalSoften and SpatialSoften..


# Int "PP"          :  Strength of the post-processing. Default is 50 (min value 0, max value 100)
#                     A 0 value will disable post processing, 100 will process at full strength.

# Bool "Reset"      :  InpaintFunc contain a feature that allow to not compute logo analysis when it was already done.
#                     By setting Reset to true, logo analysis is always computed. Default is false.

# Float "radius"    :  Radius around a damaged pixel from where values are taken when the pixel is inpainted.
#                     Bigger values prevent inpainting in the wrong direction, but also create more blur.

# Float "sharpness" : Higher values can prevent blurring caused by high Radius values.

# Float "preblur"   : Standard deviation of the blur which is applied to the image before the structure tensor is computed.
#                     Higher values help connecting isophotes which have been cut by the inpainting region, but also
#                     increase CPU usage. PreBlur=0.0 disables pre-blurring.
                     

# Float "postblur"  : Standard deviation of the blur which is applied to the structure tensors before they are used
#                     to determine the inpainting direction. Higher values help gather more directional information when 
#                     there are only few valid pixels available, but increases CPU usage.


# Bool "show"       : Allow the user to see the differents steps of the delogoing. Are displayed the source, the
#                     repaired, the repaired post-processed, the mask, the repair masks (edge and global), the color
#                     mask, the alpha mask and the inpaint mask.
                     



#______________________________________________________________________________________

#    Function :
#______________________________________________________________________________________


function InpaintFunc( clip clp, string "mask", string "loc", float "AR", string "mode", int "speed",
\                     int "pp", int "ppmode", bool "reset", float "radius", float "sharpness", float "preblur", 
\                     float"postblur", bool "show")

{

mask        = default (mask         , ""    )
loc         = default (loc          , ""    )
AR          = default (AR           , 1.0   )
mode        = default (mode         , "both")
speed       = default (speed        , 5     )
pp          = default (pp           , 50    )
ppmode      = default (ppmode       , 0     )
reset       = default (reset        , false )
radius      = default (radius       , 8.0   )
sharpness   = default (sharpness    , 75.0  )
preblur     = default (preblur      , 8.0   )
postblur    = default (postblur     , 4.0   )
show        = default (show         , false )




# debug
# =====


x           = width   (clp)
y           = height  (clp)
pp          = (pp >= 100) ? 255 : (pp <= 0) ? 0 : int(pp*255/100)
RGB         = isRGB(clp)
RGB24       = isRGB24(clp)
RGB32       = isRGB32(clp)
YUY2        = isYUY2(clp)
cropval     = (StrLen(loc)  != 2  )  ? true : false
spd         = (speed        != 20 )  ? true : false
PAR         = (AR           != 1.0)  ? float( y) / float( x) * AR : 1.0
bugloc      = (loc          == "" )  ? true : false
bugmode     = (mode         != "inpaint" && mode != "deblend" && mode != "both") ? true : false
bugspeed    = (speed        <= 0 || speed >= 21) ? true : false


assert        ( findstr(loc," ")  == 0      , """Space character is not allowed in string "loc"."""")
assert        ( mask              != ""     , """You have to define a mask (string "mymask")""")
assert        ( bugloc            == false  , """You must define "Loc".""")
assert        ( bugmode           == false  , """This mode doesn't exist. Change "mode" value.""")
assert        ( bugspeed          == false  , """"Speed" value must be between 1 and 20.""")



# calculation of crop values
# ==========================


null = (cropval == false ) ? eval("""

a           = (Rightstr(loc,1) == "L" || Rightstr(loc,1) == "1") ? 0 : (Rightstr(loc,1) == "C" || Rightstr(loc,1) == "2")  ? round((x*1/6))*2  : round((x*1/3))*2
b           = (leftstr(loc,1)  == "T" || leftstr(loc,1)  == "X") ? 0 : (leftstr(loc,1)  == "M" || leftstr(loc,1)  == "Y")  ? round((y*1/6))*2  : round((y*1/3))*2
c           = (Rightstr(loc,1) == "R" || Rightstr(loc,1) == "3") ? 0 : (Rightstr(loc,1) == "C" || Rightstr(loc,1) == "2")  ? -round((x*1/6))*2  : -round((x*1/3))*2
d           = (leftstr(loc,1)  == "B" || leftstr(loc,1)  == "Z") ? 0 : (leftstr(loc,1)  == "M" || leftstr(loc,1)  == "Y")  ? -round((y*1/6))*2  : -round((y*1/3))*2

              """) : eval("""

long        = StrLen(loc)

posvirg1    = findstr(loc, ",")
posvirg2    = findstr(rightstr(loc,long-posvirg1), ",")
posvirg2    = posvirg2+posvirg1
posvirg3    = findstr(rightstr(loc,long-posvirg2), ",")
posvirg3    = posvirg3  + posvirg2

a           = int(value(leftstr(loc,posvirg1-1)))
b           = int(value(leftstr(rightstr(loc,long-posvirg1),posvirg2-posvirg1-1)))
c           = int(value(leftstr(rightstr(loc,long-posvirg2),posvirg3-posvirg2-1)))
d           = int(value(rightstr(loc,long-posvirg3)))
""")


# crop of the part of the image where is the logo + mask creation
# ================================================================


cropped     = clp.crop(a,b,c,d)
in          = (RGB32 == true) ? cropped : cropped.converttoRGB24()
in2         = (spd   == true) ? in.SelectRangeEvery (every=20, length=speed) : in

Masque      = imagesource(mask,start=0,end=1).converttoRGB32
Masque      = Masque.crop(a,b,c,d).levels(127,1,128,0,255)
Masque      = Masque.mask(Masque)

BlendedMask = Masque.DirtyBlur().levels(0,1,75,0,255)
BlendedMask = BlendedMask.mask(BlendedMask)
RepairMask  = BlendedMask.levels(0,1,255,0,pp)
RepairEdge  = Masque.DirtyBlur().levels(0,1,255,0,900)
RepairEdge  = RepairEdge.DirtyBlur().levels(0,1,75,0,pp)


# check for an existing computed mask. If it doesn't exist or if reset = true --> computation
# ===========================================================================================


ID          = mask + "InpaintFunc" + string(a) + string(b) + string(c) + string(d) + string(speed)

Logo        = (reset == true) ? eval("""

              in2.analyzelogo(Masque).trim(0,-1).converttoRGB32
              imagewriter(ID,0,1,"ebmp")
              
              """) : eval("""

              try
               
              {imagesource(ID + "%06d.ebmp",0,0)}
              catch (dummy)
               
              {in2.analyzelogo(Masque).trim(0,-1).converttoRGB32
              imagewriter(ID,0,1,"ebmp")      }""")


# Creation of the masks used for DeblendLogo and InpaintLogo 
# ==========================================================


LogoColor   = Logo.Crop(0,0,0,Logo.Height/2).converttoRGB24

LogoAlpha   = Logo.Crop(0,Logo.Height/2,0,0)
Logoalpha   = LogoAlpha.mask(LogoAlpha)

LogoInpaint = LogoAlpha.mask(masque.dirtyblur().levels(0,1,32,0,255))


# InpaintLogo and DeblendLogo are applied depending on the value of "mode"
# ==========================================================================


repaired    = (mode ==  "both")   ?
\             in.DeblendLogo(LogoColor,LogoAlpha).
\             InpaintLogo(LogoInpaint,radius=radius,sharpness=sharpness,preblur=preblur,postblur=postblur,PixelAspect=PAR).converttorgb32:
\             (mode == "deblend") ?
\             in.DeblendLogo(Logocolor,Logoalpha).converttorgb32 : 
\             in.InpaintLogo(LogoInpaint,radius=radius,sharpness=sharpness,preblur=preblur,postblur=postblur,PixelAspect=PAR).converttorgb32


# Finalization of the repaired with post-processing
# ==========================================================


repairedpp  = (ppmode == 1) ? repaired.layer(repaired.DirtyBlur( ).mask(RepairMask))              :
\             (ppmode == 2) ? repaired.layer(repaired.DirtyBlur(2).mask(RepairMask))              : 
\             (ppmode == 3) ? repaired.layer(repaired.DirtyBlur(2).DirtyBlur().mask(RepairEdge))  : repaired


output      = in.converttorgb32.Layer(repairedpp.Mask(BlendedMask))


# Overlay of the cleaned portion over the original clip
# =====================================================


(show == true) ? Eval("""

cropped     = cropped.subtitle("source").converttoRGB32
masque      = masque.subtitle("mask")

repairmask  = repairmask.subtitle("repair mask")
repairedge  = repairedge.subtitle("repair edge")

Logoalpha   = Logoalpha.subtitle("Logo alpha")
Logocolor   = Logocolor.subtitle("Logo color").converttoRGB32
Logoinpaint = Logoinpaint.subtitle("Logo inpaint")

repaired    = repaired.subtitle("repaired")
repairedpp  = repairedpp.subtitle("repaired pp")

l1          = Stackhorizontal(cropped,repaired,repairedpp)
l2          = Stackhorizontal(masque,repairmask,repairedge)
l3          = Stackhorizontal(logocolor,logoalpha,logoinpaint)

stackvertical (l1,l2,l3)
return spline36resize(last,width(last),height(last))

""") : Eval("""


clp         = (RGB32 == true) ? clp : clp.converttoRGB32
fullclip    = clp.layer(output,x=a, y=b)
fullclip    = (RGB == true) ? (RGB32 == true) ? fullclip : fullclip.converttoRGB24() : (YUY2 == true) ? fullclip.converttoYUY2() : fullclip.converttoYV12()
return fullclip
""")

}


#==========================================================================================================
#==========================================================================================================
#==========================================================================================================


function InpaintAssist ( clip clp, string "loc", string "alignment")

{


loc         = default (loc,  "")
x           = width   (clp)
y           = height  (clp)
alignment        = default (alignment, "top")
align       = (alignment == "top") ? 8 : (alignment == "center") ? 5 : (alignment == "bottom") ? 2 :8
framecount  = framecount(clp)


# I "Loc" parameter is not specified, split the clip in 9 parts et show crop value for each part
# ==============================================================================================


loc == ""     ? Eval("""

white       = blankclip(width=round(x/3),height=round(y/3),color=$FFFFFF,length=framecount)
black       = blankclip(width=round(x/3),height=round(y/3),color=$000000,length=framecount)

l1          = stackhorizontal(white,black,white)
l2          = stackhorizontal(black,white,black)
background  = stackvertical(l1,l2,l1).converttoRGB32.spline36resize(x,y)
clp         = clp.converttoRGB32

a1          = string(0)
a2          = string(round((x*1/6))*2)
a3          = string(round((x*1/3))*2)

b1          = string(0)
b2          = string(round((y*1/6))*2)
b3          = string(round((y*1/3))*2)

ca1         = string(-round((x*1/3))*2)
ca2         = string(-round((x*1/6))*2)
ca3         = string(0)

d1          = string(-round((y*1/3))*2)
d2          = string(-round((y*1/6))*2)
d3          = string(0)

c1          = clp.crop(0               , 0          , -round((x*1/3))*2, -round((y*1/3))*2)
\             .subtitle("TL (" + a1 + ","  + b1 + ","  + ca1 + ","  + d1+ ")",align=8) 
c2          = clp.crop(round((x*1/6))*2, 0          , -round((x*1/6))*2, -round((y*1/3))*2)
\             .subtitle("TC (" + a2 + ","  + b1 + ","  + ca2 + ","  + d1+ ")",align=8)
c3          = clp.crop(round((x*1/3))*2, 0          , 0                , -round((y*1/3))*2)
\             .subtitle("TR (" + a3 + ","  + b1 + ","  + ca3 + ","  + d1+ ")",align=8)

c4          = clp.crop(0               , round((y*1/6))*2 , -round((x*1/3))*2, -round((y*1/6))*2)
\             .subtitle("ML (" + a1 + ","  + b2 + ","  + ca1 + ","  + d2+ ")",align=8)
c5          = clp.crop(round((x*1/6))*2, round((y*1/6))*2 , -round((x*1/6))*2, -round((y*1/6))*2)
\             .subtitle("MC (" + a2 + ","  + b2 + ","  + ca2 + ","  + d2+ ")",align=8)
c6          = clp.crop(round((x*1/3))*2, round((y*1/6))*2 , 0                , -round((y*1/6))*2)
\             .subtitle("MR (" + a3 + ","  + b2 + ","  + ca3 + ","  + d2+ ")",align=8)

c7          = clp.crop(0               , round((y*1/3))*2, -round((x*1/3))*2,  0)
\             .subtitle("BL (" + a1 + ","  + b3 + ","  + ca1 + ","  + d3+ ")",align=8)
c8          = clp.crop(round((x*1/6))*2, round((y*1/3))*2, -round((x*1/6))*2,  0)
\             .subtitle("BC (" + a2 + ","  + b3 + ","  + ca2 + ","  + d3+ ")",align=8)
c9          = clp.crop(round((x*1/3))*2, round((y*1/3))*2, 0                ,  0)
\             .subtitle("BR (" + a3 + ","  + b3 + ","  + ca3 + ","  + d3+ ")",align=8)

output      = stackvertical(stackhorizontal(c1,c2,c3), stackhorizontal(c4,c5,c6), stackhorizontal(c7,c8,c9))
output      = output.spline36resize(x,y)
clip1       = background.layer(output.mask(blankclip(output,color=$DEDEDE)))


""") : nop


# If "Loc" is specified, hightlight the part choosen by user
# ==========================================================


(strlen(loc) == 2) ? Eval("""

a           = (Rightstr(loc,1) == "L" || Rightstr(loc,1) == "1") ? 0 : (Rightstr(loc,1) == "C" || Rightstr(loc,1) == "2")  ? round((x*1/6))*2  : round((x*1/3))*2
b           = (leftstr(loc,1)  == "T" || leftstr(loc,1)  == "X") ? 0 : (leftstr(loc,1)  == "M" || leftstr(loc,1)  == "Y")  ? round((y*1/6))*2  : round((y*1/3))*2
c           = (Rightstr(loc,1) == "R" || Rightstr(loc,1) == "3") ? 0 : (Rightstr(loc,1) == "C" || Rightstr(loc,1) == "2")  ? -round((x*1/6))*2  : -round((x*1/3))*2
d           = (leftstr(loc,1)  == "B" || leftstr(loc,1)  == "Z") ? 0 : (leftstr(loc,1)  == "M" || leftstr(loc,1)  == "Y")  ? -round((y*1/6))*2  : -round((y*1/3))*2

             """) : (strlen(loc) != 0) ? eval("""

long        = StrLen(loc)
posvirg1    = findstr(loc, ",")
posvirg2    = findstr(rightstr(loc,long-posvirg1), ",")
posvirg2    = posvirg2+posvirg1
posvirg3    = findstr(rightstr(loc,long-posvirg2), ",")
posvirg3    = posvirg3  + posvirg2

a           = int(value(leftstr(loc,posvirg1-1)))
b           = int(value(leftstr(rightstr(loc,long-posvirg1),posvirg2-posvirg1-1)))
c           = int(value(leftstr(rightstr(loc,long-posvirg2),posvirg3-posvirg2-1)))
d           = int(value(rightstr(loc,long-posvirg3)))

              """) : nop


(loc != "") ? eval("""

hightlight  = blankclip(width=x-a+c,height=y-b+d,color=$96ff2d).converttoRGB32
clip2       = clp.converttoRGB32.layer(hightlight.Mask(blankclip(hightlight, color=$444444)),x=a,y=b)
return        clip2.subtitle("Crop value : "  + string(a) +", " +string(b) +", " +string(c) +", " +string(d), align=align, size=20  )

              """) : clip1


return last
}


#==========================================================================================================
#==========================================================================================================
#==========================================================================================================



function dirtyblur(clip clp, int "mode")

{
mode = default (mode, 1)

o    = (mode == 1) ? clp.blur(1.58).GeneralConvolution (matrix="40 75 40 75 100 75 40 75 40").blur(1.58).blur(1.58).blur(1.58) : 
\                    clp.converttoYUY2.temporalsoften(1,64,64,mode=2,scenechange=6).spatialsoften(2,255,255).converttoRGB32

return o}