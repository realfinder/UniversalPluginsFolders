############################
# sd2hd
# 2009/07/16 00:20:00 EST
# Dan Isaacs
# http://3dvp.com

# sd2hd()	:	High-quality 480i/480p/576i/576p -> 1080i/1080p/720p (supported rates are 24p, 25p, 30p, 48p, 50i, 50p, 60i, 60p)

# SmartHistogram, SmartHistogram_vscope

############################

function sd2hd(v,
\	bool   "interlaced",
\	bool   "interlaced_out",
\	bool   "Widescreen",
\	bool   "PillarBox",
\	int    "iHmax",
\	int    "iVmax",
\	bool   "Input601",
\	bool   "ScaleRGBInput",
\	int    "OutputWidth",
\	int    "OutputHeight",
\	int    "OutputFieldRate",
\	string "OutputColorSpace",
\	bool   "OutputBFF",
\	bool   "Output601",
\	bool   "SmoothTime",
\	int    "NRStrength",
\	int    "ScaleMethod",
\	float  "Sharpness",
\	int    "DeintMethod",
\	int    "maxd",
\	int    "se",
\	bool   "interlacedUV",
\	bool   "interlacedUV_out") {

        
	v = (isClip(v)) ? v : ConditionalVideoSource(v)
        wasRGB        = isRGB(v)
	wasYV12       = isYV12(v)
	interlaced    = Default(interlaced, ((Round(v.framerate) == 30 || Round(v.framerate) == 25) ? true : false))
        
	Input601      = default(Input601, true)
	Output601     = default(Output601, false)
	ScaleRGBInput = default(ScaleRGBInput, true)
	NRStrength    = default(NRStrength, 20)
	Sharpness     = default(Sharpness, .5)
	OutputBFF     = default(OutputBFF, false)
	SmoothTime    = default(SmoothTime, true)
	ScaleMethod   = default(ScaleMethod, 1)
	
	DeintMethod   = default(DeintMethod,  0)
	maxd          = default(maxd,        12)
	se            = default(se,           0)
	se            = (se < 0) ? 0 : se
	
	iHmax         = default(iHmax, 1)
	iVmax         = default(iVmax, 1)
        
        iHmax         = (ScaleMethod == 0) ? 0 : iHmax
        iVmax         = (ScaleMethod == 0) ? 0 : iVmax
	
	# prepare the input

	wasRGB  = isRGB(v)
	wasYV12 = isYV12(v)
	
	RGBMatrix = (ScaleRGBInput ? "rec" : "pc.") + (Output601 ? "601" : "709")

	Widescreen  = default(Widescreen, true)
	PillarBox   = default(PillarBox,  true)
	
	OutputColorSpace = default(OutputColorSpace, "YUY2")
	OutputColorSpace = UCase(OutputColorSpace)
	forceRGB24       = (OutputColorSpace == "RGB24") ? true : false
	OutputColorSpace = (OutputColorSpace == "RGB" || OutputColorSpace == "RGB24" || OutputColorSpace == "RGB32") ? "RGB" : OutputColorSpace
	OutputColorSpace = (OutputColorSpace == "RGB" || OutputColorSpace == "YUY2") ? OutputColorSpace : "YV12"

	OutputHeight = default(OutputHeight, 0)
	OutputWidth  = default(OutputWidth,  0)
	
	OutputWidth = (OutputWidth == 0) ?
		\ (OutputHeight == 1080) ? 1440 : 1280
		\ : OutputWidth
		
	OutputHeight = (OutputHeight == 0) ?
		\ (OutputWidth == 1920 || OutputWidth == 1440) ? 1080 : 720
		\ : OutputHeight

	SourceFieldRate = Round(v.framerate)
	SourceFieldRate = (interlaced) ? (SourceFieldRate * 2) : SourceFieldRate

	OutputFieldRate = default(OutputFieldRate, SourceFieldRate)

	interlaced_out   = Default(interlaced_out, ((OutputFieldRate >= 50 && OutputHeight != 720) ? true : false))
	
	interlacedUV     = Default(interlacedUV, interlaced)
	interlacedUV     = (wasYV12) ? interlacedUV : false
	interlacedUV     = (!interlaced) ? interlacedUV : true

	interlacedUV_out = Default(interlacedUV_out, interlaced_out)
	interlacedUV_out = (OutputColorSpace == "YV12") ? interlacedUV_out : interlaced_out
	interlacedUV_out = (!interlaced_out)            ? interlacedUV_out : true

	doublerate_deint = true
	doublerate_deint = (SourceFieldRate == 60 && OutputFieldRate == 30 && smoothtime == false) ? false : doublerate_deint
	doublerate_deint = (SourceFieldRate == 50 && OutputFieldRate == 25 && smoothtime == false) ? false : doublerate_deint

	isNTSC = (OutputFieldRate == 24 || OutputFieldRate == 30 || OutputFieldRate == 48 || OutputFieldRate == 60) ? true : false

	fps_num = OutputFieldRate
	fps_num = (isNTSC) ? fps_num * 1000 : fps_num
	fps_den = (isNTSC) ? 1001           : 1

	# PAR (automatic)
	par_i = 1.0
	par_i = (!Widescreen && v.height == 576) ? 1.0940170940170940170940170940171  : par_i
	par_i = (!Widescreen && v.height != 576) ? 0.91158472251529858619962017303229 : par_i
	par_i = ( Widescreen && v.height == 576) ? 1.4586894586894586894586894586895  : par_i
	par_i = ( Widescreen && v.height != 576) ? 1.215446296687064781599493564043   : par_i
        par_i = (v.height != 480 && v.height != 486 && v.height !=576) ? 1.0 : par_i
	par_o = (OutputWidth == 1440 && OutputHeight == 1080) ? 1.333333333 : 1.0 

	scaleH = (!widescreen && !pillarbox) ?
		\ (par_i > 1) ? Round(Float(OutputWidth) * par_i) / 4 * 4 :
		\ (par_i < 1) ? Round(Float(OutputWidth) / par_i) / 4 * 4 :
		\ OutputHeight : OutputHeight

	scaleW = Round(float(v.width) * par_i * (float(scaleH) / float(v.height)) / par_o)
	scaleW = floor(scaleW / 4) * 4
	
	sideW  = (OutputWidth  - scaleW) / 2
	sideH  = (OutputHeight - scaleH) / 2
	
        ########################################################################################################

	# convert RGB to YUY2 and/or convert 709<->601 colorspace
	v = (wasRGB) ?
		\ v.ConvertToYUY2(matrix = RGBMatrix, interlaced=interlaced) :
		\ (!Input601 &&  Output601) ? v.ColorMatrix(mode="Rec.709->Rec.601", interlaced=interlacedUV, clamp=0) :
		\ ( Input601 && !Output601) ? v.ColorMatrix(mode="Rec.601->Rec.709", interlaced=interlacedUV, clamp=0) :
		\ v

	# force NTSC framerate when variations of 29.97 and 59.94 are close enough
	v = (FramerateDenominator(v) == 1001) ? v :
					\ (v.framerate >  23.94 && v.framerate <  23.99) ? v.AssumeFPS( 24000,1001, sync_audio=false) :
					\ (v.framerate >  29.96 && v.framerate <  29.99) ? v.AssumeFPS( 30000,1001, sync_audio=false) :
					\ (v.framerate >  47.94 && v.framerate <  47.99) ? v.AssumeFPS( 48000,1001, sync_audio=false) :
					\ (v.framerate >  59.92 && v.framerate <  59.96) ? v.AssumeFPS( 60000,1001, sync_audio=false) :
					\ v

	# pre-bobbing noise reduction
	v = (wasYV12 && NRStrength > 0) ? v.TogglePlanar()                       : v
	v = (NRstrength > 0)            ? v.GrapeSmoother(NRstrength)            : v
	v = (wasYV12 && NRStrength > 0) ? v.TogglePlanar()                       : v

	# do bobbing
	v = (interlaced == true) ?
		\ v.ConditionalSmoothBob(
			\ deintmethod=deintmethod,
			\ combthresh=0,
			\ dupthresh=0,
			\ se=se,
			\ maxd=maxd,
			\ OutputColorSpace="YUY2")
		\ : (interlacedUV) ? v.UncombUV(deintmethod=deintmethod)
		\ : v
			
	# everything is YUY2 from here on
	v = v.ConvertToYUY2(interlaced=false)
	
	v = (interlaced == true && doublerate_deint == false) ? v.selecteven() : v

	# framerate pre-conversion
	v = (SmoothTime == true && (SourceFieldRate != OutputFieldRate)) ? v.ConvertFieldRate(OutputFieldRate)  : v
	
        # test if interpolation is uniform (for optimized nnedi2_rpow2)
        doRowPow2 = (ScaleMethod == 3 && iHmax > 0 && iHmax == iVmax)

	# vertical interpolation
	v = (ScaleMethod == 1 && iVmax > 0 && scaleH > v.height) ? v.TDeint(field=0, mode=-1, type=3) : v
	v = (ScaleMethod == 1 && iVmax > 1 && scaleH > v.height) ? v.TDeint(field=0, mode=-1, type=3) : v
	v = (ScaleMethod == 1 && iVmax > 2 && scaleH > v.height) ? v.TDeint(field=0, mode=-1, type=3) : v
	
	v = (ScaleMethod == 2 && iVmax > 0 && scaleH > v.height) ? v.eedi2(field=0, pp=0, maxd=8, mthresh=10, lthresh=20, vthresh=20, nt=50) : v
	v = (ScaleMethod == 2 && iVmax > 1 && scaleH > v.height) ? v.eedi2(field=1, pp=0, maxd=8, mthresh=10, lthresh=20, vthresh=20, nt=50) : v
	v = (ScaleMethod == 2 && iVmax > 2 && scaleH > v.height) ? v.eedi2(field=0, pp=0, maxd=8, mthresh=10, lthresh=20, vthresh=20, nt=50) : v

 	v = (ScaleMethod == 3 && !doRowPow2 && iVmax > 0 && scaleH > v.height) ? v.nnedi2(dh=true, field=0) : v
        v = (ScaleMethod == 3 && !doRowPow2 && iVmax > 0 && scaleH > v.height) ? v.nnedi2(dh=true, field=1) : v
        v = (ScaleMethod == 3 && !doRowPow2 && iVmax > 0 && scaleH > v.height) ? v.nnedi2(dh=true, field=0) : v
        
        
	v = (!doRowPow2 && iHmax > 0) ? v.TurnLeft() : v
	
	# horizontal interpolation
	v = (ScaleMethod == 1 && iHmax > 0 && scaleW > v.width) ? v.TDeint(field=0, mode=-1, type=3) : v
	v = (ScaleMethod == 1 && iHmax > 1 && scaleW > v.width) ? v.TDeint(field=0, mode=-1, type=3) : v
	v = (ScaleMethod == 1 && iHmax > 2 && scaleW > v.width) ? v.TDeint(field=0, mode=-1, type=3) : v
	
	v = (ScaleMethod == 2 && iHmax > 0 && scaleW > v.width) ? v.eedi2(field=0, pp=0, maxd=8, mthresh=10, lthresh=20, vthresh=20, nt=50) : v
	v = (ScaleMethod == 2 && iHmax > 1 && scaleW > v.width) ? v.eedi2(field=1, pp=0, maxd=8, mthresh=10, lthresh=20, vthresh=20, nt=50) : v
	v = (ScaleMethod == 2 && iHmax > 2 && scaleW > v.width) ? v.eedi2(field=0, pp=0, maxd=8, mthresh=10, lthresh=20, vthresh=20, nt=50) : v
        
 	v = (ScaleMethod == 3 && !doRowPow2 && iVmax > 0 && scaleH > v.height) ? v.nnedi2(dh=true, field=0) : v
        v = (ScaleMethod == 3 && !doRowPow2 && iVmax > 0 && scaleH > v.height) ? v.nnedi2(dh=true, field=1) : v
        v = (ScaleMethod == 3 && !doRowPow2 && iVmax > 0 && scaleH > v.height) ? v.nnedi2(dh=true, field=0) : v        

	v = (!doRowPow2 && iHmax > 0) ? v.TurnRight() : v

        # unform interpolation via nnedi2_rpow2
        # 1 -> 2
        # 2 -> 4
        # 3 -> 8
        
        v = (doRowPow2) ? v.nnedi2_rpow2(rfactor=Floor(Pow(2, 1 + iHmax)), cshift="spline36resize") : v
        
	# sharpening variables
        sharpenX = (Sharpness != 0) ? (scaleW < v.width)  ? Sharpness : Sharpness * (float(v.width) / float(scaleW))
                                  \ : 0
                                  
        sharpenY = (Sharpness != 0) ? (scaleH < v.height) ? Sharpness : Sharpness * (float(v.height) / float(scaleH))
                                  \ : 0
        
        SharpenXPre  = (sharpenX !=0 && scaleW  < v.width)  ? true : false
        SharpenYPre  = (sharpenY !=0 && scaleH  < v.height) ? true : false
        
	# pre-sharpening
	v = (Sharpness != 0 && (SharpenXPre || SharpenYPre)) ? v.Sharpen(sharpenX, sharpenY) : v

	v = v.Spline36Resize(scaleW,scaleH)
	
	cropW = (sideW < 0) ? abs(sideW) : 0
	cropH = (sideH < 0) ? abs(sideH) : 0
	v = (cropW > 0 || cropH > 0) ? v.Crop(cropW, cropH, (cropW *-1), (cropH*-1)) : v

	# adjust framerate to final
	v = (FramerateNumerator(v) != fps_num || FramerateDenominator(v) != fps_den) ? v.ChangeFPS(fps_num, fps_den, linear=false) : v
        
	# post-sharpening
	v = (Sharpness != 0 && (!SharpenXPre || !SharpenYPre)) ? v.Sharpen(sharpenX, sharpenY, MMX=false) : v
	
	# weaving for interlaced output
	v = (interlaced_out)               ? v.AssumeTFF()                                             : v.AssumeFrameBased()
	v = (interlaced_out && !OutputBFF) ? v.SeparateFields().SelectEvery(4,0,3).Weave().AssumeTFF() : v
	v = (interlaced_out &&  OutputBFF) ? v.SeparateFields().SelectEvery(4,1,2).Weave().AssumeBFF() : v
	
	# pillarbox non-widescreen
	padW = (sideW > 0) ? abs(sideW) : 0
	padH = (sideH > 0) ? abs(sideH) : 0
	v = (padW > 0 || padH > 0) ? v.AddBorders(padW, padH, padW, padH) : v

	# final output colorspace conversion
	v =       (OutputColorSpace == "YV12") ? v.ConvertToYV12(interlaced=interlacedUV_out) :
		\ (OutputColorSpace == "RGB")  ?
	        	\ (forceRGB24) ? v.ConvertToRGB24(interlaced=interlaced_out, matrix=RGBMatrix) : v.ConvertToRGB32(interlaced=interlaced_out, matrix=RGBMatrix) :
		\ v.ConvertToYUY2()
	
        return v
}