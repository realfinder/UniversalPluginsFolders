##############################
##############################
##                          ##
##  mfToon v0.52 by mf ^^;  ##
##                          ##
## I would claim copyright, ##
## but as I do not give my  ##
## real identity, I can't.  ##
## So as netizen to net-    ##
## izen, I ask you, please  ##
## don't do lame stuff      ##
## with my script, like     ##
## claiming you made it.    ##
## Thank you.               ##
##                          ##
##############################
##############################
              ##
              ##
################################
################################
##                            ##
## Usage:                     ##
##                            ##
## Import("mfToon-v0.52.avs") ##
## mfToon() or mfToonLite()   ##
##                            ##
################################
################################

####
## 
## New maskbuilding ("cartoon" edgedetection), and mfToon-lite to use in realtime in your
## ffdshow "AVISynth" section. It's not meant for encoding, only playback.
##
##

function mfToon(clip orig, int "twidth", int "theight", int "ssw", int "ssh", int "xstren", \
  int "xthresh", bool "cwarp", bool "sharpen", int "strength", float "wdepth", int "wblur",   \
  float "wthresh", int "drange", float "dboost", int "dlimit", bool "debug", bool "doutput",  \
  string "dclip", bool "show", int "scolor") {

# normal params

strength = Default(strength, 255)	 # line darkening strength, 0-255
sharpen  = Default(sharpen, true)	 # sharpening on/off
cwarp    = Default(cwarp, true)		 # chroma warp on/off
cwarp2   = cwarp ? 1 : 0
wdepth   = Default(wdepth, 16.0)	 # warping depth, ?-?
wblur    = Default(wblur, 1)		 # warping blur level, ?-?
wthresh  = Default(wthresh, 0.5)	 # warping threshold, 0.0-1.0
ssw      = Default(ssw, 4)     		 # supersample factor horizontally, 0-inf
ssh      = Default(ssh, 4)		 # supersample factor vertically, 0-inf
twidth 	 = Default(twidth, orig.width)	 # target width (useful for cropping), 0-inf
theight	 = Default(theight, orig.height) # target height (useful for cropping), 0-inf
show     = Default(show, false)		 # show which lines are being darkened
scolor	 = Default(scolor, $FF00FF)	 # which color to show lines in

# advanced params

xstren   = Default(xstren, 255)   	 # xsharpening strength, 0-255
xthresh  = Default(xthresh, 255)  	 # xsharpening threshold, 0-255

## Where have all the params gone?! - They were useless as of 0.5, but I forgot to clean them.

drange   = Default(drange, 64)    	 # detail range, 0-255
dboost   = Default(dboost, 1.0)   	 # detail boost, 0.1-10.0
dlimit   = Default(dlimit, 30)    	 # detail limiter, 0-255
debug    = Default(debug, false)	 # debug mode on/off
doutput  = Default(doutput, true)	 # print debug info on processed image
dclip    = Default(dclip, "rclip1")	 # which stage of the processing to show

ssw2     = twidth  * ssw
ssh2     = theight * ssh
sharpen2 = show    ? false : sharpen


orig.Unsharpmask(300, 4, 0)
sharp = last
MaskedMerge(sharp, orig.GreyScale(), orig)
sharp1 = last
MaskedMerge(sharp1, orig.GreyScale(), orig)
sharp2 = last

greymask = orig.Greyscale().Invert()

detailmaskpre0 = orig.EdgeMask(3, 255, 255, 255, "cartoon", Y=3, V=1, U=1) \
  .Tweak(0.0, 1.0, drange, 1.0).Levels(60, dboost, 255, 0, 255) \
  .Levels(0, dboost, dlimit, 255, 0).GreyScale().Inflate().Deflate().Deflate().Deflate()
detailmaskpre1 = orig.EdgeMask(3, 255, 255, 255, "roberts", Y=3, V=1, U=1) \
  .Tweak(0.0, 1.0, drange, 1.0).Levels(60, dboost, 255, 0, 255) \
  .Levels(0, dboost, dlimit, 255, 0).GreyScale().Inflate()
detailmaskpre2 = YV12Layer(detailmaskpre0, detailmaskpre1, "mul", 255, chroma=false, Y=3, V=1, U=1).Blur(1.0)
YV12Layer(detailmaskpre2, detailmaskpre2, "mul", 255, chroma=false, Y=3, V=1, U=1).Levels(0, 1.0, 190, 0, 255)
ConvertToYV12().Invert().Inflate().Invert()
detailmask = last
white = orig.Binarize(Y=-255,U=-128,V=-128)
linemask1 = MaskedMerge(white.ConvertToYV12(), detailmask, orig.Invert().ConvertToYV12()).Invert()
linemask = (strength == 255) ? linemask1 : linemask1.levels(0, 1.0, 255, 0, strength)

color = BlankClip(orig, color=scolor)
sharp3 = show ? color : sharp2

dark = MaskedMerge(orig.Greyscale(), sharp3, linemask, Y=3, U=2, V=2)
darkmerged = dark.MergeChroma(orig)
finaldark = show ? dark : darkmerged

semifinal=orig.BicubicResize(twidth, theight, 0, 0.75)

final = dark.BicubicResize(ssw2, ssh2, 0, 0.75).XSharpen(xstren, xthresh) \
  .BicubicResize(twidth, theight, 0, 0.75).MergeChroma(semifinal) \
  .aWarpSharp(cm=cwarp2, depth=wdepth, blurlevel=wblur, thresh=wthresh)

      rclip1  = sharpen2 ?   final    : finaldark
Eval("dclip1  = doutput  ? "+dclip+"  : orig")

dstring1 = "mfToon v0.52 by mf - Debug mode ;p"
dstring2 = "Pointsized: DisabledxDisabled"
dstring3 = "Bicubicsized: " + String(ssw2) + "x" + String(ssh2)
dstring4 = "Outputsize: " + String(twidth) + "x" + String(theight)
dstring5 = "Debug image: " + dclip
clipstring = sharpen2 ? "final" : "finaldark"
dstring6 = "Output image: " + clipstring

      dclip2  = dclip1.Subtitle(dstring1).Subtitle(dstring2, y=33).Subtitle(dstring3, y=48) \
                 .Subtitle(dstring4, y=63).Subtitle(dstring5, y=78).Subtitle(dstring6, y=93)
      rclip2  = debug   ?   dclip2   : rclip1

return rclip2
}

function mfToonLite(clip orig, int "twidth", int "theight", int "strength", int "dstren", int \
  "drange", float "dboost", int "dlimit", string "mask") {

# normal params

strength = Default(strength, 255)	 # line darkening strength, 0-255
mask     = Default(mask, "fastest")	 # quality of the mask

# advanced params

dstren   = Default(dstren, 255)   	 # detail strength, 0-255
drange   = Default(drange, 64)    	 # detail range, 0-255
dboost   = Default(dboost, 1.0)   	 # detail boost, 0.1-10.0
dlimit   = Default(dlimit, 30)    	 # detail limiter, 0-255

orig.Unsharpmask(200, 4, 0)
sharp = last
MaskedMerge(sharp, orig.GreyScale(), orig)
sharp1 = last
MaskedMerge(sharp1, orig.GreyScale(), orig)
sharp2 = last

greymask = orig.Greyscale().Invert()
white = orig.Binarize(Y=-255,U=-128,V=-128)

## slowest

detailmaskpre = orig.EdgeMask(3, 255, 255, 255, "sobel", Y=3, V=1, U=1) \
 .Tweak(0.0, 1.0, drange, 1.0).Levels(60, dboost, 255, 0, 255) \
 .Levels(0, dboost, dlimit, 255, 0).GreyScale().Inflate()
detailmaskpre2 = YV12Layer(detailmaskpre, detailmaskpre, "mul", 255, chroma=false, Y=3, V=1, U=1).Blur(1.0)
YV12Layer(detailmaskpre2, detailmaskpre2, "mul", 255, chroma=false, Y=3, V=1, U=1).Levels(0, 1.0, 190, 0, 255)
ConvertToYV12().Invert().Inflate().Invert()
detailmask = last
linemask1 = MaskedMerge(white.ConvertToYV12(), detailmask, orig.Invert().ConvertToYV12()).Invert()
linemaskslowest = (strength == 255) ? linemask1 : linemask1.levels(0,1.0,255,0,dstren)

## fastest

orig.Unsharpmask(100).EdgeMask(3, 255, 255, 255, "sobel", Y=3, V=1, U=1) \
 .GreyScale().Inflate().Invert().Inflate().Invert()
detailmask = last
linemask1 = MaskedMerge(white.ConvertToYV12(), detailmask, orig.Invert().ConvertToYV12()).Invert()
linemaskfastest = (strength == 255) ? linemask1 : linemask1.levels(0,1.0,255,0,dstren)

linemask = (mask == "fastest") ? linemaskfastest : linemaskslowest

dark = MaskedMerge(orig, sharp2, linemask, Y=3, U=2, V=2)

return dark
}