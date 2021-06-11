###                                                            ##
###                                                            ##
###                     2.4            (15-04-2015)            ##
### Mask functions Pack 2.62 By Dogway (20-05-2021)            ## Updated BoxMask() and LumaMask() to internal functions (faster and HBD support)
###                                                            ##
### https://forum.doom9.org/showthread.php?t=182881            ##
###                                                            ##
#################################################################


##################
###
### BoxMask
###
###
### Creates a rectangular mask so you can use it in merging operations or custom filtering in localized areas.
###
###
###########################


function BoxMask(clip clp, int "x1", int "x2", int "y1", int "y2", bool "inverse", bool "show", bool "matchformat") {

x1	    = Default(x1,0)
x2	    = Default(x2,0)
y1	    = Default(y1,0)
y2	    = Default(y2,0)
upper   = Default(inverse, false)
show    = Default(show, false)
format  = Default(matchformat, true)

bdpth = BitsPerComponent(clp)

LetterBox(BlankClip(clp,1,pixel_type="Y"+string(bdpth),color_yuv=upper?$000000:$ffffff).killaudio(),y1,height(clp)-y2,x1,width(clp)-x2,color_yuv=upper?$ffffff:$000000)
format ? MatchColorFormat(clp) : last

softlight="y range_max / A^ x range_max / B^ 1.0 2.0 A * - B 2.0 ^ * 2.0 B A * * + range_max *"
!show ? last : expr(clp,last,softlight) }


##################
###
### FlatMask
###
### 10-06-2011
### by cretindesalpes: (http://forum.doom9.org/showthread.php?p=1507257#post1507257)
### HBD mod
###
### Blends original with filtered (e.g. denoised) clip by masking out flat areas with weak, small or no detail.
### Useful for denoising cel animation while protecting detailed backgrounds.
### If you just want the mask itself use the 'show' parameter, it will be useable for masking operations as well.
###
### Use like this:
###
### raw=last
### YourFilter()
### flatmask(raw)
###
###
### Requires:
### Masktools2: http://forum.doom9.org/showthread.php?t=98985
###
###########################

function FlatMask(clip filtered, clip raw, float "str",int "r",  bool "luma", float "Lth", bool "upper", bool "show", bool "notemp", bool "extend") {
sisavs26=!(VersionNumber() < 2.6)

 raw   = default(raw, filtered)

 exten = default(extend, false)
 str   = string(default(str, exten ? 10 : 6)) # Strength of the mask, the higher -> more detail protection
 r     = default(r, exten ? 2 : 3)            # Mask blurriness

 luma  = default(luma,true)                   # Enables dark zones to be masked out (for filtering) independent of detail
 th    = default(Lth,75)                      # Start of penumbra for masking when luma=true

 upper = default(upper, false)                # Inverts the mask
 show  = default(show,  false)                # Shows the mask
 notem = default(notemp, exten)

c4ma = exten ? filtered : raw

e1 = c4ma.mt_edge (mode="prewitt", thY1=0, thY2=255)
e2 = c4ma.mt_edge (mode="min/max", thY1=0, thY2=255)
mt_makediff (e1, e2)
sisavs26 ? mt_lut ("x range_half - 0 max range_size / 0.25 ^ range_size *", scale_inputs="floatf", use_expr=2) : mt_lut ("x 128 - 0 max 256 / 0.25 ^ 256 *")
mt_deflate ().mt_deflate ()

luma ? mt_logic(c4ma.mt_binarize(threshold=sisavs26 ? th : round(th)),"min") : last

w = width ()
h = height ()

BicubicResize (w / (r*2) * 2, h / (r*2) * 2, 1, 0)
notem ? last : TemporalSoften (2, 20, 255)
mt_expand ().mt_inpand ().mt_inpand (mode="both")
BicubicResize (w, h, 1, 0)

var  = show  ? 128 : 1
code = sisavs26 ? upper ? "range_max x 10 scalef - "+str+" * -" : "x 10 scalef - "+str+" *" : upper ? "255 x 10 - "+str+" * -" : "x 10 - "+str+" *"
msk  = sisavs26 ? mt_lut (code,u=var,v=var,use_expr=2,clamp_float=true) : mt_lut (code,u=var,v=var)
msk  = exten ? !upper ? msk.mt_invert().mt_expand().mt_expand().mt_invert().mt_inpand().mt_inpand() : msk.mt_expand() : msk
show ? msk : mt_merge(filtered,raw,msk,luma=true, y=3, u=3, v=3)}



##############################################################
###                                                          #
### LumaMask() (11-01-2014)                                  #
###                                                          #
##############################################################
###
### Function by Didée, adapted by Dogway:
### http://forum.doom9.org/showpost.php?p=761786&postcount=3
###
###
### Mixes 2 versions of a source by a mask defined by luminosity (Luma Plane)
###
###
### filtered [default: last]
### -------------------
### By default the input of the function is assumed as filtered
###
###
### raw [default: filtered]
### -------------------
### Define where you want to create the mask from, and thus blend with the filtered clip.
###
###
### b [default: 24]
### -------------------
### Limit for 100% black in your mask. [0...255]
###
###
### W [default: 48]
### -------------------
### Limit for 100% white in your mask. [0...255]
###
###
### upper [default: false]
### -------------------
### Inverts the mask. By default filtered clip will be passed through the white parts of the mask.
###
###
### smooth [default: false]
### -------------------
### Denoises some nervious grain on the mask so it doesn't have a negative effect on the mask/blending.
###
###
### show [default: false]
### -------------------
### Shows the mask, which you can directly use with any masking operations on your own.
###_______________________
###                       |
### Example:              |
###  raw=last             |
###  YourFilter()         |
###  LumaMask(raw)        |
###_______________________|
###
###   This will pass the filtered version of the clip only in the brightest part of the image,
###   starting where luma pixel value is 24 bright and smoothed up to 100% bypass from 48 brightness value onwards.
###   Useful to protect dark/bright areas from certain filters.
###
##############################################################


function LumaMask(clip filtered, clip raw, int "b", int "w", bool "upper", bool "smooth", bool "show") {

raw      = default(raw, filtered)

LO       = string(default(b, 24))
HI       = string(default(w, 48))
upper    = default(upper,  false)
smooth   = default(smooth, false)
show     = default(show,   false)

contoy   = !isy(filtered)
cplane   = contoy ? "range_half" : Undefined

code     = upper ? "x "+LO+" scalef < range_max x "+HI+" scalef > 0 range_max x "+LO+" scalef -   range_max "+HI+" scalef "+LO+" scalef - / * - ? ?" : \
                   "x "+LO+" scalef < 0         x "+HI+" scalef >   range_max 0 x "+LO+" scalef - range_max "+LO+" scalef "+HI+" scalef - / * - ? ?"

msk      = expr(raw,code,cplane,cplane,scale_inputs="floatf")
msk      = smooth ? msk.removegrain(22,0) : msk
msk

show  ?  msk : ex_merge(raw,filtered,msk,1) }
