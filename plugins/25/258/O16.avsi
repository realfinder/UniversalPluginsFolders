#############################################################################################
###                                                                                       ###
### O16 & Down10 v1.6.0: output 16 bit clip using "dither", "f3kdb" or "SmoothAdjust.dll" ###
### original script by 06_taro, modified by mawen1250                                     ###
###                                                                                       ###
#############################################################################################
###
### Changelog:
### 2013.01.05 mod v1.6.0 - Add U10 and Round10, speed optimization, using some functions from "dither" tool
### 2012.04.03 v1.5.2     - Add LowDepth for fun, not fully implemented ( full range and speed optimization )
### 2012.03.25 v1.5.1     - Down10 now can directly output interleaved msb/lsb high bit depth clip
### 2012.03.14 v1.5.0     - Synchronize argument names with parameter names of f3kdb v1.5.0
### 2011.11.08 v1.3.2     - Replace all "dither" fuctions by "f3kdb"
###                         now it should be faster and uses less memory
###                         especially directly output high bit clip from TV range 8-bit clips with default settings
### 2011.11.05 v1.3.1     - Adjust f3kdb arguments to f3kdb version 1.4.1 and later
### 2011.10.31 v1.3 final - Use f3kdb to dither down, the result is more accurate
###                       - Separate TV range and PC range algorithm, and ensure that conversion is correct
###                       - Fix a bug in dithering down
###                       - Add U16 and C16
### 2011.09.27 v1.3 alpha - Rename "bitdepth" to "depth"
###                       - Add "dither" and "smooth", dangerous, no accuracy guaranteed
###                         Set "dither=-1, smooth=0" if you want old funcion, which does not apply any dithering or smoothing
###                       - Separate bit-depth downscaling function to "Down10()"
###                       - Restrict "depth" to [9, 16] in O16 and [8,16] in Down10
### 2011.08.11 v1.2       - "bitdepth" restricted up to 16
### 2011.08.09 v1.1       - Add "bitdepth" parameter to output self-defined bit depth
### 2011.08.05 v1.0       - First Script
###
###################################################################################################################################
###
### Requirements:
### "dither"       - [ 1.22.0 ~ ] : http://forum.doom9.org/showthread.php?p=1386559#post1386559
### "f3kdb"        - [ 1.5.0 ~  ] : http://forum.doom9.org/showthread.php?t=161411
### "SmoothAdjust" - [ 2.00  ~  ] : http://forum.doom9.org/showthread.php?t=154971
###
###################################################################################################################################
###
### Usage:
###
### O16     - get 8-bit input clip,
###         - process with 16-bit post-processing filters,
###         - OUTPUT interleaved 9-16 bit output,
###         - which can be passed to x264 directly.
###         - I will not add 8-bit output support in O16,
###         - since more checking in parameters will slow down O16 funcion and "U16().pp.Down10(8)" can easily do the same thing.
### ------------
### input   - input clip, must be 8-bit clip.
###         - Defualt: not set
### depth   - output bit depth, range from 9 to 16.
###         - Defualt: 16
### pp      - 16-bit precision post-processing defined by yourself.
###         - Defualt: not set ( no pp )
### dither  - use dithering if output is a non 16-bit clip and either "pp" is defined or tvRange is false,
###         - explaination and strength defined in SmoothAdjust,
###         - when value is -2, use Ordered dithering,
###         - when value is -3, use Floyd-Steinberg dithering.
###         - when value is -4, use Dither_quantize instead of f3kdb.
###         - Default: -1 if output 16-bit clip or no pp applied, otherwise -3 for TV range and 50 for PC range
### ditherm - Dithering method for DitherPost/Dither_quantize:
###         - -1	no dither, round to the closest value
###         - 0		8-bit ordered dither + noise.
###         - 1		1-bit dither
###         - 2		2-bit dither, light
###         - 3		2-bit dither, medium
###         - 4		2-bit dither, strong
###         - 5		2-bit dither, stronger
###         - 6		Serpentine Floyd-Steinberg error diffusion + noise. Well-balanced algorithm.
###         - 7		Stucki error diffusion + noise. Looks “sharp” and preserve light edges and details well.
###         - 8		Atkinson error diffusion + noise. Generates distinct patterns but keeps clean the flat areas.
### smooth  - use gradient smoothing if defined "pp" and output is a non 16-bit clip,
###         - explaination and strength defined in SmoothAdjust,
###         - do NOT have effect if dither<-1 or dither==-1 but input is TV range.
###         - Default: 0
### tvRange - processe the clip as TV Range or not.
###         - Default: true
###
### ----------------------------------------------------------
###
### Down10  - get stacked 16-bit input clip and convert it DOWN to 8-16 bit output.
### ------------
### clp     - input clip, must be 16-bit clip.
###         - Defualt: not set
### depth   - output bit depth, range from 8 to 16.
###         - Defualt: 10
### dither  - use dithering if output is a non 16-bit clip,
###         - when value is in [-1, 100], explaination and strength defined in SmoothAdjust,
###         - when value is -2, use Ordered dithering,
###         - when value is -3, use Floyd-Steinberg dithering.
###         - when value is -4, use Dither_quantize instead of f3kdb.
###         - Default: -3 for TV range and 50 for PC range
### ditherm - Dithering method for DitherPost/Dither_quantize:
###         - -1	no dither, round to the closest value
###         - 0		8-bit ordered dither + noise.
###         - 1		1-bit dither
###         - 2		2-bit dither, light
###         - 3		2-bit dither, medium
###         - 4		2-bit dither, strong
###         - 5		2-bit dither, stronger
###         - 6		Serpentine Floyd-Steinberg error diffusion + noise. Well-balanced algorithm.
###         - 7		Stucki error diffusion + noise. Looks “sharp” and preserve light edges and details well.
###         - 8		Atkinson error diffusion + noise. Generates distinct patterns but keeps clean the flat areas.
### smooth  - use gradient smoothing if output is a non 16-bit clip,
###         - explaination and strength defined in SmoothAdjust,
###         - do NOT have effect if dither<-1 or dither==-1 but input is TV range.
###         - Default: 0
### tvRange - processe the clip as TV Range or not.
###         - Default: true
### stack   - output stacked msb/lsb (true) or interleaved msb/lsb (false).
###         - Default: true
###
### ----------------------------------------------------------
###
### U16     - get 8-bit input clip and UP-convert it to stacked/interleaved 16 bit output.
### ------------
### c       - input clip, must be 8-bit clip.
###         - Defualt: not set
### tvRange - processe the clip as TV Range or not.
###         - Default: true
### stack   - output stacked msb/lsb (true) or interleaved msb/lsb (false).
###         - Default: true
###
### ----------------------------------------------------------
###
### C16     - get stacked input clip and CONVERT it to interleaved output, the same as Dither_convey_yuv4xxp16_on_yvxx.
### ------------
### c       - input clip.
###         - Defualt: not set
###
### ----------------------------------------------------------
###
### U10     - get 8-bit input clip and UP-convert it to stacked/interleaved 8-16 bit output.
### ------------
### c       - input clip, must be 8-bit clip.
###         - Defualt: not set
### depth   - output bit depth, range from 8 to 16.
###         - Defualt: 10
### tvRange - processe the clip as TV Range or not.
###         - Default: true
### stack   - output stacked msb/lsb (true) or interleaved msb/lsb (false).
###         - Default: true
###
### ----------------------------------------------------------
###
### Round10 - get stacked 16-bit tvRange input clip and convert it Down to stacked 8-16 bit output with Rounding.
### ------------
### c       - input clip, must be stacked 16-bit tvRange clip.
###         - Defualt: not set
### depth   - output bit depth, range from 8 to 16.
###         - Defualt: 10
###
###################################################################################################################################
### 
### Sample 1 (simply output 16-bit, no pp): 
### AviSource(sample.avi)
### O16()
### 
### Sample 2 (simply output 10-bit, no pp): 
### AviSource(sample.avi)
### O16(10)
### 
### Sample 3 (output 16-bit after pp): 
### AviSource(sample.avi)
### O16(pp="Dither_resize16(1280, 720)")
### 
### Sample 4 (output 16-bit after multi-step pp, with """three quotes""" inside String pp):
### AviSource(sample.avi)
### pp16=
### \ """Dither_resize16(648, 480, 4, 0, -5, 0, kernel="spline64")
### \ Dither_crop16(4, 0, -4, 0)"""
### O16(pp=pp16)
### 
### Sample 5 (another example, exactly the same with Sample 4):
### AviSource(sample.avi)
### O16(pp=
### \ """Dither_resize16(648, 480, 4, 0, -5, 0, kernel="spline64")
### \ Dither_crop16(4, 0, -4, 0)""")
### 
### Sample 6 (another example, exactly the same with Sample 4, using custom-defined function):
### AviSource(sample.avi)
### O16(pp="CustomPP()")
### FUNCTION CustomPP(clip input){
###   tmp=input.Dither_resize16(648, 480, 4, 0, -5, 0, kernel="spline64")
###   pped=tmp.Dither_crop16(4, 0, -4, 0)
###   return pped
### }
### 
### Sample 7 (output 10-bit after pp, using dithering): 
### AviSource(sample.avi)
### O16(10, pp="Dither_resize16(1280, 720)", dither=0)
### 
### Sample 8 (output 8-bit after pp in 16-bit precision):
### AviSource(sample.avi)
### U16()
### Dither_resize16(1280, 720)
### Down10(8)
###
###################################################################################################################################

FUNCTION O16( clip input, int "depth", string "pp", int "dither", int "ditherm", int "smooth", bool "tvRange" ){
  
  Defined(depth) ? Assert( depth>8 && depth<=16 , """O16: "depth" ranges from 9 to 16!""") : nop()
  
  depth   = Default( depth,     16 )
  smooth  = Default( smooth,     0 )
  tvRange = Default( tvRange, true )
  dither  = tvRange ? Default(dither, -3) : Default(dither, 50) # use dither or not, -4 use Dither_quantize instead of f3kdb
  ditherm = Default( ditherm,    6 ) # dither mode for DitherPost/Dither_quantize

  Assert( depth>8 && depth<=16      , """O16: "depth" ranges from 9 to 16!"""    )
  Assert( dither>=-4 && dither<=100 , """O16: "dither" ranges from -4 to 100!""" )
  Assert( ditherm>=-1 && ditherm<=8 , """O16: "ditherm" ranges from -1 to 8!"""  )
  Assert( !(dither==-4 && depth==15), """O16: "depth" can't be 15 when "dither" is -4""" )
  
  last = input.U16( tvRange=tvRange )
  pp16 = Defined(pp) ? Eval(pp) : last
  
###  
### The following conversion gives the same result as pp16.Down10.C16,
### but may be a little bit faster when using f3kdb to dither down,
### which is the default dithering method.
###
  
  return  !Defined(pp) ? input.U10( depth=depth, tvRange=tvRange, stack=false ) :
  \      ( depth==16 ) ? pp16.C16() :
  \      pp16.Down10(depth=depth, dither=dither, ditherm=ditherm, smooth=smooth, tvRange=tvRange, stack=false)
}

###################################################################################################################################

Function Down10( clip clp, int "depth", int "dither", int "ditherm", int "smooth", bool "tvRange", bool "stack" ){

  tvRange = Default( tvRange, true )
  depth   = Default( depth,     10 ) # bit-depth of output clip
  smooth  = Default( smooth,     0 ) # use smooth or not
  dither  = tvRange ? Default(dither, -3) : Default(dither, 50) # use dither or not, -4 use Dither_quantize instead of f3kdb
  ditherm = Default( ditherm,    6 ) # dither mode for DitherPost/Dither_quantize
  stack   = Default( stack,   true ) # output stacked msb/lsb or interleaved msb/lsb
  
  Assert( dither>=-4 && dither<=100 , """Down10: "dither" ranges from -4 to 100!""" )
  Assert( ditherm>=-1 && ditherm<=8 , """Down10: "ditherm" ranges from -1 to 8!"""  )
  Assert( depth>=8   && depth<=16   , """Down10: "depth" ranges from 8 to 16!"""    )
  Assert( !(dither==-4 && depth==15), """Down10: "depth" can't be 15 when "dither" is -4""" )
  
  dither  = dither==-4 && depth==15 ? -3 : dither
  
  shift   = int( Pow( 2, depth - 8 ) )
  ycFloor = int( 16  * shift )
  neutral = int( 128 * shift )
  yCeil   = int( 235 * shift )
  cCeil   = int( 240 * shift )
  ycRge   = int( Pow( 2, depth ) - 1 )
  
  yExpr   = tvRange ? ( "0-0;4096-"+String(ycFloor)+";32768-"+String(neutral)+";60160-"+String(yCeil)+";65535-"+String(ycRge) )
  \                 : ( "0-0;65535-"+String(ycRge) )
  cExpr   = tvRange ? ( "0-0;4096-"+String(ycFloor)+";32768-"+String(neutral)+";61440-"+String(cCeil)+";65535-"+String(ycRge) )
  \                 : ( "0-0;65535-"+String(ycRge) )
  
  smoothDown = clp.SmoothCurve16( Ycurve=yExpr, Ucurve=cExpr, Vcurve=cExpr, interp=0, smooth=smooth,
  \                               dither=( (dither>-1) ? dither : -1 ), limiter=false, TVrange=0 )
  
  ditherDown = dither==-4 ? clp.Dither_quantize( depth, reducerange=true, mode=ditherm )
  \          : dither==-1 ? clp.Round10( depth=depth )
  \                       : clp.f3kdb( Y=0, Cb=0, Cr=0, grainY=0, grainC=0, dither_algo=(-dither), input_mode=1,
  \                                    output_depth=depth, output_mode=( (depth>8) ? stack ? 1 : 2 : 0 ) )
  
  down    = ( dither<-1 || ( dither==-1 && smooth==0 && tvRange ) ) ? ( depth==8 ) ? clp.DitherPost( mode=ditherm )
  \                                                                 : (dither>=-3) ? ditherDown
  \                                                                 :   stack      ? ditherDown
  \                                                                                : ditherDown.C16
  \                                                                 : ( depth==8 ) ? smoothDown.Get_lsb()
  \                                                                 :   stack      ? smoothDown
  \                                                                                : smoothDown.C16

  return ( depth==16 ) ? stack ? clp : clp.C16 : down
}

###################################################################################################################################

Function U16( clip c, bool "tvRange", bool "stack" ){ 

  tvRange = Default( tvRange, true )
  stack   = Default( stack,   true )
  
  Expr    = "0-0;128-32768;255-65535;65535-65535"
  
  up      =  tvRange ? c.Dither_convert_8_to_16()
  \                  : StackVertical(c.Gen_null_lsb(), c).SmoothCurve16(Ycurve=Expr, Ucurve=Expr, Vcurve=Expr, interp=0,
  \                                                                     limiter=false, TVrange=0, smooth=0, dither=-1)
  
  return stack ? up : up.Dither_out()
}

###################################################################################################################################

Function C16( clip c ){
  return c.Dither_out()
 }

###################################################################################################################################

Function LowDepth(clip input, int "depth", int "dither", int "ditherm", int "smooth", bool "tvRange"){

  tvRange = Default( tvRange, true )
  depth   = Default( depth,      8 ) # bit-depth of output clip
  smooth  = Default( smooth,     0 ) # use smooth or not
  dither  = tvRange ? Default(dither, -3) : Default(dither, 50) # use dither or not, -4 use Dither_quantize instead of f3kdb
  ditherm = Default( ditherm,    6 ) # dither mode for DitherPost/Dither_quantize

  Assert( dither>=-4 && dither<=100, """LowDepth: "dither" ranges from -4 to 100!""" )
  Assert( depth<=8   && depth>=1   , """LowDepth: "depth" ranges from 1 to 8!"""     )
  
  StackVertical(input.Gen_null_lsb, input)
  Down10(depth=depth+8, dither=dither, ditherm=ditherm, smooth=smooth, tvRange=tvRange)
  Dither_lut16("x "+string(8-depth)+" <<", Y=3, U=3, V=3)
  Get_lsb
}

###################################################################################################################################

Function U10( clip c, int "depth", bool "tvRange", bool "stack" ){

  depth   = Default( depth,     10 )
  tvRange = Default( tvRange, true )
  stack   = Default( stack,   true )
  
  Assert( depth>=8   && depth<=16   , """U10: "depth" ranges from 8 to 16!"""    )
  
  shift   = int( Pow( 2, depth - 8 ) )
  neutral = int( 128 * shift )
  ycRge   = int( Pow( 2, depth ) - 1 )
  Expr    = "0-0;128-"+String(neutral)+";255-"+String(ycRge)+";65535-65535"
  
  upmsb   = c.mt_lut("x " +string(16-depth)+ " >>", U=3, V=3)
  uplsb   = c.mt_lut("x " +string(depth-8 )+ " << x " +string(16-depth)+ " >> 8 << -", U=3, V=3)
  
  tvup    = depth==16 ? c.Dither_convert_8_to_16() : StackVertical(upmsb, uplsb)
  pcup    = StackVertical(c.Gen_null_lsb(), c).SmoothCurve16(Ycurve=Expr, Ucurve=Expr, Vcurve=Expr, interp=0,
  \                                                          limiter=false, TVrange=0, smooth=0, dither=-1)
  
  up      = tvRange ? tvup : pcup

  return depth==8 ? c : stack ? up : up.Dither_out()
}

###################################################################################################################################

Function Round10( clip c, int "depth" ){

  depth   = Default( depth,     10 )
  
  Assert( depth>=8   && depth<=16   , """Round10: "depth" ranges from 8 to 16!"""    )
  
  divisor = int( Pow( 2, 16-depth ) )
  
  return depth==16 ? c : depth==8 ? c.DitherPost(mode=-1) : c.Dither_lut16("x " +String(divisor)+ " /", U=3, V=3)
}

###################################################################################################################################

Function Get_lsb      (clip src){  return src.Crop(0, src.Height/2, src.Width, src.Height/2) }
Function Gen_null_lsb (clip src){  return BlankClip(src, color_yuv=0)                        }