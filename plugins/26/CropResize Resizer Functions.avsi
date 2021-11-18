# ===============================================================================
# ========== Resizer Wrapper Functions 2021-10-22 ===============================
# ===============================================================================
#
#  PLEASE NOTE: Any resizers or resizer wrapper functions used with CropResize must accept
#  cropping arguments as float, and for wrapper functions, the cropping arguments must be included.
#  Without the ability to apply sub-pixel cropping with a resizer, the script's cropping won't be accurate.
#
#  The included wrapper functions for Avisynth resizers with optional arguments are:
#  CR_Bicubic(), CR_Blackman(), CR_Gauss(), CR_Lanczos() and CR_Sinc().
#  The included wrapper functions for AVSResize/z.lib resizers with optional arguments are:
#  CR_ZBicubic() and CR_ZLanczos().
#  Also Included are wrapper functions for three additional third partly resizing scripts/plugins:
#  CR_Resize16X(), CR_ResampleHQ() and CR_Resize8().
#
#  The wrapper functions can easily be modified to specify or change any optional resizer arguments.
#  Should you wish to use a resizer with different settings on occasion, make a copy of the appropriate wrapper
#  function and add the copy to the script, change it's default options and give the function a unique name.
#  Configuring resizer options can be achieved via the CropResize RStr argument since version 2021-10-15,
#  however the wrapper functions are still included as sometimes it's a more convenient method.
#
# ===============================================================================
# ========== CR_Bicubic() - BicubicResize Wrapper Function ======================
# ===============================================================================

function CR_Bicubic(clip Source, int target_width, int target_height, \
float "src_left", float "src_top", float "src_width", float "src_height", float "B", float "C")  {

# The defaults are B=1.0/3.0 and C=1.0/3.0
# Uncommenting the two lines below and changing their values will change the defaults.

# B = default(B, 1.0/3.0)
# C = default(C, 1.0/3.0)

BicubicResize(Source, target_width, target_height, \
src_left=src_left, src_top=src_top, src_width=src_width, src_height=src_height, b=B, c=C)  }

# ===============================================================================
# ========== CR_Blackman() - BlackmanResize Wrapper Function ====================
# ===============================================================================

function CR_Blackman(clip Source, int target_width, int target_height, \
float "src_left", float "src_top", float "src_width", float "src_height", int "Taps")  {

# The default for Taps is 4
# Uncomment the line below and replace 4 to set a different default for Taps.

# Taps = default(Taps, 4)

BlackmanResize(Source, target_width, target_height, \
src_left=src_left, src_top=src_top, src_width=src_width, src_height=src_height, taps=Taps)  }

# ===============================================================================
# ========== CR_Gauss() - GaussResize Wrapper Function ==========================
# ===============================================================================

function CR_Gauss(clip Source, int target_width, int target_height, \
float "src_left", float "src_top", float "src_width", float "src_height", float "P")  {

# The default for P is 30.0
# Uncomment the line below and replace 30.0 to set a different default for P.

# P = default(P, 30.0)

GaussResize(Source, target_width, target_height, \
src_left=src_left, src_top=src_top, src_width=src_width, src_height=src_height, p=P)  }

# ===============================================================================
# ========== CR_Lanczos() - LanczosResize Wrapper Function ======================
# ===============================================================================

function CR_Lanczos(clip Source, int target_width, int target_height, \
float "src_left", float "src_top", float "src_width", float "src_height", int "Taps")  {

# The default for Taps is 3
# Uncomment the line below and replace 3 to set a different default for Taps.

# Taps = default(Taps, 3)

LanczosResize(Source, target_width, target_height, \
src_left=src_left, src_top=src_top, src_width=src_width, src_height=src_height, taps=Taps)  }

# ===============================================================================
# ========== CR_Sinc() - SincResize Wrapper Function ============================
# ===============================================================================

function CR_Sinc(clip Source, int target_width, int target_height, \
float "src_left", float "src_top", float "src_width", float "src_height", int "Taps")  {

# The default for Taps is 4
# Uncomment the line below and replace 4 to set a different default for Taps.

# Taps = default(Taps, 4)

SincResize(Source, target_width, target_height, \
src_left=src_left, src_top=src_top, src_width=src_width, src_height=src_height, taps=Taps)  }

# ===============================================================================
# ========== CR_ZBicubic() - z_BicubicResize Wrapper Function ===================
# ===============================================================================

function CR_ZBicubic(clip Source, int target_width, int target_height, \
float "src_left", float "src_top", float "src_width", float "src_height", float "B", float "C")  {

# The defaults are B=1.0/3.0 and C=1.0/3.0
# Uncommenting the two lines below and changing their values will change the defaults.

# B = default(B, 1.0/3.0)
# C = default(C, 1.0/3.0)

z_ConvertFormat(Source, target_width, target_height, \
src_left=src_left, src_top=src_top, src_width=src_width, src_height=src_height, \
resample_filter="Bicubic", filter_param_a=B, filter_param_b=C)  }

# ===============================================================================
# ========== CR_ZLanczos() - z_LanczosResize Wrapper Function ===================
# ===============================================================================

function CR_ZLanczos(clip Source, int target_width, int target_height, \
float "src_left", float "src_top", float "src_width", float "src_height", int "Taps")  {

# The default for Taps is 3
# Uncomment the line below and replace 3 to set a different default for Taps.

# Taps = default(Taps, 3)

z_ConvertFormat(Source, target_width, target_height, \
src_left=src_left, src_top=src_top, src_width=src_width, src_height=src_height, \
resample_filter="Lanczos", filter_param_a=Taps)  }

# ===============================================================================
# ========== CR_Resize16X() - ResizeX Wrapper (16 bit resizing of 8 bit video) ==
# ===============================================================================

# ResizeX script https://github.com/realfinder/AVS-Stuff/blob/master/avs 2.6 and up/ResizeX.avsi
# ResizeX dependency https://github.com/realfinder/AVS-Stuff/blob/Community/avs 2.5 and up/Zs_RF_Shared.avsi

# Requires the Dithertools plugin for resizing 8 bit video in stacked 16 bit
# http://avisynth.nl/index.php/Dither_tools

# As "lsb" is uncommented and set to true below, the clip is converted to stacked 16 bit, resized, then
# dithered back to 8 bit

# Enabling "lsb_out" below will double the height of the output clip due to the stacked 16 bit output, and
# affect CropResize's ability to add borders, color correct and calculate the correct output display aspect
# ratio, although the copping and resizing should still be correct

# ResizeX also supports all Avisynth+ bitdepths.

function CR_Resize16X(clip Source, int target_width, int target_height, \
float "src_left", float "src_top", float "src_width", float "src_height", \
string "kernel", int "taps", float "a1", float "a2", string "cplace", bool "luma", bool "chroma", \
bool "lsb_in", bool "lsb", bool "mt", string "mt_params", string "dither_params", \
bool "lsb_out", bool "desampling", int "dither_mode")  {

# Uncomment any line below and replace "xxx" to set a preferred default.

# kernel = default(kernel, xxx)
# taps = default(taps, xxx)
# a1 = default(a1, xxx)
# a2 = default(a2, xxx)
# cplace = default(cplace, xxx)
# cplace = default(cplace, xxx)
# luma = default(luma, xxx)
# chroma = default(chroma, xxx)
   lsb = default(lsb, true)
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
# ========== CR_ResampleHQ() - ResampleHQ Wrapper Function ======================
# ===============================================================================

# ResampleHQ 32 bit: https://forum.doom9.org/showthread.php?t=160038
# ResampleHQ 64 bit: https://forum.doom9.org/showthread.php?p=1722300#post1722300

function CR_ResampleHQ(clip Source, int target_width, int target_height, \
string "dstcolorspace", string "srcmatrix", string "dstmatrix", bool "dither", \
float "src_left", float "src_top", float "src_width", float "src_height", \
string "kernel", float "karg1", float "karg2", float "kblur_x", float "kblur_y", \
string "chroma_kernel", float "chroma_karg1", float "chroma_karg2")  {

# Uncomment any line below and replace "xxx" to set a preferred default.

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
# ========== CR_Resize8() - Resize8 Wrapper Function ============================
# ===============================================================================

# Updated HBD version. https://forum.doom9.org/showthread.php?t=183057
# Corrects the slight chroma shift caused by Avisynth's resizers.
# Includes ringing repair.
# Requires RgTools
# http://avisynth.nl/index.php/RgTools

# The original Resize8 function http://avisynth.nl/index.php/Resize8
# (no longer works with this wrapper function).

function CR_Resize8(clip Source, int "target_width", int "target_height", \
float "src_left", float "src_top", float "src_width", float "src_height", \
string "kernel", string "kernel_c", float "a1", float "a2", float "a1_c", float "a2_c", \
val "noring", val "noring_c", string "cplace", bool "Y", bool "U", bool "V", bool "alpha", \
bool "chroma", string "rstr", string "rstr_c", bool "separate", bool "show")  {

# The Resize8 defaults for resizing kernels are "Lanczos4" for luma upscaling and "Lanczos" for chroma upscaling.
# "Spline36" is the default for both luma and chroma downscaling.
# For the updated HBD Resize8 linked to above, "kernel" sets both the luma and chroma resizers, unless "kernel_c"
# is used to specify something else for chroma.

# Uncomment any line below and replace "xxx" to set a preferred default.

# kernel = default(kernel, xxx)
# kernel_c = default(kernel_c, xxx)
# a1 = default(a1, xxx)
# a2 = default(a2, xxx)
# a1_c = default(a1_c, xxx)
# a2_c = default(a2_c, xxx)
# noring = default(noring, false)
# noring_c = default(noring_c, false)
# cplace = default(cplace, xxx)
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
noring=noring, noring_c=noring_c, cplace=cplace, Y=Y, U=U, V=V, alpha=alpha, \
chroma=chroma, rstr=rstr, rstr_c=rstr_c, separate=separate, show=show)  }

# ===============================================================================
# ===============================================================================
# ===============================================================================