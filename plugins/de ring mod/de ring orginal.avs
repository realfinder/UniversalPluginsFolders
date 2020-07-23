######
##
## HQDering v0.1 by mf
##
## Applies deringing by using a smart smoother near edges (where ringing occurs) only.
##
## Usage: Import("HQDering-v0.1.avs")
## HQDering()
##
####
function HQDering(clip input, int "strength", int "overall", string "smoother", string "params") {
	strength = Default(strength, 255)#strength, 0 - 255
	overall = Default(overall, 0)#overall smoothing, 0 - 255
	smoother = Default(smoother, "Deen")#filter that smooths
	#params = default defined below # filter parameters - use Chr(34) for quotes

	defaultnull = Default(params, "")
	defaultdeen = Default(params, Chr(34) + "a3d" + Chr(34) + ", 4, 15, 15, 20")

	params = (smoother == "Deen") ? defaultdeen : defaultnull

	try {
		smoothedwparams = Eval(smoother + "(input, " + params + ")")
	} catch (err_msg) {
		smoothedwoparams = Eval(smoother + "(input)")
	}

	smoothed = (params == "") ? smoothedwoparams : smoothedwparams

	input.EdgeMask(3, 255, 255, 255, "sobel", Y = 3, V = 1, U = 1)
	normalmask = last

	normalmask.Levels(0, 3.3, 90, 0, 255).Blur(1.0)
	amplifiedmask = last

	normalmask.Inflate().Inflate().Inflate().Levels(0, 3.3, 90, 0, 255).Blur(1.0).Inflate().Inflate().Inflate().Levels(0, 3.3, 255, 0, 255).Inflate().Inflate()
	thickmask = last

	YV12Layer(amplifiedmask.Invert(), thickmask, "mul", 255, chroma = false, Y = 3, V = 1, U = 1)
	Levels(60, 3.0, 140, overall, strength)
	ringingmask = last
	MaskedMerge(input, smoothed, ringingmask)
}