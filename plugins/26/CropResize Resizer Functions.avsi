# ===============================================================================
# ===============================================================================
#            CropResize Resizer Wrapper Functions 2023-10-28
# ===============================================================================
# ===============================================================================
#
#  PLEASE NOTE: Any resizers or resizer wrapper functions used with CropResize must accept
#  cropping arguments as float, and for wrapper functions, the cropping arguments must be
#  included. Without the ability to apply cropping with a resizer, the script's cropping
#  and resizing won't be accurate.
#
#  Included wrapper functions:
#
#  For the Avisynth resizers with optional arguments:
#  CR_Bicubic(), CR_Blackman(), CR_Gauss(), CR_Lanczos() and CR_Sinc().
#
#  For 16 bit linear light resizing:
#  CR_AVSResize(), CR_DitherToolsLinear(), CR_FMTConvLinear() and CR_ResampleHQ().
#
#  For the Resize8 and ResizeX scripts:
#  CR_Resize8() and CR_ResizeX().
#
#  The wrapper functions can easily be modified to specify or change any optional resizer arguments.
#  Should you wish to use a resizer with different settings on occasion, make a copy of the appropriate wrapper
#  function and add the copy to the script, change it's default options and give the function a unique name.
#
# ===============================================================================
# ===============================================================================
#            Avisynth Wrapper Functions
# ===============================================================================
# ===============================================================================

# ===============================================================================
#            CR_Bicubic
# ===============================================================================

function CR_Bicubic(clip Source, int target_width, int target_height, \
float "src_left", float "src_top", float "src_width", float "src_height", float "B", float "C")  {

# The defaults are B=1.0/3.0 and C=1.0/3.0
# Uncomment the following 2 lines to change the defaults
# B = default(B, 1.0/3.0)
# C = default(C, 1.0/3.0)

BicubicResize(Source, target_width, target_height, \
src_left=src_left, src_top=src_top, src_width=src_width, src_height=src_height, b=B, c=C)  }

# ===============================================================================
#            CR_Blackman
# ===============================================================================

function CR_Blackman(clip Source, int target_width, int target_height, \
float "src_left", float "src_top", float "src_width", float "src_height", int "Taps")  {

# The default for Taps is 4
# Uncomment the following line to set a new default for Taps
# Taps = default(Taps, 4)

BlackmanResize(Source, target_width, target_height, \
src_left=src_left, src_top=src_top, src_width=src_width, src_height=src_height, taps=Taps)  }

# ===============================================================================
#            CR_Gauss
# ===============================================================================

function CR_Gauss(clip Source, int target_width, int target_height, \
float "src_left", float "src_top", float "src_width", float "src_height", float "P")  {

# The default for P is 30.0
# Uncomment the following line to set a new default for P
# P = default(P, 30.0)

GaussResize(Source, target_width, target_height, \
src_left=src_left, src_top=src_top, src_width=src_width, src_height=src_height, p=P)  }

# ===============================================================================
#            CR_Lanczos
# ===============================================================================

function CR_Lanczos(clip Source, int target_width, int target_height, \
float "src_left", float "src_top", float "src_width", float "src_height", int "Taps")  {

# The default for Taps is 3
# Uncomment the following line to set a new default for Taps
# Taps = default(Taps, 3)

LanczosResize(Source, target_width, target_height, \
src_left=src_left, src_top=src_top, src_width=src_width, src_height=src_height, taps=Taps)  }

# ===============================================================================
#            CR_Sinc
# ===============================================================================

function CR_Sinc(clip Source, int target_width, int target_height, \
float "src_left", float "src_top", float "src_width", float "src_height", int "Taps")  {

# The default for Taps is 4
# Uncomment the following line to set a new default for Taps
# Taps = default(Taps, 4)

SincResize(Source, target_width, target_height, \
src_left=src_left, src_top=src_top, src_width=src_width, src_height=src_height, taps=Taps)  }

# ===============================================================================
# ===============================================================================
#            CR_AVSResizeLinear - 16 Bit Linear Light Resizing
# ===============================================================================
# ===============================================================================
#
#  Requires Avisynth+.
#  AVSResize plugin http://avisynth.nl/index.php/Avsresize
#
# -------------------------------------------------------------------------------

function CR_AVSResizeLinear(clip Source, int Width, int Height, \
float "src_left", float "src_top", float "src_width", float "src_height", \
string "Kernel", val "Param_A", val "Param_B", string "KernelC", val "ParamC_A", val "ParamC_B", \
string "Chromaloc", string "Chromaloc_Out", bool "Full", bool "Full_Out", int "Out_Bits", string "Format")  {

# -------------------------------------------------------------------------------

# Kernel  -  The resizing method (default "Spline36").
# KernelC  -  The resizer for upscaling/downscaling YUV subsampled chroma (default "Bicubic").
# Chromaloc, Chromaloc_Out  -  Chromaloc is applied to Chromaloc_Out unless Chromaloc_Out is specified.

# Full, Full_Out - True for full range (RGB default), false for limited range (YUV default).
# Full is applied to Full_Out unless Full_Out is specified.

# Format - Source color format for YUV. Used for conversion to linear light (default, "HD").
# "UHD" (rec.2020 standard dynamic range), "HD" (rec.709), "PAL" (rec.601, PAL primaries) or
# "NTSC" (rec.601, NTSC primaries).

  Kernel = default(Kernel, "Spline36")
  KernelC = default(KernelC, "Bicubic")
# Param_A = default(Param_A, xxx)
# Param_B = default(Param_B, xxx)
# ParamC_A = default(ParamC_A, xxx)
# ParamC_B = default(ParamC_B, xxx)
  Out_Bits = default(Out_Bits, BitsPerComponent(Source))
# Chromaloc = default(Chromaloc, IsRGB(Source) ? "center" : "left")
# Chromaloc_Out = default(Chromaloc_Out, Chromaloc)
  Full = default(Full, IsRGB(Source))
  Full_Out = default(Full_Out, Full)
  Format = default(Format, "HD")

# -------------------------------------------------------------------------------

Assert(defined(Chromaloc) || !defined(Chromaloc_Out), " CR_AVSResizeLinear " + chr(10) + \
" Chromaloc must be defined when Chromaloc_Out is defined " + chr(10))
Assert((Format == "RGB") || (Format == "UHD") || (Format == "HD") || \
(Format == "PAL") || (Format == "NTSC"), " CR_AVSResizeLinear " + chr(10) + \
" Chromaloc must be defined when Chromaloc_Out is defined " + chr(10))

RangeIn = Full ? "full" : "limited"
RangeOut = Full_Out ? "full" : "limited"

ColorA = IsRGB(Source) ? "rgb:srgb:709:" + RangeIn + "=>rgb:linear:709:full" : \
(Format == "UHD") ? "2020:2020:2020:" + RangeIn + "=>rgb:linear:xyz:full" : \
(Format == "HD") ? "709:709:709:" + RangeIn + "=>rgb:linear:709:full" : \
(Format == "PAL") ? "470bg:601:470bg:" + RangeIn + "=>rgb:linear:470bg:full" : \
(Format == "NTSC") ? "470bg:601:170m:" + RangeIn + "=>rgb:linear:170m:full" : nop()

ColorB = IsRGB(Source) ? "rgb:linear:709:full=>rgb:srgb:709:" + RangeOut : \
(Format == "UHD") ? "rgb:linear:xyz:full=>2020:2020:2020:" + RangeOut : \
(Format == "HD") ? "rgb:linear:709:full=>709:709:709:" + RangeOut : \
(Format == "PAL") ? "rgb:linear:470bg:full=>470bg:601:470bg:" + RangeOut : \
(Format == "NTSC") ? "rgb:linear:170m:full=>470bg:601:170m:" + RangeOut : nop()

Chromaloc = defined(Chromaloc) && defined(Chromaloc_Out) ? Chromaloc + "=>" + Chromaloc_Out : \
defined(Chromaloc) ? Chromaloc + "=>" + Chromaloc : undefined()

RGBType = HasAlpha(Source) ? "RGBAP" : "RGBP"
Chroma = Is420(Source) ? 420 : Is422(Source) ? 422 : Is444(Source) ? 444 : undefined()
Family = \
IsRGB(Source) ? HasAlpha(Source) ? "RGBA" : "RGB" : IsY(Source) ? "Y" : HasAlpha(Source) ? "YUVA" : "YUV"

OutType = BuildPixelType(family=Family, bits=Out_Bits, chroma=Chroma)

return Source.z_ConvertFormat(pixel_type=RGBType+string(16), chromaloc_op=Chromaloc, \
colorspace_op=ColorA, resample_filter=KernelC, filter_param_a=ParamC_A, filter_param_b=ParamC_B)\
.z_ConvertFormat(width, height, src_left=src_left, src_top=src_top, src_width=src_width, \
src_height=src_height, resample_filter=Kernel, filter_param_a=Param_A, filter_param_b=Param_B)\
.z_ConvertFormat(pixel_type=OutType, chromaloc_op=Chromaloc, colorspace_op=ColorB, \
resample_filter=KernelC, filter_param_a=ParamC_A, filter_param_b=ParamC_B)  }

# ===============================================================================
# ===============================================================================
#            CR_DitherToolsLinear - 16 Bit Linear Light Resizing
# ===============================================================================
# ===============================================================================
#
#  Supports YV12, YV16, YV24, YV411 & Y8.
#  DitherTools plugin http://avisynth.nl/index.php/Dither_tools
#
# -------------------------------------------------------------------------------

function CR_DitherToolsLinear(clip Source, \
int Width, int Height, float "src_left", float "src_top", float "src_width", float "src_height", \
string "Kernel", string "CurveS", string "CurveD", float "GammaS", float "GammaD", \
bool "SigmoidS", bool "SigmoidD", float "ThrS", float "ThrD", float "ContS", float "ContD", \
string "CPlaceS", string "CPlaceD", int "DitherMode", bool "Slice")  {

# Uncomment and/or change the lines below to set new defaults.

# Kernel = default(Kernel, "Spline36")
  CurveS = default(CurveS, "709")
  CurveD = default(CurveD, CurveS)
# GammaS = default(GammaS, xxx)
# GammaD = default(GammaD, xxx)
# SigmoidS = default(SigmoidS, false)
# SigmoidD = default(SigmoidD, SigmoidS)
# ThrS = default(ThrS, xxx)
# ThrD = default(ThrD, ThrS)
# ContS = default(ContS, xxx)
# ContD = default(ContD, ContS)
# CPlaceS = default(CPlaceS, "MPEG2")
# CPlaceD = default(CPlaceD, CPlaceS)
  DitherMode = default(DitherMode, 6)
  Slice = default(Slice, false)

Source.Dither_convert_8_to_16()\
.Dither_y_gamma_to_linear(curve=CurveS, gcor=GammaS, sigmoid=SigmoidS, thr=ThrS, cont=ContS)\
.Dither_resize16(Width, Height, src_left, src_top, src_width, src_height, \
kernel=Kernel, cplaces=CPlaceS, cplaced=CPlaceD)\
.Dither_y_linear_to_gamma(curve=CurveD, gcor=GammaD, sigmoid=SigmoidD, thr=ThrD, cont=ContD)\
.DitherPost(mode=DitherMode, slice=Slice)  }

# ===============================================================================
# ===============================================================================
#            CR_FMTConvLinear - 16 Bit Linear Light Resizing
# ===============================================================================
# ===============================================================================
#
#  Requires Avisynth+
#  FMTConv plugin:
#  http://avisynth.nl/index.php/Fmtconv
#
# -------------------------------------------------------------------------------

function CR_FMTConvLinear(clip Source, int Width, int Height, \
float "src_left", float "src_top", float "src_width", float "src_height", \
int "out_bits", string "mat", string "trans", bool "full", string "kernel", int "taps", val "a1", val "a2")  {

Source_Bits = BitsPerComponent(Source)

# mat  -  the matrix used for converting YUV to linear RGB and back.
# trans  -  the transfer function for converting YUV to linear RGB and back.
# full  -  YUV only, true for full range, false for limited range.

  out_bits = default(out_bits, Source_Bits)
  mat = default(mat, "709")
  trans = default(trans, "709")
  full = default(full, false)
# kernel = default(kernel, "spline36")
# taps = default(taps, xxx)
# a1 = default(a1, xxx)
# a2 = default(a2, xxx)

Input = (Source_Bits == 16) ? Source : Source.fmtc_bitdepth(bits=16)
Input = Is444(Input) ? Input : Input.fmtc_resample(css="444")

Resized = !IsRGB(Source) ? \
Input.fmtc_matrix(mat=mat, fulls=full, fulld=true, bits=16)\
.fmtc_transfer(transs=trans, transd="linear")\
.fmtc_resample(width, height, sx=src_left, sy=src_top, sw=src_width, sh=src_height, \
kernel=Kernel, taps=taps, a1=a1, a2=a2)\
.fmtc_transfer(transs="linear", transd=trans)\
.fmtc_matrix(mat=mat, fulls=true, fulld=full, bits=16) : \
Input.fmtc_transfer(transs="srgb", transd="linear")\
.fmtc_resample(width, height, sx=src_left, sy=src_top, sw=src_width, sh=src_height, \
kernel=Kernel, taps=taps, a1=a1, a2=a2)\
.fmtc_transfer(transs="linear", transd="srgb")

Output = Is444(Source) || IsRGB(Source) ? Resized : \
Is422(Source) ? Resized.fmtc_resample(css="422") : Resized.fmtc_resample(css="420")

return (BitsPerComponent(Output) == out_bits) ? Output : Output.fmtc_bitdepth(bits=out_bits)  }

# ===============================================================================
# ===============================================================================
#            CR_ResampleHQ - 32 Bit Linear Light Resizing
# ===============================================================================
# ===============================================================================
#
#  Supports YV12, YUY2, RGB24 & RGB32.
#  ResampleHQ plugin http://avisynth.nl/index.php/ResampleHQ
#
# -------------------------------------------------------------------------------

function CR_ResampleHQ(clip Source, int target_width, int target_height, \
string "dstcolorspace", string "srcmatrix", string "dstmatrix", bool "dither", \
float "src_left", float "src_top", float "src_width", float "src_height", \
string "kernel", float "karg1", float "karg2", float "kblur_x", float "kblur_y", \
string "chroma_kernel", float "chroma_karg1", float "chroma_karg2")  {

# Uncomment the lines below and replace "xxx" to set new defaults.

# dstcolorspace = default(dstcolorspace, xxx)
# srcmatrix = srcmatrix(srcmatrix, xxx)
# dstmatrix = default(dstmatrix, xxx)
# dither = default(dither, xxx)
# kernel = default(kernel, xxx)
# karg1 = default(karg1, xxx)
# karg2 = default(karg2, xxx)
# kblur_x = default(kblur_x, xxx)
# kblur_y = default(kblur_y, xxx)
# chroma_kernel = default(chroma_kernel, xxx)
# chroma_karg1 = default(chroma_karg1, xxx)
# chroma_karg2 = default(chroma_karg2, xxx)

ResampleHQ(Source, target_width, target_height, \
dstcolorspace=dstcolorspace, srcmatrix=srcmatrix, dstmatrix=dstmatrix, \
src_left=src_left, src_top=src_top, src_width=src_width, src_height=src_height, \
kernel=kernel, karg1=karg1, karg2=karg2, kblur_x=kblur_x, kblur_y=kblur_y, \
chroma_kernel=chroma_kernel, chroma_karg1=chroma_karg1, chroma_karg2=chroma_karg2)  }

# ===============================================================================
# ===============================================================================
#            CR_Resize8
# ===============================================================================
# ===============================================================================
#
#  Supports all Avisynth+ bitdepths.
#  Corrects the slight chroma shift caused by Avisynth's resizers for sources with sub-sampled chroma.
#
#  Resize8 HBD version https://forum.doom9.org/showthread.php?t=183057
#  Requires RgTools for ringing repair http://avisynth.nl/index.php/RgTools
#
#  The original Resize8 http://avisynth.nl/index.php/Resize8
#  (no longer works with this wrapper function).
#
#  The Resize8 defaults for resizing kernels are "Lanczos4" for luma upscaling and "Lanczos" for chroma upscaling.
#  "Spline36" is the default for both luma and chroma downscaling.
#  For the updated Resize8 HBD version, specifying a resizer with the "kernel" argument configures
#  both the luma and chroma resizing, unless "kernel_c" is specified for the chroma resizer.
#
# -------------------------------------------------------------------------------

function CR_Resize8(clip Source, int "target_width", int "target_height", \
float "src_left", float "src_top", float "src_width", float "src_height", \
string "kernel", string "kernel_c", float "a1", float "a2", float "a1_c", float "a2_c", \
val "noring", val "noring_c", string "cplace", string "cplaced", bool "Y", bool "U", bool "V", \
bool "alpha", bool "chroma", string "rstr", string "rstr_c", bool "separate", bool "show")  {

# Uncomment the lines below and replace "xxx" to set new defaults.

# kernel = default(kernel, xxx)
# kernel_c = default(kernel_c, xxx)
# a1 = default(a1, xxx)
# a2 = default(a2, xxx)
# a1_c = default(a1_c, xxx)
# a2_c = default(a2_c, xxx)
# noring = default(noring, false)
# noring_c = default(noring_c, false)
# cplace = default(cplace, xxx)
# cplaced = default(cplaced, xxx)
# Y = default(Y, xxx)
# U = default(U, xxx)
# V = default(V, xxx)
# alpha = default(alpha, xxx)
# chroma = default(chroma, xxx)
# rstr = default(rstr, xxx)
# rstr_c = default(rstr_c, xxx)
# separate = default(separate, xxx)
# show = default(show, xxx)

Resize8(Source, target_width, target_height, \
src_left=src_left, src_top=src_top, src_width=src_width, src_height=src_height, \
kernel=kernel, kernel_c=kernel_c, a1=a1, a2=a2, a1_c=a1_c, a2_c=a2_c, \
noring=noring, noring_c=noring_c, cplace=cplace, cplaced=cplaced, Y=Y, U=U, V=V, \
alpha=alpha, chroma=chroma, rstr=rstr, rstr_c=rstr_c, separate=separate, show=show)  }

# ===============================================================================
# ===============================================================================
#            CR_Resize16X
# ===============================================================================
# ===============================================================================
#
#  Supports all Avisynth+ bitdepths.
#  Corrects the slight chroma shift caused by Avisynth's resizers for sources with sub-sampled chroma.
#
#  ResizeX script
#  https://github.com/realfinder/AVS-Stuff/blob/master/avs 2.6 and up/ResizeX.avsi
#  ResizeX dependency
#  https://github.com/realfinder/AVS-Stuff/blob/Community/avs 2.5 and up/Zs_RF_Shared.avsi
#  Requires the Dithertools plugin for resizing 8 bit video in stacked 16 bit
#  http://avisynth.nl/index.php/Dither_tools
#
# -------------------------------------------------------------------------------

function CR_Resize16X(clip Source, int target_width, int target_height, \
float "src_left", float "src_top", float "src_width", float "src_height", \
string "kernel", int "taps", float "a1", float "a2", string "cplace", bool "luma", bool "chroma", \
bool "lsb_in", bool "lsb", bool "mt", string "mt_params", string "dither_params", \
bool "lsb_out", bool "desampling", int "dither_mode")  {

# Uncomment the lines below and replace "xxx" to set new defaults.
# If "lsb" is uncommented and true below, 8 bit video is converted to
# stacked 16 bit, resized, then dithered back to 8 bit.

# kernel = default(kernel, xxx)
# taps = default(taps, xxx)
# a1 = default(a1, xxx)
# a2 = default(a2, xxx)
# cplace = default(cplace, xxx)
# cplace = default(cplace, xxx)
# luma = default(luma, xxx)
# chroma = default(chroma, xxx)
# lsb = default(lsb, true)
# lsb_in = default(lsb_in, xxx)
# lsb_out = default(lsb_out, xxx)
# mt = default(mt, xxx)
# mt_params = default(mt_params, xxx)
# dither_params = default(dither_params, xxx)
# desampling = default(desampling, xxx)
# dither_mode = default(dither_mode, xxx)

ResizeX(Source, target_width, target_height, \
src_left=src_left, src_top=src_top, src_width=src_width, src_height=src_height, \
kernel=kernel, taps=taps, a1=a1, a2=a2, cplace=cplace, luma=luma, chroma=chroma, \
lsb_in=lsb_in, lsb=lsb, mt=mt, mt_params=mt_params, dither_params=dither_params, \
lsb_out=lsb_out, desampling=desampling, dither_mode=dither_mode)  }

# ===============================================================================
# ===============================================================================
