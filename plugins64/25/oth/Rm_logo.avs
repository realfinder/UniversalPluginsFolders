# rm_logo() Version 0.5 -- 23.04.08
#
# Script to help in the removal of channel logos or other distracting objects
#
# Required filters:
# AVSInpaint: Ver 2008-01-06
#             Discussion & Code : http://forum.doom9.org/showthread.php?t=133682
# ExInpaint:  Ver 0.1+ 
#             Code http://avisynth.org.ru/exinpaint/exinpaint.html
# mt_masktools: Ver 2.0.32+ 
#               Code http://manao4.free.fr/masktools-v2.0a32.zip
# removegrain: Ver 1.0 (8/2005)
#              Code  http://www.removegrain.de.tf 
# fft3dfilter: Ver 2.1.1 or later 
#              Code http://avisynth.org.ru/fft3dfilter/fft3dfilter.html
# ttempsmoothf Ver 0.9.4 or later
#              Code http://bengal.missouri.edu/~kes25c/ 
# medianblur Ver 0.8.4
#            Code http://www.avisynth.org/tsp/medianblur084.zip
#
function rm_logo( clip clp, string "logomask", string "loc",float "par", string "mode",int "percent",int "deblendfalloff",\
                  int "AlphaToRepair", float "RepairRadius", float "InpaintRadius", float "InpaintSharpness",\
                  float "InpaintPreBlur", float "InpaintPostBlur", string "cutsize", bool "lmask", int "pp", bool "debug", \
                  int "cutwidth", int "cutheight")
{
logomask         = default( logomask,           "" ) # file location of the logo, the must be masked in pure white
loc              = default( loc,                "" ) # where is the logo, TR, TL, BR, BL for top right, top left, bottom right, bottom left
cutsize          = default( cutsize,       "small" ) # how big a cut to make, small, medium, large
cutwidth         = default( cutwidth,            0 ) # how wide a cut to make in pixels, -1 for full width of frame
cutheight        = default( cutheight,           0 ) # how tall a cut to make in pixels, -1 for full height of frame
par              = default( par,               1.0 ) # pixel aspect ratio
mode             = default( mode,           "both" ) # deblend, inpaint or both
percent          = default( percent,            25 ) # how much of the clip to analyse in creating color&alpha masks, more is better but slower
deblendfalloff   = default( deblendfalloff,      5 ) # graidient fallout from logo mask
AlphaToRepair    = default( AlphaToRepair,     130 ) # what is the luma value of the solid part of the logo
RepairRadius     = default( RepairRadius,      1.0 ) # used to expand the mask for none alpha ie solid areas
InpaintRadius    = default( InpaintRadius,     6.0 ) # radius around a damaged pixel from where values are taken when the pixel  is inpainted. Bigger values prevent
                                                     # inpainting in the wrong direction, but also create more blur
InpaintSharpness = default( InpaintSharpness, 25.0 ) # Higher values can prevent blurring caused by high Radius values.
InpaintPreBlur   = default( InpaintPreBlur,    1.5 ) # Standard deviation of the blur which is applied to the image before the structure tensor is computed. Higher values 
                                                     # help connecting isophotes which have been cut by the inpainting region, but also increase CPU usage. PreBlur=0.0 
                                                     # disables pre-blurring.
InpaintPostBlur  = default( InpaintPostBlur,   5.0 ) # standard deviation of the blur which is applied to the structure tensors before they are used to determine the 
                                                     # inpainting direction. Higher values help gather more directional information when there are only few valid pixels 
                                                     # available, but increases CPU usage
lmask            = default( lmask,            true ) # apply post process through a repair mask
PP               = default( PP,                  1 ) # Post process function 0,1,2 to help reduce damage left behind by logo removal
debug            = default( debug,           false ) # show mask to help in tunning the output

# set up some values that we need to run
clp_width   = width( clp )
clp_height  = height( clp )
RGB         = isRGB( clp )
RGB32       = isRGB32( clp )
RGB24       = isRGB24( clp )
par         = ( par!= 1.0 ) ? float( clp_height ) / float( clp_width ) * par : 1.0
percent     = ( percent < 0) ? 25 : (percent > 100) ? 100 : percent

# Get the always fun input error checking done
assert        ( logomask != "" , "You have to define a logomask")
assert        ( loc      != "" , "You must provide a value for Loc UL,UR,LL,LR")
assert        ( loc == "TR" || loc == "TL" || loc == "BR" || loc == "BL"  , "Loc must be one of TR, TL, BR, BL")
assert        ( mode == "both" || mode == "inpaint" || mode == "deblend", "Specified mode doesn't exist.")

# Get our crop locations based on the passed location
loc         = UCase( loc )
cutsize     = UCase( cutsize )
multi       = ( cutsize == "SMALL" ) ? 2.25 : ( cutsize == "MEDIUM" ) ? 2.15 : 2
chunk       = ( clp_height > 720 ) ? 2.9 : 3
cutwidth    = ( cutwidth == 0 || cutwidth == -1 ) ? cutwidth : m4(cutwidth)
cutheight   = ( cutheight == 0 || cutheight == -1 ) ? cutheight : m4(cutheight)

a           = ( Rightstr( loc, 1 ) == "L" ) ? 0 : ( cutwidth == 0 ) ? m4( ( clp_width / chunk )  * multi ) : ( cutwidth == -1 ) ? 0 : (clp_width - cutwidth) 
b           = ( Leftstr( loc, 1 )  == "T" ) ? 0 : ( cutheight == 0 ) ? m4( ( clp_height / chunk )  * multi ) : (cutheight == -1 ) ? 0 : (clp_height - cutheight)
c           = ( Rightstr( loc, 1 ) == "R" ) ? 0 : (cutwidth == 0) ? -m4( ( clp_width / chunk )  * multi ) : (cutwidth == -1 ) ? 0 : -(clp_width - cutwidth)
d           = ( Leftstr( loc, 1 )  == "B" ) ? 0 : (cutheight == 0 ) ? -m4( ( clp_height / chunk )  * multi ) : (cutheight == -1) ? 0 : -(clp_height - cutheight)
cropped     = clp.crop(a,b,c,d)

# Anaylse the entire clip or a percentage for speed.  
snipSize    = round( framecount( cropped ) / (framecount( cropped ) * (percent / 100.0) ))
analyse     = ( percent != 100 ) ? cropped.SelectRangeEvery( snipSize, 1 ) : cropped

# Read in our logo mask, prepare it and crop out the corner of interest
logo_mask   = imagesource(logomask,start=0,end=1)
logo_mask   = logo_mask.crop(a,b,c,d)
logo_mask   = logo_mask.ConvertToYV12(Matrix="PC.601")
logo_mask   = logo_mask.DistanceFunction(255/deblendfalloff,PixelAspect=par).Greyscale

# Clean the analyse clip to improve results
analyse = (IsYV12(analyse)) ? analyse : analyse.ConvertToYV12
analyse = analyse.TTempSmoothF(maxr=2,lthresh=256,cthresh=256,scthresh=255).converttoRGB24()
input   = ( RGB24 == true ) ? cropped : cropped.converttoRGB24()

# seperate out the directory and logo names so we can save a unique ebmp file
sl           = logomask.revstr().findstr("\") - 1
Assert((sl   >= 0),"specify a fully qualified directory and logomask name to use")
logo_name    = (sl < 0  ) ? "" : rightstr(logomask,sl) # name and extension
s2           = logo_name.findstr(".") - 1 # find the length of the extension
logo_name    = leftstr(logo_name,s2) # just the name !
Analyse_Name = logo_name + loc + string(percent) + "AnalyzeResult%06d.ebmp"

# Time to run the analysis on the logo, we want the color map and alpha map out of the file.
try {                                                      
  # Analyze is a bit slow so we only do it once and store the result in a file, check if it exists or if it has changed
  ImageSource(Analyse_Name,0,0)
  (Interleave( AssumeFPS(input.FrameRate), input.Trim(0,-2).AnalyzeLogo(logo_mask) ).FrameCount > 3) ? last : last
}
catch( dummy ) {
  # Nice catch, we are here since we need to perform our logo analysis as none already exists
  analyse.AnalyzeLogo(logo_mask)
  
  # The analysis is complete, save a frame (all frames are the same)
  Trim( 0, -1 )
  ImageWriter( logo_name + loc + string(percent) + "AnalyzeResult", 0, 1, "ebmp" )
}

# The color map is the top half of the Analyze result, The alpha channel is in the bottom half
AssumeFPS(analyse.FrameRate)
LogoColor = Crop(0,0,0,last.Height/2)
LogoAlpha = Crop(0,last.Height/2,0,0).ConvertToYV12(Matrix="PC.601")

# Create a Deblend mask, this is a mask that falls off the marked logo area, we use this to blend the delogoed area back into the clip
DeblendMask = logo_mask.DistanceFunction( 255.0 / DeblendFalloff, PixelAspect=par )

# Create a repair mask for pixels that cannot be deblended
LogoAlpha.Invert.mt_lut(expr="x " + " " + string(alphatorepair) + " " + "< 255 0 ?").mt_expand.mt_inflate
RepairMask = ( RepairRadius > 0.1 ) ? DistanceFunction( 84.0 / RepairRadius, PixelAspect=par ) : last

# InpaintLogo and DeblendLogo based on user preferance
deblend    = ( mode == "both" ) ? input.DeblendLogo(LogoColor,LogoAlpha) \
           : ( mode == "deblend" ) ? input.DeblendLogo(logoColor,logoAlpha) : input
repaired   = ( mode == "both" ) ? deblend.InpaintLogo(RepairMask, Radius=InpaintRadius, Sharpness=InpaintSharpness, \
                                  PreBlur=InpaintPreBlur, PostBlur=InpaintPostBlur, PixelAspect=par) \
           : ( mode == "inpaint" ) ? deblend.InpaintLogo(RepairMask,Radius=InpaintRadius, Sharpness=InpaintSharpness, PreBlur=InpaintPreBlur,\
                                     PostBlur=InpaintPostBlur, PixelAspect=par) : deblend

#repaired = ExInpaint (repaired.converttorgb32, repairmask.converttorgb32, color=$ffffff,xsize=5, ysize=3, radius=36)

output = Layer(input.ConvertToRGB32, repaired.ConvertToRGB32.Mask(DeblendMask.ConvertToRGB32(Matrix="PC.601")))
output = output.converttoyv12

# post processing of the results if requested
postmask = LogoAlpha.Invert.mt_lut(expr="x " + " " + string(alphatorepair) + " " + "< 255 0 ?").mt_expand.mt_inflate
postmask = postmask.DistanceFunction( 64.0 / RepairRadius, PixelAspect=par ) 

#postmask = (pp > 0 && lmask) ? repairmask.DistanceFunction( 512.0 / DeblendFalloff, PixelAspect=par ) : blankclip(output,color=$000000)
post = ( PP == 1 ) ? output.minblur(1,uv=3).medianblur(3,0,0).removegrain(11)  \
     : ( pp == 2 ) ? output.fft3dfilter(sigma=16,sigma2=12,sigma3=8,sigma4=4,bt=3,bw=16,bh=16,ow=8,oh=8,plane=4) \
     : ( pp == 3 ) ? output.mt_convolution("1 8 28 56 76 56 28 8 1","1 8 28 56 76 56 28 8 1",y=3,v=2,u=2) \
     : output
output = ( pp > 0 ) ? mt_merge(output,post,postmask) : output

aa = debug ? stackhorizontal(logo_mask.ConvertToYV12.subtitle("logo mask"),logocolor.ConvertToYV12.subtitle("Logo Color"),logoalpha.ConvertToYV12.subtitle("Logo Alpha")) : nop
bb = debug ? stackhorizontal(deblendmask.ConvertToYV12.subtitle("Deblend Mask"),repairmask.ConvertToYV12.subtitle("Repair Mask"),postmask.ConvertToYV12.subtitle("Post Mask")) : nop
cc = debug ? stackhorizontal(cropped.ConvertToYV12.subtitle("Original"),repaired.ConvertToYV12.subtitle("Repaired"),output.ConvertToYV12.subtitle("Post")) : nop

# Almost done, lets blend in our repair
output = (RGB == true) ? (RGB24 == true) ? output : output.converttoRGB32() : output.converttoYV12()
final   = clp.overlay(output,a, b)

RETURN debug ? stackvertical(aa,bb,cc) : final
}

FUNCTION MinBlur(clip input, int r, int "uv")
{
  # Nifty Gauss/Median combination
  # Taken from MCBob.avs:
  uv   = default(uv,3)
  
  # process chroma if uv==3, otherwise just luma
  uv2  = (uv==2) ? 1  : uv
  rg4  = (uv==3) ? 4  : -1
  rg11 = (uv==3) ? 11 : -1
  rg20 = (uv==3) ? 20 : -1
  medf = (uv==3) ? 1  : -200
  
  # make our blur clips, r controls amount 
  RG11D = (r==1) ? mt_makediff(input,input.removegrain(11, rg11),U=uv2,V=uv2)
   \    : (r==2) ? mt_makediff(input,input.removegrain(11,rg11).removegrain(20,rg20),U=uv2,V=uv2)
   \    :          mt_makediff(input,input.removegrain(11,rg11).removegrain(20,rg20).removegrain(20,rg20),U=uv2,V=uv2)
  RG4D  = (r==1) ? mt_makediff(input,input.removegrain(4,rg4),U=uv2,V=uv2)
   \    : (r==2) ? mt_makediff(input,input.medianblur(2,2*medf,2*medf),U=uv2,V=uv2)
   \    :          mt_makediff(input,input.medianblur(3,3*medf,3*medf),U=uv2,V=uv2)
  DD    = mt_lutxy(RG11D,RG4D,"x 128 - y 128 - * 0 < 128 x 128 - abs y 128 - abs < x y ? ?",U=uv2,V=uv2)
  RETURN (input.mt_makediff(DD,U=uv,V=uv))
}

FUNCTION m4(float x) {RETURN( x<16?16:int(round(x/4.0)*4)) }