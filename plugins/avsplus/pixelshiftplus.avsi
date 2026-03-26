################################################################################
# PixelShiftPlus v1.1.0 (2022/12/10)
# Script to independently shift pixels with subpixel accuracy.
# It includes 4 functions:
# * PixelShiftRGB – shift any plane in an RGB(A) clip.
# * PixelShiftYUV – shift any plane in a YUV(A) clip.
# * PixelShiftUV – shift the chroma in a YUV(A) clip. Similar to ChromaShiftSP2.
# * PixelShiftC – uniformly shifts the chroma in a YUV(A) clip.
#
# http://avisynth.nl/index.php/PixelShiftPlus
# author: reel.deel
#
# REQUIREMENTS
# ************
# AviSynth+ v3.7.2 or greater
# FillBorders v1.3.0 or greater (optional)
################################################################################

/*
SYNTAX and PARAMETERS
**********************
PixelShiftRGB (clip input, float "RX", float "RY", float "GX", float "GY",
              float "BX", float "BY", float "AX", float "AY", string "Resizer",
              int "Mode", bool "Inverse")

PixelShiftYUV (clip input, float "YX", float "YY", float "UX", float "UY",
               float "VX", float "VY", float "AX", float "AY", string "Resizer",
               bool "ChromaPixels", int "Mode", bool "Inverse")

PixelShiftUV (clip input, float "UX", float "UY", float "VX", float "VY",
              string "Resizer", bool "ChromaPixels", int "Mode", bool "Inverse")

PixelShiftC (clip input, float "X", float "Y",
             string "Resizer", bool "ChromaPixels", int "Mode", bool "Inverse")

input:
-----
    Input clip.
    PixelShiftRGB: all RGB(A) colorspaces are supported.
    PixelShiftY(UV): all YUV(A) colorspaces are supported.

RX, RY, GX, GY, BX, BY, AX, AY:
YX, YY, UX, UY, VX, VY, AX, AY:
-------------------------------
    Specify the shift amount in each (R, G, B, A) or (Y, U, V, A) plane.
    * (X) horizontal shift: positive values shift left, negative values right.
    * (Y) vertical shift: positive values shift upwards, negative values downwards.
    Note that the shifting direction will be reversed if Inverse=true.
    Default: 0.0 (all)

Resizer:
--------
    Resizer to use to shift planes.
    Available options: "Bicubic", "Bilinear", "Blackman","Gauss", "Lanczos",
    "Lanczos4", "Point", "Sinc", "Spline16", "Spline36", "Spline64".
    Note that "Point" cannot do subpixel shifting because it uses only integer
    pixel coordinates, float values will be rounded.
    Default: "Spline36"

ChromaPixels:
-------------
    By default, the X and Y shift values of the chroma planes are shifted in
    "luma pixels", meaning that the shift values are divided by the subsampling
    ratio of the input clip. For example:
    * YUV420, the X and Y shift values are divided by 2 since the chroma planes
      are half the width and height of the luma plane.
    * YUV422 or YUV411, only the X shift value is divided by 2 and 4, respectively.
    * YUV444, has no effect since the chroma planes are the same size as the luma.
    When set to true, the X and Y shift values are not divided.
    Default: false

Mode:
-----
    Border mode:
    * 0 : "fillmargins" - top and bottom borders are filled with a weighted
          average of its three neighbours from the previous line. Left and right
          borders are repeated, as in mode 1.
    * 1 : "repeat" - fills the borders using the outermost line or column.
    * 2 : "mirror" - fills the borders by mirroring.
    * 3 : "reflect" - fills the borders by reflecting (whole sample symmetric).
    * 4 : "wrap" - fills the borders by wrapping.
    * 5 : "fade" - fills the borders to constant value.
    * 6 : "fixborders" - A direction "aware" modification of FillMargins. It
          also works on all four sides.
    Default: 1 (all other modes require the FillBorders plugin)

Inverse:
--------
    If true, it will reverse the shifting direction:
    * (X) horizontal shift: negative values shift left, positive values right.
    * (Y) vertical shift: negative values shift upwards, positive values downwards.
    Default: False

################################################################################*/

#/////////////////////////////////
# RGB pixel shifting function
function PixelShiftRGB (clip input, float "RX", float "RY", float "GX", float "GY", \
                                    float "BX", float "BY", float "AX", float "AY", \
                                    string "Resizer", int "Mode", bool "Inverse")
{
    Assert((IsRGB(input)), "PixelShiftRGB: input clip must be RGB(A)")
    PixelShiftPlus(input, plane1X=RX, plane1Y=RY, plane2X=GX, plane2Y=GY, \
                          plane3X=BX, plane3Y=BY, plane4X=AX, plane4Y=AY, \
                          Resizer=Resizer, Mode=Mode, Inverse=Inverse)
}
#/////////////////////////////////
# YUV pixel shifting function
function PixelShiftYUV (clip input, float "YX", float "YY", float "UX", float "UY", \
                                    float "VX", float "VY", float "AX", float "AY", \
                                    string "Resizer", bool "ChromaPixels", int "Mode", bool "Inverse")
{
    Assert((!IsRGB(input)), "PixelShiftYUV: input clip must be YUV(A)")
    PixelShiftPlus(input, plane1X=YX, plane1Y=YY, plane2X=UX, plane2Y=UY, \
                          plane3X=VX, plane3Y=VY, plane4X=AX, plane4Y=AY, \
                          Resizer=Resizer, ChromaPixels=ChromaPixels, Mode=Mode, Inverse=Inverse)
}
#/////////////////////////////////
# UV pixel shifting function
function PixelShiftUV (clip input, float "UX", float "UY", float "VX", float "VY", \
                                   string "Resizer", bool "ChromaPixels", int "Mode", bool "Inverse")
{
    Assert((IsYUV(input) || IsYUVA(Input)), "PixelShiftUV: input clip must be YUV(A)")
    PixelShiftPlus(input, plane2X=UX, plane2Y=UY, plane3X=VX, plane3Y=VY, Resizer=Resizer, \
                          ChromaPixels=ChromaPixels, Mode=Mode, Inverse=Inverse)
}
#/////////////////////////////////
# Uniform UV pixel shifting function
function PixelShiftC (clip input, float "X", float "Y", \
                                  string "Resizer", bool "ChromaPixels", int "Mode", bool "Inverse")
{
    Assert((IsYUV(input) || IsYUVA(Input)), "PixelShiftUV: input clip must be YUV(A)")
    PixelShiftPlus(input, plane2X=X, plane2Y=Y, plane3X=X, plane3Y=Y, Resizer=Resizer, \
                          ChromaPixels=ChromaPixels, Mode=Mode, Inverse=Inverse)
}
#/////////////////////////////////
# General pixel shifting function
function PixelShiftPlus (clip input, float "plane1X", float "plane1Y", float "plane2X", float "plane2Y", \
                                     float "plane3X", float "plane3Y", float "plane4X", float "plane4Y", \
                                     string "Resizer", bool "ChromaPixels", int "Mode", bool "Inverse")
{
    p1X  = Default(plane1X, 0.0)
    p1Y  = Default(plane1Y, 0.0)
    p2X  = Default(plane2X, 0.0)
    p2Y  = Default(plane2Y, 0.0)
    p3X  = Default(plane3X, 0.0)
    p3Y  = Default(plane3Y, 0.0)
    p4X  = Default(plane4X, 0.0)
    p4Y  = Default(plane4Y, 0.0)
    rzr  = Default(Resizer, "Spline36")
    uvp  = Default(ChromaPixels, false)
    mode = Default(Mode, 1)
    inv  = Default(Inverse, false)

    # Sanity checks
    Assert((mode >= 0 && mode <= 6), "PixelShiftPlus: mode must be [0,6]")

    # General properties
    w = Width(input)
    h = Height(input)
    Alpha_ = HasAlpha(input)
    IsRGB_ = IsRGB(input)
    IsRGBI = (IsRGB_ && IsInterleaved(input))
    IsYUV_ = (IsYUV(input) || IsYUVA(input))

    # Rerverse the shift values
    if (inv) {
        p1X = (p1X < 0) ? abs(p1X) : -p1X
        p1Y = (p1Y < 0) ? abs(p1Y) : -p1Y
        p2X = (p2X < 0) ? abs(p2X) : -p2X
        p2Y = (p2Y < 0) ? abs(p2Y) : -p2Y
        p3X = (p3X < 0) ? abs(p3X) : -p3X
        p3Y = (p3Y < 0) ? abs(p3Y) : -p3Y
        p4X = (p4X < 0) ? abs(p4X) : -p4X
        p4Y = (p4Y < 0) ? abs(p4Y) : -p4Y
    }

    # Pixel shifting
    if (IsY(input)) {
        if (mode!=1) {
            # Determine border values
            p1LB = (p1X < 0) ? abs(Round(p1X)) : 0
            p1RB = (p1X > 0) ? Round(p1X) : 0
            p1TB = (p1Y < 0) ? abs(Round(p1Y)) : 0
            p1BB = (p1Y > 0) ? Round(p1Y) : 0
        }

        # Use PointResize when the X/Y shift is whole
        rzr1 = (Fmod(p1X, 1.0)==0 && Fmod(p1Y, 1.0)==0) ? "Point" : rzr

        # Shifting and borders
        p1 = (p1X==0 && p1Y==0) ? input : input.Eval(+ rzr1 + "Resize(w, h, src_left=p1X, src_top=p1Y)")
        Return (mode==1) ? p1 : p1.FillBorders(left=p1LB, top=p1TB, right=p1RB, bottom=p1BB, mode=mode)
    }
    else {
        # Get colorspace (minus alpha) and also converts interleaved format names to their planar equivalents
        csp = (IsRGB_) ? BuildPixelType(family="RGB", sample_clip=input) \
                       : BuildPixelType(family="YUV", sample_clip=input)

        if (IsYUV_ && !Is444(Input)) {

            # Determine chroma subsampling ratio
            hss = (IsYV411(input)) ? 4 : 2
            vss = (Is420(input))   ? 2 : 1

            # Calculate chroma dimensions based on subsampling
            wc = (hss==1) ? w : Int(w / hss)
            hc = (vss==1) ? h : Int(h / vss)

            # Convert chroma pixels to luma pixels
            p2X = (hss==1 || uvp) ? p2X : Float(p2X / hss)
            p2Y = (vss==1 || uvp) ? p2Y : Float(p2Y / vss)
            p3X = (hss==1 || uvp) ? p3X : Float(p3X / hss)
            p3Y = (vss==1 || uvp) ? p3Y : Float(p3Y / vss)
        }
        else {
            wc = w
            hc = h
        }

        # Use PointResize when the X/Y shift is whole
        rzr1 = (Fmod(p1X, 1.0)==0 && Fmod(p1Y, 1.0)==0) ? "Point" : rzr
        rzr2 = (Fmod(p2X, 1.0)==0 && Fmod(p2Y, 1.0)==0) ? "Point" : rzr
        rzr3 = (Fmod(p3X, 1.0)==0 && Fmod(p3Y, 1.0)==0) ? "Point" : rzr
        rzr4 = (Fmod(p4X, 1.0)==0 && Fmod(p4Y, 1.0)==0) ? "Point" : rzr

        if (mode!=1) {
            # Determine border values
            p1LB = (p1X < 0) ? abs(Round(p1X)) : 0
            p1RB = (p1X > 0) ? Round(p1X) : 0
            p1TB = (p1Y < 0) ? abs(Round(p1Y)) : 0
            p1BB = (p1Y > 0) ? Round(p1Y) : 0
            p2LB = (p2X < 0) ? abs(Round(p2X)) : 0
            p2RB = (p2X > 0) ? Round(p2X) : 0
            p2TB = (p2Y < 0) ? abs(Round(p2Y)) : 0
            p2BB = (p2Y > 0) ? Round(p2Y) : 0
            p3LB = (p3X < 0) ? abs(Round(p3X)) : 0
            p3RB = (p3X > 0) ? Round(p3X) : 0
            p3TB = (p3Y < 0) ? abs(Round(p3Y)) : 0
            p3BB = (p3Y > 0) ? Round(p3Y) : 0
            p4LB = (p4X < 0) ? abs(Round(p4X)) : 0
            p4RB = (p4X > 0) ? Round(p4X) : 0
            p4TB = (p4Y < 0) ? abs(Round(p4Y)) : 0
            p4BB = (p4Y > 0) ? Round(p4Y) : 0
        }

        # Extract planes based on color format
        p1 = (IsYUV_) ? ExtractY(input) : ExtractR(input)
        p2 = (IsYUV_) ? ExtractU(input) : ExtractG(input)
        p3 = (IsYUV_) ? ExtractV(input) : ExtractB(input)
        p4 = (Alpha_) ? ExtractA(input) : p1

        # Shifting
        p1 = (p1X==0 && p1Y==0) ? p1 : p1.Eval(+ rzr1 + "Resize(w,  h,  src_left=p1X, src_top=p1Y)")
        p2 = (p2X==0 && p2Y==0) ? p2 : p2.Eval(+ rzr2 + "Resize(wc, hc, src_left=p2X, src_top=p2Y)")
        p3 = (p3X==0 && p3Y==0) ? p3 : p3.Eval(+ rzr3 + "Resize(wc, hc, src_left=p3X, src_top=p3Y)")
        p4 = (p4X==0 && p4Y==0) ? p4 : p4.Eval(+ rzr4 + "Resize(w,  h,  src_left=p4X, src_top=p4Y)")

        if (mode!=1) {
            # Borders
            p1 = p1.FillBorders(left=p1LB, top=p1TB, right=p1RB, bottom=p1BB, mode=mode)
            p2 = p2.FillBorders(left=p2LB, top=p2TB, right=p2RB, bottom=p2BB, mode=mode)
            p3 = p3.FillBorders(left=p3LB, top=p3TB, right=p3RB, bottom=p3BB, mode=mode)
            p4 = p4.FillBorders(left=p4LB, top=p4TB, right=p4RB, bottom=p4BB, mode=mode)
        }

        # Combines planes and add alpha, if needed
        out = (IsYUV_) ? CombinePlanes(p1, p2, p3, planes="YUV", source_planes="YYY", pixel_type=csp) \
                       : CombinePlanes(p1, p2, p3, planes="RGB", source_planes="YYY", pixel_type=csp)
        out = (Alpha_) ? AddAlphaPlane(out, p4) : out

        # Output and convert originally interleaved formats back to interleaved, if needed
        Return (IsRGBI) ? ConvertToRGB(out) : (IsYUY2(input)) ? ConvertToYUY2(out) : out
    }
}
