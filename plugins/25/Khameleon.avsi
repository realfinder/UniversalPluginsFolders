# Khameleon: bidirectional masking cleaner
# version 1.1, 16/02/2018
# Based in DeHaloH, thanks to the authors!
# Developed by GMJCZP
#
# Requirements: TCannyMod, RGTools, MaskTools2, TUnsharp

# SUGGESTIONS FOR CLEANING/RESTORING

# - Suggestions for restoring edges:
# denoised = input.Deen("a2d", 2, 10  , 0, 0, 0, 0, 0) (used by default by DeHaloH)
# denoised = input.frfun7(1.01,3.0,0).frfun3b(s=8,T=3,tuv=7).Deen("a2d", 2, 5  , 0, 0, 0, 0, 0)
# denoised = input.frfun7(1.01,14,0).fft3dfilter(sigma=3,sigma2=3.25,sigma3=3.5,sigma4=6).Deen("a2d", 2, 10  , 0, 0, 0, 0, 0)
# denoised = input.fft3dfilter(sigma=3,sigma2=3.25,sigma3=3.5,sigma4=6).Deen("a2d", 2, 15  , 0, 0, 0, 0, 0)

# - Suggestions for inner cleaning:
# denoised = input.Temporalsoften(2,3,3,mode=2,scenechange=6)
# denoised = input.dfttest(sigma=2, tbsize=1)

Function Khameleon(clip denoised, clip input, int "DR_Radius", bool "Maska", int "mode",
\ bool "edge", bool "focus", int "str_focus", float "gamma", float "cont", bool "sobel")
{
 edge       = Default(edge, true)
 mode       = Default(mode, edge ? 0 : 1)
 Maska      = Default(Maska, false)
 DR_Radius  = Default(DR_Radius, 0)
 focus      = Default(focus, false)
 str_focus  = Default(str_focus, 40)
 gamma      = Default(gamma, 1.0) # 2.0 for inner cleaning is interesting
 cont       = Default(cont, 1.0)
 sobel      = Default(sobel, false)

 Assert(!(edge == true && gamma <> 1.0), "Gamma values can only be varied for inner cleaning")
 Assert((mode == 0 || mode == 1), "Wrong value for mode")
 Assert(!(focus == true && edge == false), "Focus = true: only valid for edge=true")

 EM = mode == 0 ? input.Camembert2() : input.tweak(cont=cont).TCannyMod(sobel=sobel)

 input_low    = 1
 gamma        = gamma
 input_high   = 128
 output_low   = 255
 output_high  = 0

 lmask = input.mt_lut(Yexpr = "x " +string(input_low)+ " - " +string(input_high)+ " " +string(input_low)+ " - / 1 " +string(gamma)+
    \        " / ^ " +string(output_high)+ " " +string(output_low)+ " - * " +string(output_low)+ " +", U=2,V=2).invert().RemoveGrain(12)#.blur(0.5)

 RM = DR_Radius(EM,DR_Radius,0)
 full = mt_logic(RM, lmask, "and")
 full = edge ? full :  full.Invert().mt_deflate().mt_binarize(threshold=192)
 
 # For blurring edges
 denoised = (edge == true && focus == true) ? denoised.spline16Resize(int(width(input)*1.5),int(height(input)*1.5)).tunsharp(str_focus,type=5).spline16Resize(width(input),height(input)) 
    \ : denoised

 denoised = Maska ? denoised.Invert() : denoised
return mt_merge(input, denoised, full) 
}

function Camembert2(clip input)
{
input
a=RemoveGrain(12,-1).RemoveGrain(12,-1)
mt_makediff(a,input)
#input
#a=RemoveGrain(12).RemoveGrain(12)
#mt_adddiff(input,mt_makediff(a,input))
mt_lut("x 128 - abs 2 *")
greyscale()
mt_lut(Yexpr = "X 0 - 115 0 - / 1 1.0 / ^ 255 0 - * 0 +", U=2,V=2)
RemoveGrain(12)
mt_lut(Yexpr = "X 0 - 64  0 - / 1 0.4 / ^ 255 0 - * 0 +", U=2,V=2)
RemoveGrain(12)
RemoveGrain(12)
mt_lut(Yexpr = "X 0 - 30  0 - / 1 1.0 / ^ 255 0 - * 0 +", U=2,V=2)
RemoveGrain(12)
return (last)
}