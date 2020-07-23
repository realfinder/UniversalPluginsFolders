############################
# hd2sd
# 2010/01/15 00:50:00 EST
# Dan Isaacs
# http://3dvp.com

# hd2sd()	:	High-quality 1080i/1080p/720p -> 480i/480p/576i/576p  (supported rates are 24p, 25p, 30p, 48p, 50i, 50p, 60i, 60p)

# + other functions...
# SmartHistogram, SmartHistogram_vscope
############################

############################
function hd2sd_init() {
        Import(    AviSynthPluginsDir + "ConditionalSmoothBob.avsi")
        LoadPlugin(AviSynthPluginsDir + "hd2sd_sd2hd/ColorMatrix.dll")
        LoadPlugin(AviSynthPluginsDir + "hd2sd_sd2hd/GrapeSmoother.dll")
        LoadPlugin(AviSynthPluginsDir + "hd2sd_sd2hd/VScope.dll")
        LoadPlugin(AviSynthPluginsDir + "hd2sd_sd2hd/FFT3DFilter.dll")
        ConditionalSmoothBob_init()
}
############################

function hd2sd(v,
\	bool   "interlaced",
\	bool   "interlaced_out",
\	int    "OutputHeight",
\	int    "OutputWidth",
\	int    "OutputFieldRate",
\	string "OutputColorSpace",
\	bool   "OutputBFF",
\	bool   "Output601",
\	bool   "OutputWidescreen",
\	int    "WidescreenType",
\	float  "CropCenter",
\	bool   "ResizeSharper",
\	bool   "FixWrongRGB",
\	bool   "Input601",
\	bool   "InputBFF",
\	int    "InputBlackLevel",
\	int    "InputWhiteLevel",
\	float  "InputGamma",
\	bool   "ScaleRGBInput",
\	bool   "ScaleBlack",
\	bool   "ScaleWhite",
\	bool   "LimitBlack",
\	bool   "LimitWhite",
\	bool   "LimitColor",
\	bool   "ExpandRGB",
\	float  "Sharpness",
\	bool   "SharpenPost",
\	float  "VerticalBlur",
\	bool   "SmoothTime",
\	int    "NR",
\	int    "GrapeSmootherAmount",
\	int    "FFT3DAmount",
\	int    "maxd",
\	int    "se",
\	bool   "ShowHistogram",
\	bool   "ToggleHistogramMode",
\	bool   "PreviewPAR",
\	int    "DeintMethod",
\	bool   "HybridProtect",
\	bool   "HQFiltering",
\	bool   "ForceSDFieldRate",
\       bool   "interlacedUV",
\       bool   "interlacedUV_out",
\       float  "InputPAR",
\       float  "OutputPAR",
\       int    "OutputAudioRate",
\       bool   "AdjustFramerate",
\       bool   "AutoIndex",
\       bool   "Debug"
\ ) {

        hd2sd_init()
        
        LastMTMode = -1
	Try { LastMTMode = GetMTMode() } Catch(err_msg) { LastMTMode = -1 }
        
	# set default parameters required for preparing the input

	InputBFF        = default(InputBFF, false)
	Input601        = default(Input601, false)
	Output601       = default(Output601, true)
	FixWrongRGB     = default(FixWrongRGB, false)
	ScaleRGBInput   = default(ScaleRGBInput, true)
        AdjustFramerate = Default(AdjustFramerate, true)
        AutoIndex       = Default(AutoIndex, false)
        
	# get and prepare the input
	v = (isClip(v)) ? v : ConditionalVideoSource(v, AutoIndex=AutoIndex)
        
        ar = (HasAudio(v)) ? v.audiorate() : -1
        OutputAudioRate = Default(OutputAudioRate, ar)
        v = (HasAudio(v) && OutputAudioRate <= 0) ? v.KillAudio : v

	v = (InputBFF) ? v.AssumeBFF() : v.AssumeTFF()
        
        origW  = v.width()
        origH  = v.height()
        origFn = v.FramerateNumerator()
        origFd = v.FramerateDenominator()
        origFr = v.Framerate()
        origCs = (v.isRGB32()) ? "RGB32" : (v.isRGB24()) ? "RGB24" : (v.isYUY2()) ? "YUY2" :  (v.isYV12()) ? "YV12" : "?"
        
	interlaced = Default(interlaced, ((Round(v.framerate) == 30 || Round(v.framerate) == 25) ? true : false))
	
	wasRGB  = isRGB(v)
	wasYV12 = isYV12(v)

	RGBMatrix = (ScaleRGBInput ? "rec" : "pc.") + (Output601 ? "601" : "709")

	# set other defaults and dependent variables

	OutputWidescreen = default(OutputWidescreen, true)
	WidescreenType   = default(WidescreenType, 1)

	NR = default(NR, 0)
	GrapeSmootherAmount = default(GrapeSmootherAmount, 20)
	FFT3DAmount         = default(FFT3DAmount,        256)

	OutputColorSpace = default(OutputColorSpace, "YV12")
	OutputColorSpace = UCase(OutputColorSpace)
	forceRGB24       = (OutputColorSpace == "RGB24") ? true : false
	OutputColorSpace = (OutputColorSpace == "RGB" || OutputColorSpace == "RGB24" || OutputColorSpace == "RGB32") ? "RGB" : OutputColorSpace
	OutputColorSpace = (OutputColorSpace == "RGB" || OutputColorSpace == "YUY2") ? OutputColorSpace : "YV12"

	InputBlackLevel = default(InputBlackLevel, 0)
	InputWhiteLevel = default(InputWhiteLevel, 255)
	InputGamma      = default(InputGamma, 1.0)

	ScaleBlack = default(ScaleBlack, false)
	ScaleWhite = default(ScaleWhite, false)

	LimitWhite = default(LimitWhite, true)
	LimitBlack = default(LimitBlack, true)
	LimitColor = default(LimitColor, true)

	OutputBFF  = default(OutputBFF, false)
	SmoothTime = default(SmoothTime, true)
        
        ExpandRGB  = default(ExpandRGB, true)
        
	luma_low_scale    = (ScaleBlack) ? 16  : 0 
	luma_high_scale   = (ScaleWhite) ? 235 : 255
	luma_low_limit    = (LimitBlack) ? 16  : 0 
	luma_high_limit   = (LimitWhite) ? 235 : 255
	chroma_low_limit  = (LimitColor) ? 16  : 0
	chroma_high_limit = (LimitColor) ? 240 : 255
	
	SourceFieldRate = Round(v.framerate)
	SourceFieldRate = (interlaced) ? (SourceFieldRate * 2) : SourceFieldRate
	OutputFieldRate = default(OutputFieldRate, SourceFieldRate)

        assume_interlaced_out = (OutputFieldRate == 50 || OutputFieldRate == 60) ? true : false
	interlaced_out   = Default(interlaced_out, (assume_interlaced_out ? true : false))
	
        # ForceSDFieldRate is not really ever used, but it is here
	ForceSDFieldRate = default(ForceSDFieldRate, false)
	OutputFieldRate = (ForceSDFieldRate) ?
		\ (OutputFieldRate == 48) ? 24 :
			\ (OutputFieldRate % 25 == 0) ? (interlaced_out ? 50 : 25) : (interlaced_out ? 60 : 30)
		\ : OutputFieldRate
        
	interlacedUV     = Default(interlacedUV, interlaced)
	interlacedUV     = (wasYV12) ? interlacedUV : false
	interlacedUV     = (!interlaced) ? interlacedUV : true

	interlacedUV_out = Default(interlacedUV_out, interlaced_out)
	interlacedUV_out = (OutputColorSpace == "YV12") ? interlacedUV_out : interlaced_out
	interlacedUV_out = (!interlaced_out)            ? interlacedUV_out : true
	
	OutputHeight = default(OutputHeight, 0)
        OutputHeight = (OutputHeight == 0) ? 
                \ (OutputFieldRate % 25 == 0) ? 576 : 480
                \ : OutputHeight
                
	OutputHeight = (interlaced_out && OutputColorSpace == "YV12") ? Ceil(OutputHeight / 4.0) * 4 : OutputHeight
                
	doublerate_deint = true
	doublerate_deint = (SourceFieldRate == OutputFieldRate * 2) ? false : doublerate_deint



	DeintMethod    = default(DeintMethod,  3)
	maxd           = default(maxd,        12)
	se             = default(se,           0)
	se             = (se < 0) ? 0 : se
	
	HybridProtect  = default(HybridProtect, false)
	combthresh     = (HybridProtect) ? 4     : 0
	dupthresh      = (HybridProtect) ? 0.001 : 0

	ResizeSharper = default(ResizeSharper, true)
	HQFiltering   = default(HQFiltering, true)
	Sharpness     = default(Sharpness,      0)
        SharpenPost   = default(SharpenPost, false)
	VerticalBlur  = default(VerticalBlur, 0.0)
	VerticalBlur  = (VerticalBlur > 1.5) ? 1.5 : VerticalBlur
	VerticalBlur  = (VerticalBlur < 0.0) ? 0   : VerticalBlur
	
	fps_n =   (OutputFieldRate == 60) ? 60000 :
		\ (OutputFieldRate == 48) ? 48000 :
		\ (OutputFieldRate == 30) ? 30000 :
		\ (OutputFieldRate == 24) ? 24000 :
		\ OutputFieldRate
		
	fps_d = (fps_n >= 24000) ? 1001 : 1
	fps   = (float(fps_n) / float(fps_d))

	CropCenter  = Default(CropCenter,0.5)
	CropCenter  = Abs(CropCenter)
	CropCenter  = (CropCenter > 1.0) ? 1.0 : CropCenter

	ShowHistogram       = Default(ShowHistogram, false)
	ToggleHistogramMode = Default(ToggleHistogramMode, false)
	PreviewPAR          = Default(PreviewPAR, false)
        
	OutputWidth = Default(OutputWidth, 720)
	
	# PAR ################################################
        
        OutputWidescreen = (WidescreenType < 0) ? false : OutputWidescreen
        WidescreenType   = Abs(WidescreenType)
        
        ntsc_s = 0.91158472251529858619962017303229
        ntsc_w = 1.21544629668706478159949356404300
        pal_s  = 1.09401709401709401709401709401710
        pal_w  = 1.45868945868945868945868945868950

        par_i =       (v.height == 1080 || v.height == 1088) ?
                        \   (v.width == 1440) ? 1.33333333333333333333333333333333
                        \ : (v.width == 1280) ? 1.50000000000000000000000000000000
                        \ :                     1.0
                  \ : (v.height == 720) ?
                        \   (v.width == 960)  ? 1.33333333333333333333333333333333
                        \ :                     1.0
                  \ : 1.0
                  
        InputPAR  = Default(InputPAR,  par_i)

        par_o =     (WidescreenType == 0) ? (float(OutputHeight) / float(v.height) * float(v.width) * InputPAR) / float(OutputWidth)
                        \ : ((OutputWidth == 720 || OutputWidth == 704) && OutputHeight == 576) ?
                                \ (OutputWidescreen) ? pal_w
                                \ :                    pal_s
                        \ : ((OutputWidth == 720 || OutputWidth == 704) && OutputHeight == 480 || OutputHeight == 486) ?
                                \ (OutputWidescreen) ? ntsc_w
                                \ :                    ntsc_s
                        \ : 1.0

        OutputPAR = Default(OutputPAR, par_o)
        
        # factor
        fY = (float(OutputHeight) / float(v.height))
        fX = (InputPAR / OutputPAR) * fY
        
        # delta
        dX = (float(OutputWidth) / fY) * (OutputPAR / InputPAR)
        dY = (float(OutputWidth) / fY) * (OutputPAR / InputPAR) / float(v.width) * float(v.height)
        
        # pre-resize crop values (per side)
        cX = (v.width  > dX && WidescreenType == 1) ? abs(float(v.width)  - dX) / 2.0 : 0
        cY = (v.height < dY && WidescreenType == 1) ? abs(float(v.height) - dY) / 2.0 : 0
        
        # output scaling sizes
        sX = (WidescreenType == 2) ? Float(v.width)  * fX : OutputWidth
        sY = (WidescreenType == 2) ? Float(v.height) * fY : OutputHeight

        dar_i = (Float(v.width) * InputPAR) / Float(v.height)
        
        sY = (WidescreenType == 2 && sX > OutputWidth) ? Float(OutputWidth) / dar_i * OutputPAR  : sY
        sX = (WidescreenType == 2 && sX > OutputWidth) ? OutputWidth                             : sX

        cX = Round(cX / 2.0) * 2
        cY = Round(cY / 2.0) * 2
        
        sX = Round(sX / 2.0) * 2
        sY = Round(sY / 2.0) * 2
        
        sX = (WidescreenType == 0) ? OutputWidth  : sX
        sY = (WidescreenType == 0) ? OutputHeight : sY

        sX = ((OutputWidth == 720 || OutputWidth == 704) && (sX == 702 || sX == 710)) ? Ceil(sX / 4.0) * 4 : sX 
        sY = (interlaced_out && OutputColorSpace == "YV12")                           ? Ceil(sY / 4.0) * 4 : sY
        
	#############################################################################################
	# HD -> SD conversion
	#############################################################################################
	
        # adjust the source framerate and audio to standard rate to avoid dropped frames
        
        RateType =  (OutputFieldRate == 24 || OutputFieldRate == 48 || OutputFieldRate == 30 || OutputFieldRate == 60) ? 2
                \ : (OutputFieldRate == 25 || OutputFieldRate == 50)                                                   ? 1
                \ : 0

        RateType = (AdjustFramerate) ? RateType : -1
        
        v = v.ConditionalBroadcastRate(ar=OutputAudioRate, RateType=RateType, debug=false)
        
	# convert RGB to YUY2 and/or convert 709<->601 colorspace
	v = (wasRGB) ?
		\ v.ConvertToYUY2(matrix = RGBMatrix, interlaced=interlaced) :
		\ (!Input601 &&  Output601) ? v.ColorMatrix(mode="Rec.709->Rec.601", interlaced=interlacedUV, clamp=false) :
		\ ( Input601 && !Output601) ? v.ColorMatrix(mode="Rec.601->Rec.709", interlaced=interlacedUV, clamp=false) :
		\ v

	v = (wasRGB && FixWrongRGB) ? v.ColorMatrix(mode="Rec.709->Rec.601", clamp=false, interlaced=interlacedUV) : v
	
        hcrop_total = cX * 2
        vcrop_total = cY * 2

	lcrop = Floor(hcrop_total * CropCenter)
	rcrop = (hcrop_total - lcrop)
        
	lcrop = (lcrop % 2 != 0) ? lcrop + 1 : lcrop
	rcrop = (rcrop % 2 != 0) ? rcrop + 1 : rcrop

	lcrop = (lcrop < 0) ? 0 : lcrop
	rcrop = (rcrop < 0) ? 0 : rcrop * -1

	tcrop = Floor(vcrop_total * CropCenter)
        bcrop = (vcrop_total - tcrop)
        
	tcrop = (tcrop % 2 != 0) ? tcrop + 1 : tcrop
	bcrop = (bcrop % 2 != 0) ? bcrop + 1 : bcrop
        
	tcrop = (tcrop < 0) ? 0 : tcrop
	bcrop = (bcrop < 0) ? 0 : bcrop * -1

	v = (lcrop != 0 || rcrop != 0 || tcrop != 0 || bcrop != 0) ? v.crop(lcrop, tcrop, rcrop, bcrop) : v

	# noise reduction HDV input (FFT3dFilter)
	fclip = (NR >  4 && NR <  7) ? v.FFT3DFilter(sigma=2, interlaced=interlaced, ncpu = 2) : NOP()
	v     = (NR >  4 && NR <  7) ?
			\ (FFT3DAmount >= 256) ? fclip :
			\ (FFT3DAmount <=   0) ? v :
			\ Merge(v, fclip, weight=(Float(FFT3DAmount) / 256.0)) :
			\ v
		
	# noise reduction HDV input (GrapeSmoother <- requires YUY2)
	v = (wasYV12 && GrapeSmootherAmount > 0 && (NR == 2 || NR == 6 || NR == 7)) ? v.TogglePlanar() : v

	v = (GrapeSmootherAmount > 0 &&  NR == 6)             ? v.ConvertToYUY2(interlaced=interlaced).MergeChroma(v.GrapeSmoother(GrapeSmootherAmount))  : v
	v = (GrapeSmootherAmount > 0 && (NR == 2 || NR == 7)) ? v.ConvertToYUY2(interlaced=interlaced).GrapeSmoother(GrapeSmootherAmount)                 : v
	
	v = (wasYV12 && GrapeSmootherAmount > 0 && (NR == 2 || NR == 6 || NR == 7)) ? v.TogglePlanar() : v
	
        # horizontal resize before EEDI or NNEDI deinterlacing when source is interlaced and pre-sharpening is not being used
        v = (interlaced && (DeintMethod == 1 || DeintMethod == 0) && (Sharpness == 0 || SharpenPost)) ? (ResizeSharper) ? v.Spline36Resize(sX, v.height()) : v.GaussResize(sX, v.height(), p=50) : v
        
	# do bobbing
	v = (interlaced) ?
		\ v.ConditionalSmoothBob(
			\ deintmethod=deintmethod,
			\ combthresh=combthresh,
			\ dupthresh=dupthresh,
			\ se=se,
			\ maxd=maxd,
			\ OutputColorSpace="YUY2")
		\ : (interlacedUV) ? v.UncombUV(deintmethod=deintmethod)
		\ : v
	 		
	# everything is YUY2 from here on
	v = v.ConvertToYUY2(interlaced=false)
	
	# sharpening (pre), levels, resizing, frameblending
	v = (!SharpenPost && Sharpness != 0) ? v.Sharpen(Sharpness, MMX=!HQFiltering) : v
	v = (ScaleWhite || ScaleBlack || InputBlackLevel > 0 || InputWhiteLevel < 255 || InputGamma != 1.0) ? v.Levels(InputBlackLevel,InputGamma,InputWhiteLevel,luma_low_scale,luma_high_scale,coring=false) : v
        v = (ResizeSharper) ? v.Spline36Resize(sX, sY) : v.GaussResize(sX, sY, p=50)
        
	v = (SmoothTime && (SourceFieldRate != OutputFieldRate)) ? v.ConvertFieldRate(OutputFieldRate) : v.ChangeFPS(fps_n, fps_d, linear=false)

	# noise reduction SD output
	fclip = (NR == 3 || NR == 4 || NR == 7) ? v.FFT3DFilter(sigma=1.5, interlaced=false, ncpu = 2) : NOP()
	v     = (NR == 3 || NR == 4 || NR == 7) ?
			\ (FFT3DAmount >= 256) ? fclip :
			\ (FFT3DAmount <=   0) ? v :
			\ Merge(v, fclip, weight=(Float(FFT3DAmount) / 256.0)) :
			\ v
	v = (GrapeSmootherAmount > 0 && NR == 4) ? v.MergeChroma(v.GrapeSmoother(GrapeSmootherAmount)) : v
        
        # sharpening (post)
	v = (SharpenPost && Sharpness != 0) ? v.Sharpen(Sharpness, MMX=!HQFiltering) : v
        
	# vertical filtering
	v = (VerticalBlur > 0) ? v.blur(0, VerticalBlur, MMX=!HQFiltering) : v
	
	# weaving for interlaced output
        # SetMTMode(5) for 50p or 60p sources [much faster... I don't understand why]
        Try { status = (!interlaced && interlaced_out && origFr >= 48 && LastMTMode > 0 && LastMTMode != 5) ? SetMTMode(5) : NOP() } Catch(err) {  }
	v = (interlaced_out) ?
		\ (OutputBFF) ?
			\ v.SeparateFields().SelectEvery(4,1,2).Weave() :
			\ v.SeparateFields().SelectEvery(4,0,3).Weave() :
		\ v
	
	v = (OutputBFF) ? v.AssumeBFF() : v.AssumeTFF()
        # SetMTMode(LastMTMode)
        Try { status = (!interlaced && interlaced_out && origFr >= 48 && LastMTMode > 0) ? SetMTMode(LastMTMode) : NOP() } Catch(err) {  }

	v = ((LimitWhite && !ScaleWhite) || (LimitBlack && !ScaleBlack) || LimitColor) ? v.Limiter(luma_low_limit, luma_high_limit, chroma_low_limit, chroma_high_limit) : v

	# RGB output options
	RGBMatrix  = (Output601) ? "601" : "709"
	RGBMatrix = ((ExpandRGB) ? "rec" : "pc.") + RGBMatrix

	# padding
	hborder = (OutputWidth - v.width) / 2
	hborder = (hborder < 0) ? 0 : hborder
	vborder = (OutputHeight - v.height) / 2
	vborder = (vborder < 0) ? 0 : vborder
	
        vshift = (vborder % 2 != 0) ? 1 : 0
        hshift = (hborder % 2 != 0) ? 1 : 0
	v = (hborder > 0 || vborder > 0) ? v.AddBorders(hborder + hshift, vborder + vshift, hborder - hshift, vborder - vshift) : v

	# PAR adjusted preview mode
	pparw = Round(float(v.width) * OutputPAR)
	pparw = (pparw % 2 != 0) ? pparw + 1 : pparw
	pparw = (pparw % 4 != 0) ? pparw + 2 : pparw
	v = (PreviewPAR) ? v.BicubicResize(pparw, v.height) : v

	# Final output colorspace conversion and Histogram preview mode
	v = (OutputColorSpace == "YV12") ? v.ConvertToYV12(interlaced=interlacedUV_out) : v

	histo_mode = (ToggleHistogramMode) ? "classic" : "levels"
	v = (ShowHistogram && !ToggleHistogramMode) ? StackHorizontal(v, v.SmartHistogram(mode=histo_mode)) : v
	v = (ShowHistogram &&  ToggleHistogramMode) ? StackVertical(  v, v.SmartHistogram(mode=histo_mode)) : v

	OutputColorSpace = (ShowHistogram) ? "RGB" : OutputColorSpace
	forceRGB24       = (ShowHistogram) ? false : forceRGB24

	v = (OutputColorSpace == "RGB" &&  forceRGB24) ? v.ConvertToRGB24(interlaced=interlaced_out, Matrix=RGBMatrix) : v
	v = (OutputColorSpace == "RGB" && !forceRGB24) ? v.ConvertToRGB32(interlaced=interlaced_out, Matrix=RGBMatrix) : v

        Debug=Default(Debug, false)
        v = (Debug) ? v
                     \ .subtitle(origCs + " " + string(origW) + "x" + string(origH) + "/" + String(SourceFieldRate) + (interlaced ? "i" : "p") + (!InputBFF ? " (TFF) " : " (BFF) ") + string(origFr) + " fps (" + string(origFn) + " / " + string(origFd) + ")" + " PAR:" + string(InputPAR), y=10)
                     \ .subtitle("dX:" + string(dX) + " dY:" + string(dY), y=30)
                     \ .subtitle("cX:" + string(cX) + " cY:" + string(cY), y=50)
                     \ .subtitle("sX:" + string(sX) + " sY:" + string(sY), y=70)
                     \ .subtitle("lcrop:" + string(lcrop) + " tcrop:" + string(tcrop) + " rcrop:" + string(rcrop) + " bcrop:" + string(bcrop), y=90)
                     \ .subtitle("hborder:" + string(hborder) + " vborder:" + string(vborder) + " vshift:" + string(vshift) + " hshift:" + string(hshift), y=110)
                     \ .subtitle(OutputColorSpace + " " + string(v.width) + "x" + string(v.height)  + "/" + String(OutputFieldRate) + (interlaced_out ? "i" : "p") + ((v.GetParity()) ? " (TFF) " : " (BFF) ") + string(v.framerate) + " fps (" + string(v.frameratenumerator) + " / " + string(v.frameratedenominator) + ")" + " PAR:" + string(OutputPAR), y=140)
             \ : v
        
	return v
}

function SmartHistogram(v, string "matrix", string "mode", bool "interlaced") {
        hd2sd_init()
        
	matrix = default(matrix, "pc.709")
	interlaced = default(interlaced,true)
	mode = default(mode, "classic")

	vh = v

	vh = (isRGB(v)  && mode == "levels")  ? vh.converttoyv12(matrix=matrix,interlaced=interlaced) : vh
	vh = (isYUY2(v) && mode == "levels")  ? vh.converttoyv12(interlaced=interlaced)               : vh

	vh = (isRGB(v)  && mode == "classic") ? vh.converttoyuy2(matrix=matrix,interlaced=interlaced) : vh
	vh = (isYV12(v) && mode == "classic") ? vh.converttoyuy2(interlaced=interlaced)               : vh

	v_width  = vh.width

	vh = (mode == "classic") ?  vh.SmartHistogram_vscope() : vh.histogram(mode = mode).crop(v_width, 0, (vh.width - v_width), vh.height)

	vh = (isRGB32(v)) ? vh.ConvertToRGB32(matrix=matrix,interlaced=interlaced) : vh
	vh = (isRGB24(v)) ? vh.ConvertToRGB24(matrix=matrix,interlaced=interlaced) : vh
	vh = (isYUY2(v))  ? vh.ConvertToYUY2(interlaced=interlaced) : vh
	vh = (isYV12(v))  ? vh.ConvertToYV12(interlaced=interlaced) : vh

	return vh
}

function SmartHistogram_vscope(v) {
        hd2sd_init()
        
	vs = v.VideoScope("bottom",false,"Y","Y")
	vs = vs.crop(0,vs.height-256,-0,-0)

	vs1 = vs.crop(0,0,vs.width,20).levels(0,1,255,64,255,coring=false)
	vs2 = vs.crop(0,20,-0,-16)
	vs3 = vs.crop(0,240,-0,-0).levels(0,1,255,64,255,coring=false)

	vs = stackvertical(vs1,vs2)
	vs = stackvertical(vs,vs3)

	return vs
}