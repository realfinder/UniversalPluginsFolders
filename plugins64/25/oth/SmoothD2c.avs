###
#  This file contains the SmoothD2c() script routine.
#

###
#  REQUIRED ROUTINES
#  
#  aWarpSharp2.dll  available from http://sites.google.com/site/pavelsx2/
#  MaskTools2.dll available   from http://avisynth.org/mediawiki/MaskTools2
#  The following 2 routines are included at the end of this file.  They have been 
#  modified as sugested in http://forum.doom9.org/showthread.php?t=79898 so they 
#  work with MaskTools2.dll
#  Ylevels() and YlevelsS()   see  http://avisynth.org/mediawiki/Ylevels 
#                   available from http://forum.doom9.org/showthread.php?t=79898
###
#  RESTRICTIONS
#  
#  The Input clip must be evenly divisible by 4 in both height and width.

###
#  ARGUMENTS
#
#  SmoothD2c() provides a wrapper around SmoothD2() that takes a clip with the luma deblocked and uses SmoothD2 to deblock the chroma.
#              The arguments quant, num_shift, Matrix, Qtype, and ZW  are the same as those in SmoothD2 and have the same defaults.
#              The arguments Cpr, cWarpToLuma and downSize are specific to SmoothD2c().
#
#              Cpr (0..8) Chroma Protection Strength. Provides control over chroma desaturation at low luma levels. 
#                         It does so by building a SmoothD2 Zero Weight Mask "ZWmask".
#                         Low luma pixels map to high Zero weights in ZWMASK. 
#                         Default 0 no protection 
#                         8 strong protection.  
#
#              cWarpToLuma (0...8) uses aWarpSharp2() to warp the chroma to the luma. Default 0 no warping 8 strong warping.
#                                  This will move the chroma from high luma areas toward strong low luma edges which is
#                                  useful to reduce chroma bleeding.
#                                  Places where the chroma has been moved from may be visibly desaturated.  
#                                  NOTE: The SmoothD2c() argument Cpr will have NO effect on chroma desaturation caused by
#                                  cWarpToLuma. 
#
#              downSize (1...4) This specifies how much the image should be shrunk before deblocking.
#                               Default 1 no downsizing.  
#                                       2 reduce image to 1/2 it's original size before processing.
#                                       3 reduce image to 1/3 it's original size before processing.
#                                       4 reduce image to 1/4 it's original size before processing.
#                               This can be useful if you have really bad chroma blocking. see examples at 
#                               https://sites.google.com/site/jconklin754smoothd2/home
#

###
#  GETTING STARTED
#
#  First all parameters default to reasonable values so SmoothD2c() should work, though it will provide only very weak deblocking.  
#  The most important parameter is quant, which is the primary control of deblocking strength.  
#  If you can not get as much deblocking as desired then try using a different Matrix.  
#     Matrix 8, or Matrix 13-29 
#  If you still can't get enough deblocking then try Qtype=2 or 4.
#  If you still can't get enough deblocking then increase downSize. For Qtype=1 you probably want a Matrix between 13-29.
#  When you get enough deblocking find an area, usually in a darker part of the picture, that the chroma has washed out and start increasing Cpr 
#  until the chroma returns.  Its a balancing act between chroma washout and chroma deblocking.  
#  When you have gotten this far and you have chroma bleeding around strong luma edges then you can try increasing cWarpToLuma 
#  to see if it will help reduce it.  Note that cWarpToLuma especially at higher settings will tend to washout the chroma around the edges.
#  This chroma washout cannot be corrected by increasing Cpr.


###
#  This routine takes a clip that has already had the luma deblocked and uses SmoothD2 to deblock the chroma.
# Defaults SmoothD2c(quant=3, num_shift=3, Matrix=3, Qtype=1, ZW=1, Cpr=0, cWarpToLuma=0, downSize=1, ncpu=1)
Function SmoothD2c(clip clp, int "quant", int "num_shift", int "Matrix", int "Qtype", int "ZW", int "Cpr", int "cWarpToLuma", int "downSize", int "ncpu") {
quant       = default( quant,          3 )  
num_shift   = default( num_shift,      3 )  
Matrix      = default( Matrix,         3 )  
Qtype       = default( Qtype,          1 )  
ZW          = default( ZW,             1 )  
Cpr         = default( Cpr,            0 )  # Chroma Protection Strength aka Chroma Vampire Be Gone
cWarpToLuma = default( cWarpToLuma,    0 ) 
downSize    = default( downSize,       1 ) 
ncpu        = default( ncpu,           1 ) 


Assert( ( quant       >= 1  &&  quant       <=  31 ) ? true : false, chr(10) + "'quant' wrong value! [1-31]" + chr(10))
Assert( ( num_shift   >= 1  &&  num_shift   <=   4 ) ? true : false, chr(10) + "'num_shift' wrong value! [1-4]" + chr(10))
Assert( ( Matrix      >= 1  &&  Matrix      <= 110 ) ? true : false, chr(10) + "'Matrix' wrong value! [1-110]" + chr(10))
Assert( ( Qtype       >= 0  &&  Qtype       <=   4 ) ? true : false, chr(10) + "'Qtype' wrong value! [0-4]" + chr(10))
Assert( ( ZW          >= 0  &&  ZW          <=  16 ) ? true : false, chr(10) + "'ZW' wrong value! [1-16]" + chr(10))
Assert( ( Cpr         >= 0  &&  Cpr         <=   6 ) ? true : false, chr(10) + "'Cpr' wrong value! [0-6]" + chr(10))
Assert( ( cWarpToLuma >= 0  &&  cWarpToLuma <=   8 ) ? true : false, chr(10) + "'cWarpToLuma' wrong value! [0-8]" + chr(10))
Assert( ( downSize    >= 1  &&  downSize    <=   4 ) ? true : false, chr(10) + "'downSize' wrong value! [1-4]" + chr(10))
Assert( ( ncpu        >= 1  &&  ncpu        <=   4 ) ? true : false, chr(10) + "'ncpu' wrong value! [1-4]" + chr(10))
Assert( ( clp.width   == m4(clp.width)             ) ? true : false, chr(10) + "'clip width'  must be a multiple of 4" + chr(10))
Assert( ( clp.height  == m4(clp.height)            ) ? true : false, chr(10) + "'clip height' must be a multiple of 4" + chr(10))

   ow  = clp.width
   oh  = clp.height

   sd1 = clp 

   sd1 = (downSize    > 1) ? sd1.Lanczos4Resize(m32(ow/downSize), m32(oh/downSize)) : sd1
   sd1 = (cWarpToLuma > 0) ? sd1.colorWarpToLuma(strength=cWarpToLuma)    : sd1

   zw1 = (Cpr == 0)  ?  sd1.ylevels( 0, 1.0, 255, 0, 0)  :  sd1.buildZmask(cpr=cpr)                


   u2  = sd1.UToY()
   v2  = sd1.VToY()

   cw   = u2.width
   ch   = u2.height

   zwuv = zw1.Lanczos4Resize(cw, ch)

   u2  = u2.SmoothD2(quant=quant, num_shift=num_shift, Matrix=Matrix, Qtype=Qtype, ZW=ZW, ZWmask=zwuv, ncpu=ncpu) 
   v2  = v2.SmoothD2(quant=quant, num_shift=num_shift, Matrix=Matrix, Qtype=Qtype, ZW=ZW, ZWmask=zwuv, ncpu=ncpu) 

   u2 = (downSize > 1) ? u2.Lanczos4Resize(ow/2, oh/2) : u2
   v2 = (downSize > 1) ? v2.Lanczos4Resize(ow/2, oh/2) : v2

#   u2 = (downSize > 1) ? u2.bicubicResize(ow/2, oh/2) : u2
#   v2 = (downSize > 1) ? v2.bicubicResize(ow/2, oh/2) : v2

   sd1 = YToUV(u2, v2).MergeLuma(clp)

   return(sd1)
}


###
# m4  "mod-4"   see "Crop restrictions" in http://avisynth.org/mediawiki/Crop
#               m4 is used in may scripts that do resizing.
# m8  "mod-8"   is used so that cropping will occur on luma block (8x8) boundaries
#               and that resizing will produce an integer number of luma blocks.
# m16 "mod-16"  is used so that cropping will occur on YV12 chroma block (16x16) boundaries
#               and that resizing will produce an integer number of chroma blocks.
# m16 "mod-m32" is used so that the zw1 mask can be resized to the size of the u and v planes.
function  m4(float x) {return(x<16?16:int(round(x/4.0) *4))}
function  m8(float x) {return(x<16?16:int(round(x/8.0) *8))}
function m16(float x) {return(x<32?32:int(round(x/16.0)*16))}
function m32(float x) {return(x<64?64:int(round(x/32.0)*32))}


###
# 
#  This routine builds a zero Weight Mask 
#  which is used to limit the strength of chroma 
#  processing in dark areas.
#
# Defaults buildZmask(Cpr=1)
function buildZmask(clip clp, int "Cpr") {
Cpr = default( Cpr, 1 )

    clp.SmoothD2(quant=31, num_shift=4, Matrix=29, Qtype=1, ZW=0, ZWce=1, ZWlmDark=0, ZWlmBright=255, ncpu=1) 
    mt_invert()
    YlevelsS(90,1.01,240,0,255) # This does a non linear range expansion see http://forum.doom9.org/showthread.php?t=79898
    mask = mt_invert()

    ZWmask = (Cpr ==  0)  ?  clp                 
\          : (Cpr ==  1)  ?  mask.ylevels(32, 60.0, 255,  8, 0)
\          : (Cpr ==  2)  ?  mask.ylevels(32, 50.0, 255,  16, 0) 
\          : (Cpr ==  3)  ?  mask.ylevels(32, 30.0, 255,  16, 0) 
\          : (Cpr ==  4)  ?  mask.ylevels(32, 12.0, 255,  16, 0) 
\          : (Cpr ==  5)  ?  mask.ylevels(32,  7.0, 255,  16, 0) 
\          :                 mask.ylevels(32,  1.0, 255,  16, 0) 

    return(ZWmask)
}




###
# 
#  This routine moves the color information toward the edges in the luma
#
# Defaults colorWarpToLuma(strength=1)
function colorWarpToLuma(clip clp, int "strength") {
strength = default( strength, 1 )

  thresh = (strength ==  0)  ?    1                   
\        : (strength ==  1)  ?   24
\        : (strength ==  2)  ?   32 
\        : (strength ==  3)  ?   48  
\        : (strength ==  4)  ?   64  
\        : (strength ==  5)  ?   96  
\        : (strength ==  6)  ?  128  
\        : (strength ==  7)  ?  192  
\        :                      255  

    blur = strength + 2
    warpedColor = clp.aWarpSharp2(thresh=thresh, blur=blur, type=1, depth=14, chroma=4)
    mt_merge(clp, clp, warpedColor, y=2, u=5, v=5) 

    return(last)
}


function Ylevels(clip clp, int a, float gamma, int b, int c, int d)
       { wicked="x "+string(a)+" - "+string(b)+" "+string(a)+" - / 1 "+string(gamma)+" / ^ "+string(d)+" "+string(c)+" - * "+string(c)+" +"
        # Reminder: Yexpr = "x a - b a - / 1 gamma / ^ d c - * c +"
        # return( clp.subtitle(wicked) )
        # return( clp.YV12LUT(Yexpr = wicked, U=2,V=2) )  
         return( clp.mt_lut(Yexpr = wicked, U=2,V=2) )  
         }

         
function YlevelsS(clip clp, int a, float gamma, int b, int c, int d)
       { wicked="x "+string(a)+" - "+string(b)+" "+string(a)+" - / 1 "+string(gamma)+" / ^ "+string(d)+" "+string(c)+" - * "+string(c)+" + x 162,97466 / sin 255 * * x 255 x 162,97466 / sin 255 * - * + 255 /"
        # return( clp.YV12LUT(Yexpr = wicked, U=2,V=2) )  
         return( clp.mt_lut(Yexpr = wicked, U=2,V=2) )  
         }

