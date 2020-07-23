######
##
## HQDering v0.1 by mf, modified by lachs0r
##
## Applies derining by using a smart smoother near edges (where ringing occurs) only.
##
## Usage: Import("HQDering-v0.1.avs")
##        HQDering()
##
####

function HQDering(clip input, int "strength", int "overall", string "smoother", string "params") {

 strength = Default(strength, 255)	# strength, 0-255
 overall  = Default(overall, 0)		# overall smoothing, 0-255
 smoother = Default(smoother, "Deen")	# filter that smooths
#params   = default defined below	# filter parameters - use Chr(34) for quotes

defaultnull = Default(params, "")
defaultdeen = Default(params, Chr(34)+"a3d"+Chr(34)+", 2, 12, 15, 20")

params = (smoother=="Deen") ? defaultdeen : defaultnull

try {
smoothedwparams = Eval(smoother + "(input, " + params + ")")
}
catch(err_msg) {
smoothedwoparams = Eval(smoother + "(input)")
}

smoothed = (params=="") ? smoothedwoparams : smoothedwparams

input.EdgeMask(0, 255, 255, 255, "line", Y=3, V=1, U=1)
normalmask = last

normalmask.Levels(0, 3.3, 90, 0, 255).Blur(1.0)
amplifiedmask = last.Levels(0, 3.3, 90, 0, 255).deflate.deflate

normalmask.inflate.inflate.inflate.Levels(0, 3.3, 90, 0, 255).Blur(1.0).inflate.inflate.inflate.Levels(0, 3.3, 255, 0, 255).inflate.inflate.mt_expand
thickmask = last

overlay(amplifiedmask.invert, thickmask, mode="multiply")

Levels(60, 3.0, 140, overall, strength)

# maskedmerge causes aliasing, so supersample
# spline36 causes slight ringing, so don’t do that
ringingmask = last.spline16resize(last.width*5,last.height*5)
input = input.spline16resize(last.width*5,last.height*5)
smoothed = smoothed.spline16resize(last.width*5,last.height*5)

MaskedMerge(input, smoothed, ringingmask)

spline16resize(input.width/5,input.height/5)

}