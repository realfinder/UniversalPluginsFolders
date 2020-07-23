############################
# ConditionalSmoothBob
# 2010/01/15 00:50:00 EST
# Dan Isaacs
# http://3dvp.com

# ConditionalSmoothBob()	:	Double-rate deinterlacing using various engines -- with the ability to skip deinterlacing for duplicate and non-combed frames
# ConditionalVideoSource()	:	Attempts to load a video clip using various source filters
# ConditionalBroadcastRate()	:	Adjusts framerate and audio pitch to match broadcast specs (300000/1001, 25/1, etc.) within a given tolerance

# IntMultFPS(), zAlignFPS()	:	Functions for changing the framerate without altering the position of the first frame(s)
# BlendAperture			:	Keep the same framerate, but blend adjacent frames together using a variable aperture
# TogglePlanar			:	Auto-converts YV12<->YUY2 so that there is no loss of quality (point resized) when switched back and forth
# UncombUV			:	Converts interlaced YV12 -> progressive YV12 (actually, it works on YUY2 also -- assuming it was interlaced YV12 to begin with)
# ConvertFieldRate
# ConditionalVideoSource
#
# NOTE: dupthresh and combthresh have no effect when running the multithreaded version of AviSynth with SetMTMode(), as the runtime environment causes issues with MT. 

############################

function ConditionalSmoothBob_init() {
        LoadPlugin(         AviSynthPluginsDir + "ConditionalSmoothBob/FFMpegSource.dll")
        LoadPlugin(         AviSynthPluginsDir + "ConditionalSmoothBob/QTSource.dll")
        LoadPlugin(         AviSynthPluginsDir + "ConditionalSmoothBob/Decomb.dll")
        LoadPlugin(         AviSynthPluginsDir + "ConditionalSmoothBob/EEDI2_imp.dll")
        LoadPlugin(         AviSynthPluginsDir + "ConditionalSmoothBob/nnedi2.dll")
        LoadPlugin(         AviSynthPluginsDir + "ConditionalSmoothBob/TomsMoComp.dll")
        LoadPlugin(         AviSynthPluginsDir + "ConditionalSmoothBob/yadifmod.dll")
        Load_Stdcall_Plugin(AviSynthPluginsDir + "ConditionalSmoothBob/yadif.dll")
}

############################



function ConditionalSmoothBob(v, 
\	int    "DeintMethod",
\	int    "combthresh",
\	float  "dupthresh",
\	string "OutputColorSpace",
\	int    "maxd",
\	int    "se") {
        
        ConditionalSmoothBob_init()

        v = (!isClip(v)) ? ConditionalVideoSource(v) : v

	DeintMethod  = default(DeintMethod, 2)
	DeintMethod  = (DeintMethod <  0) ?  0 : DeintMethod
	DeintMethod  = (DeintMethod >  3) ?  3 : DeintMethod

	combthresh   = default(combthresh,    0)
	dupthresh    = default(dupthresh, 0.0000)
	maxd         = default(maxd, 16)
	se           = default(se, 0)
	se           = (se < 0) ? 0 : se
	
	wasTFF       = GetParity(v) ? true : false
	
	OutputColorSpace = default(OutputColorSpace, "")
	OutputColorSpace = UCase(OutputColorSpace)
	
	OutputColorSpace = (OutputColorSpace == "" && isRGB32(v)) ? "RGB32" : OutputColorSpace
	OutputColorSpace = (OutputColorSpace == "" && isRGB24(v)) ? "RGB24" : OutputColorSpace
	OutputColorSpace = (OutputColorSpace == "" && isYUY2(v))  ? "YUY2"  : OutputColorSpace
	OutputColorSpace = (OutputColorSpace == "" && isYV12(v))  ? "YV12"  : OutputColorSpace

        v = isRGB(v) ? v.ConvertToYUY2(interlaced=true) : v
	
	# padding or mod16 width and height
	w16 = ceil(float(v.width)  / 16.0) * 16
	h16 = ceil(float(v.height) / 16.0) * 16
	
	bL = (w16 - v.width) / 2
	bR = (bL % 2 != 0) ? bL - 1 : bL
	bL = (bL % 2 != 0) ? bL + 1 : bL
	
	bT = (h16 - v.height) / 2
	bB = (bT % 2 != 0) ? bT - 1 : bT
	bT = (bT % 2 != 0) ? bT + 1 : bT

	v = (bL > 0 || bR > 0 || bT > 0 || bB > 0) ? v.AddBorders(bL, bT, bR, bB) : v
	
	rclip = v.IntMultFPS(2)
        
        lclip = (DeintMethod == 0) ? v.yadifmod(mode=1, edeint=v.nnedi2(field=-2)) : rclip
        lclip = (DeintMethod == 1) ? v.yadifmod(mode=1, edeint=v.SeparateFields().EEDI2(Field = -2, maxd = maxd))                                      : lclip
        lclip = (DeintMethod == 2) ? v.yadifmod(mode=1, edeint=Interleave(v.TomsMoComp(-1, se, 0), v.DoubleWeave().SelectOdd().TomsMoComp(-1, se, 0))) : lclip
        lclip = (DeintMethod == 3) ? yadif(v.Trim(0,-1) ++ v, mode=1).Trim(2,0)                                                                        : lclip

	c1 = String(combthresh) + " > 0 && !IsCombed(threshold=" + String(combthresh) + ")"
	c2 =                      "current_frame % 2 == 1 && " + String(dupthresh) + " > 0 && YDifferenceToNext       < " + String(dupthresh)
	c3 = "current_frame > 0 && current_frame % 2 == 0 && " + String(dupthresh) + " > 0 && YDifferenceFromPrevious < " + String(dupthresh)
	c  = "("  + c1 + ") || (" + c2 + ") || (" + c3 + ")"
	
	(combthresh > 0 || dupthresh > 0) ?
		\ ConditionalFilter( 
			\ rclip.ConvertToYV12(),
			\ rclip,
			\ lclip,
			\ c, "=", "true", show=false)
		\ : lclip
	
	# restore cropping after mod16 padding
	(bL > 0 || bR > 0 || bT > 0 || bB > 0) ? Crop(bL, bT, bR * -1, bB * -1) : last
	
	(OutputColorSpace == "RGB32") ? ConvertToRGB32(interlaced=false) : last
	(OutputColorSpace == "RGB24") ? ConvertToRGB24(interlaced=false) : last
        (OutputColorSpace == "YUY2")  ? ConvertToYUY2(interlaced=false)  : last
        (OutputColorSpace == "YV12")  ? ConvertToYV12(interlaced=false)  : last
	
	AssumeFrameBased()
	(wasTFF) ? AssumeTFF() : AssumeBFF()
	
	return last
}

function IntMultFPS(clip v, float fM) {
	fM = default(fM, 2)
	fM = Round(fM)
	fc = v.framecount
	v = v.changefps(fM * FramerateNumerator(v), FramerateDenominator(v), linear=false)
	sT = Floor(fM / 2.0) - 1
	sT = (sT == 0) ? -1 : sT
	v = v.Trim(0,sT) ++ v
	v = v.Trim(0, fc * fM -1)
	return v
}

function zAlignFPS(clip v, float "num", int "den") {
	num = default(num, v.framerate)
	den = default(den, 1)
	
	fr  = v.framerate
	fc  = v.framecount
	fr2 = float(num) / float(den)

	passthru = (den == 1 && fr2 == num) || (FramerateNumerator(v) == num && FramerateDenominator(v) == den) ? true : false
	
	v = (passthru == false && den == 1) ? v.changefps(num, linear=false)             : v
	v = (passthru == false && den != 1) ? v.changefps(Round(num), den, linear=false) : v

	sT = Floor(fr / fr2) - 1
	sT = (sT == 0)  ? -1 : sT
	
	minfr = (fr < fr2) ? fr : fr2
	maxfr = (fr > fr2) ? fr : fr2
	
	trimthresh = (fr < fr2) ? Abs(Round(maxfr/minfr) - (maxfr/minfr)) : 0

	v = (passthru == false && (trimthresh > 0.001 || trimthresh == 0)) ? v.Trim(0,sT) ++ v : v
	return v
}


function BlendAperture(clip v, float "aperture", int "direction") {
	
	orig = v
	v = v.KillAudio()
	
	aperture  = Default(aperture, 2.5)
	direction = Default(direction, -1)
	
	function ba_fblend(clip c, float n, bool trailing, bool strong) {
		fc = c.framecount()
		
		trailing = Default(trailing, true)
		strong   = Default(strong,true)
		
		n = strong ? n : (n / 2.0)
		
		last = c
		fc = framecount()
		
		trailing ?
			\ Loop(Trim(0,-1), Ceil(n)) ++ last :
			\ last ++ Loop(Trim(framecount()-1,-1), Ceil(n) - 1)
		
		a   = trailing ? Trim(ceil(n),      0) : Trim(00,0)
		a01 = trailing ? Trim(ceil(n) -  1, 0) : Trim(01,0)
		a02 = trailing ? Trim(ceil(n) -  2, 0) : Trim(02,0)
		a03 = trailing ? Trim(ceil(n) -  3, 0) : Trim(03,0)
		a04 = trailing ? Trim(ceil(n) -  4, 0) : Trim(04,0)
		a05 = trailing ? Trim(ceil(n) -  5, 0) : Trim(05,0)
		a06 = trailing ? Trim(ceil(n) -  6, 0) : Trim(06,0)
		a07 = trailing ? Trim(ceil(n) -  7, 0) : Trim(07,0)
		a08 = trailing ? Trim(ceil(n) -  8, 0) : Trim(08,0)
		a09 = trailing ? Trim(ceil(n) -  9, 0) : Trim(09,0)
		a10 = trailing ? Trim(ceil(n) - 10, 0) : Trim(10,0)
		a11 = trailing ? Trim(ceil(n) - 11, 0) : Trim(11,0)
		a12 = trailing ? Trim(ceil(n) - 12, 0) : Trim(12,0)
		a13 = trailing ? Trim(ceil(n) - 13, 0) : Trim(13,0)
		a14 = trailing ? Trim(ceil(n) - 14, 0) : Trim(14,0)
		a15 = trailing ? Trim(ceil(n) - 15, 0) : Trim(15,0)
		a16 = trailing ? Trim(ceil(n) - 16, 0) : Trim(16,0)
		a17 = trailing ? Trim(ceil(n) - 17, 0) : Trim(17,0)
		a18 = trailing ? Trim(ceil(n) - 18, 0) : Trim(18,0)
		a19 = trailing ? Trim(ceil(n) - 19, 0) : Trim(19,0)
		a20 = trailing ? Trim(ceil(n) - 20, 0) : Trim(20,0)
		
		amt = 1.0 / n
		
		a = a ++ Loop(Trim(a.framecount-1, -1), ceil(n))
		(n > 1) ? a : last
		
		(n > 20)           ? Merge(a20, weight=amt) : last
		(n > 19)           ? Merge(a19, weight=amt) : last
		(n > 18)           ? Merge(a18, weight=amt) : last
		(n > 17)           ? Merge(a17, weight=amt) : last
		(n > 16)           ? Merge(a16, weight=amt) : last
		(n > 15)           ? Merge(a15, weight=amt) : last
		(n > 14)           ? Merge(a14, weight=amt) : last
		(n > 13)           ? Merge(a13, weight=amt) : last
		(n > 12)           ? Merge(a12, weight=amt) : last
		(n > 11)           ? Merge(a11, weight=amt) : last
		(n > 10)           ? Merge(a10, weight=amt) : last
		(n > 09)           ? Merge(a09, weight=amt) : last
		(n > 08)           ? Merge(a08, weight=amt) : last
		(n > 07)           ? Merge(a07, weight=amt) : last
		(n > 06)           ? Merge(a06, weight=amt) : last
		(n > 05)           ? Merge(a05, weight=amt) : last
		(n > 04)           ? Merge(a04, weight=amt) : last
		(n > 03)           ? Merge(a03, weight=amt) : last
		(n > 02)           ? Merge(a02, weight=amt) : last
		(n > 01)           ? Merge(a01, weight=amt) : last
		(strong && n > 01) ? Merge(a,   weight=amt) : last
		
		Trim(0, fc-1)
	}
	
	strong = (direction == 0) ? false : true

	a = ba_fblend(v, aperture, false, strong)
	b = ba_fblend(v, aperture, true,  strong)

	(aperture <= 1)           ? orig :
		\ (direction > 0) ? a    :
	        \ (direction < 0) ? b    :
	        \ Merge(a,b,weight=0.5)

	(HasAudio(orig) && aperture > 1) ? AudioDub(orig) : last
        
}


function ConvertFieldRate(clip c, int "OutputFieldRate") {
	c

	fr = last.framerate()
	fNTSC = (fr == 24 || fr == 30 || fr == 48 || fr == 60) ? 1 : 1000
	
	NTSC_out = (OutputFieldRate % 25 == 0) ? false : true
	
	SourceFieldRate = Round(fr)
	OutputFieldRate = Default(OutputFieldRate, (SourceFieldRate >= 48 ? SourceFieldRate / 2 : SourceFieldRate * 2))
	
	a = Merge(SelectEven(), SelectOdd(), weight=0.5)
	b = Merge(Trim(1,0).SelectEven(), Trim(1,0).SelectOdd(), weight=0.5)

	num = (NTSC_out) ? OutputFieldRate * fNTSC   : OutputFieldRate
	den = (NTSC_out) ? ((fNTSC == 1) ? 1 : 1001) : 1
	
	(SourceFieldRate == OutputFieldRate * 2) ?
		\ a :
			\ ((SourceFieldRate != OutputFieldRate)
			\  && ((SourceFieldRate == 48 || SourceFieldRate == 50 || SourceFieldRate == 60)
			\  &&  (OutputFieldRate == 48 || OutputFieldRate == 50 || OutputFieldRate == 60))
			\ ||  ((SourceFieldRate == 24 || SourceFieldRate == 25 || SourceFieldRate == 30)
			\   && (OutputFieldRate == 24 || OutputFieldRate == 25 || OutputFieldRate == 30))
			\ ) ? ConvertFPS(num, den) :
				\ ((SourceFieldRate != OutputFieldRate)
				\  && ((SourceFieldRate == 24 || SourceFieldRate == 25 || SourceFieldRate == 30)
				\  &&  (OutputFieldRate == 48 || OutputFieldRate == 50 || OutputFieldRate == 60))
				\ ) ? Interleave(last, Interleave(a,b)).ConvertFPS(num, den) :
					\ ((SourceFieldRate != OutputFieldRate)
					\  && ((SourceFieldRate == 48 || SourceFieldRate == 50 || SourceFieldRate == 60)
					\  &&  (OutputFieldRate == 24 || OutputFieldRate == 25 || OutputFieldRate == 30))
					\ ) ? a.ConvertFPS(num, den) :
						\ last
}

function TogglePlanar(clip c) {
	c
	wasYV12 = isYV12()
	
	padL = (width()  % 4 == 0) ? 0 : ((width()  / 4 * 4) + 4) - width()
	padT = (height() % 4 == 0) ? 0 : ((height() / 4 * 4) + 4) - height()
	
	(padL > 0 || padT > 0) ? AddBorders(padL, padT, 0, 0) : last
	
	function Plane2YUY2(clip c, string "plane") {
		c = (plane != "V") ? c.UtoY() : c.VtoY()
		Interleave(c,c).AssumeFieldBased().Weave().ConvertToYUY2()
	}

	y = ConvertToYUY2()
	u = Plane2YUY2("U")
	v = Plane2YUY2("V")
	
	(wasYV12) ? YToUV(u,v,y) : c.ConvertToYV12()
	(GetParity(c)) ? AssumeTFF() : AssumeBFF()
	
	(padL > 0 || padT > 0) ? Crop(padL, padT, 0, 0) : last
}

function UncombUV(clip c, int "DeintMethod") {
	c
        DeintMethod = default(DeintMethod, 3)
	wasYUV = (isRGB()) ? false : true

	uv = (wasYUV) ? ConditionalSmoothBob(deintmethod=DeintMethod).SelectEven() : NOP()
	u  = (wasYUV) ? uv.UtoY() : NOP()
	v  = (wasYUV) ? uv.VtoY() : NOP()
	
	(wasYUV) ? YtoUV(u,v,c) : c
}

###############################################

function ConditionalVideoSource(v, bool "AutoIndex") {
	# open MPEG files with FFMpegSource, then try DirectShowSource
        #       If files are .m2v, .mpv or .m4v then attempt to load external audio track
        # open AVI files YUY2 -> RGB32 -> ???
        
        ConditionalSmoothBob_init()
        
        wasClip  = (isClip(v))   ? true : false
        filename = (IsString(v)) ? v                                                     : ""
        ext      = (IsString(v)) ? GetFileExtension(filename)                            : ""
        filebase = (IsString(v)) ? LeftStr( filename, (StrLen(filename) - StrLen(ext)) ) : ""
        
        AutoIndex = Default(AutoIndex, false)
        
        Assert((wasClip || isString(v)), "ConditionalVideoSource: You must either pass a filename or a clip to this function.")
        
        # check for MT
	LastMTMode = -1
	Try {
		LastMTMode = GetMTMode()
	} Catch(err_msg) {
	        LastMTMode = -1
	}
        
        #  *.dga,  *.d2v
        #  *.mpeg, *.mpg, *.m2v, *.mpv,  *.m2t, *.ts
        #  *.m2ts, *.avc, *.264, *.h264, *.m4v, *.mp4
        #  *.avi
        
        ################################
        # clip-loading private functions
        ################################
        
        function ConditionalVideoSource_mpeg(filename, ext) {
                #pp = (ext == ".avi") ? "" :  "hb:32:39/vb:32:39"
                
                Try {
                        FFMpegSource(filename, atrack=-1)
                } Catch(err_msg1) {
                        Try {
                                type = GetFileExtension(filename)
                                FFMpegSource(filename)
                        } Catch(err_msg2) {
                                return err_msg2
                        }
                }
        }
        
        function ConditionalVideoSource_avi(filename) {
                Try {
                        AviSource(filename, pixel_type="yuy2")
                } Catch(err_msg1) {
                        Try {
                                AviSource(filename, pixel_type="rgb32")
                        } Catch(err_msg2) {
                                Try {
                                        AviSource(filename)
                                } Catch(err_msg3) {
                                        return err_msg3
                                }
                        }
                }
        }
        
        function ConditionalVideoSource_qt(filename) {
                Try {
                        QTInput(filename, color=2, audio=true)
                } Catch(err_msg1) {
                        Try {
                                QTInput(filename, color=2, audio=false)
                        } Catch(err_msg2) {
                                Try {
                                        QTInput(filename)
                                } Catch(err_msg3) {
                                        return err_msg3
                                }
                        }
                }
        }

        function ConditionalVideoSource_dshow(filename) {
                Try {
                        DirectShowSource(filename)
                } Catch(err_msg1) {
                        return err_msg1
                }
        }
        
        function ConditionalVideoSource_d2v(filename) {
                Try {
                        Mpeg2Source(filename)
                } Catch(err_msg1) {
                        return err_msg1
                }
        }
        
        function ConditionalVideoSource_dga(filename) {
                Try {
                        AVCSource(filename, deblock=true)
                } Catch(err_msg1) {
                        return err_msg1
                }
        }
        
        function GetFileExtension(filename) {
                ext  = RightStr(filename,4)
                ext  = (LeftStr(ext,1) == ".") ? ext : RightStr(filename,5)
                ext  = (LeftStr(ext,1) == ".") ? ext : RightStr(filename,3)
                ext  = (LeftStr(ext,1) == ".") ? ext : ""
                
                ext = LCase(ext)
                
                return ext
        }
        
        function AppendErrStr(str1, str2) {
                str1 = (string(str2 ) == "") ? str1 : (string(str1) + chr(13) + chr(13) + string(str2))
                return str1
        }
        
        ################################
        # attempt opening video
        ################################
        
        err_str = ""
        tryOpen = false
        
        isTS = (ext == ".m2t" || ext == ".m2ts" || ext == ".mts" || ext == ".ts") ? true : false
        
        
        # SetMTMode(3)
        Try { status = (!isClip(v) && LastMTMode > 0 && GetMTMode() != 3) ? SetMTMode(3) : NOP() } Catch(err) { v }

        # DirectShowSource
        tryOpen = (!isClip(v) && isTS) ? true : false
        v       = (tryOpen)                     ? ConditionalVideoSource_dshow(filename) : v
        err_str = (tryOpen && !isClip(v))       ? AppendErrStr(err_str, v)               : err_str
        
        # DG AVC Index
        tryOpen = (!isClip(v) && ext == ".dga") ? true                                   : false
        v       = (tryOpen)                     ? ConditionalVideoSource_dga(filename)   : v
        err_str = (tryOpen && !isClip(v))       ? AppendErrStr(err_str, v)               : err_str
        
        # DG Index
        tryOpen = (!isClip(v) && ext == ".d2v") ? true                                   : false
        v       = (tryOpen)                     ? ConditionalVideoSource_d2v(filename)   : v
        err_str = (tryOpen && !isClip(v))       ? AppendErrStr(err_str, v)               : err_str

        # SetMTMode(2)
        Try { status = (!isClip(v) && LastMTMode > 0 && GetMTMode() != 2) ? SetMTMode(2) : NOP() } Catch(err) { v }

        # try FFMpegSource for MPEG2 and MPEG4 formats and AVI files
        tryOpen = (!isClip(v) && (ext == ".mpeg" || ext == ".mpg" || ext == ".mpv" || ext == ".m2v"  || isTS ||
                         \  ext == ".avc" || ext == ".264" || ext == ".h264" || ext == ".m4v" || ext == ".mp4" || ext == ".mxf" ||
                         \  ext == ".avi")) ? true : false
        v       = (tryOpen)                     ? ConditionalVideoSource_mpeg(filename, ext)  : v
        err_str = (tryOpen && !isClip(v))       ? AppendErrStr(err_str, v)                    : err_str
        
        # try AviSource for other .avi files
        tryOpen = (!isClip(v) && ext == ".avi") ? true                                   : false
        v       = (tryOpen)                     ? ConditionalVideoSource_avi(filename)   : v
        err_str = (tryOpen && !isClip(v))       ? AppendErrStr(err_str, v)               : err_str
        
        # QuickTime
        tryOpen = (!isClip(v) && ext == ".mov" || ext == ".qt") ? true                   : false
        v       = (tryOpen)                     ? ConditionalVideoSource_qt(filename)    : v
        err_str = (tryOpen && !isClip(v))       ? AppendErrStr(err_str, v)               : err_str    
         
        # SetMTMode(3)
        Try { status = (!isTS && !isClip(v) && LastMTMode > 0 && GetMTMode() != 3) ? SetMTMode(3) : NOP() } Catch(err) { v }
         
        # DirectShowSource if all else fails
        tryOpen = (!isClip(v) && ext != ".d2v" && ext != ".dga" && !isTS) ? true : false
        v       = (tryOpen)                     ? ConditionalVideoSource_dshow(filename) : v
        err_str = (tryOpen && !isClip(v))       ? AppendErrStr(err_str, string(v))       : err_str
        
        Assert(isClip(v), err_str)
        
        # MT (return to original)
        Try { status = (LastMTMode > 0 && GetMTMode() != LastMTMode) ? SetMTMode(LastMTMode) : NOP() } Catch(err) { v }
        
        v
        
        #(!isClip(v)) ?
        #       \ BlankClip(length=1, width=1280, height=720, pixel_type="YUY2", fps=1)
        #               \ .subtitle("unable to load file:", x=180, y=60,  size=40)
        #               \ .subtitle(filename,               x=180, y=120, size=30)
        #               \ .subtitle(string(v),              x=180, y=180, size=20)
        #       \ : v

        # if a filename was passed as v, then try to dub a corresponding .wav file
        Try {
                (!wasClip) ? AudioDub(WavSource(filebase + ".wav")) : last
        } Catch(err_msg) {

        }

        (!wasClip && (height == 1080)) ? AssumeTFF() : last
        #(!wasClip) ? Loop(100) : v
}

function ConditionalBroadcastRate(v, float "ar", float "tolerance", int "RateType", bool "Debug") {
        ConditionalSmoothBob_init()
        
        Debug = Default(debug, false)
        
        v = (!isClip(v)) ? ConditionalVideoSource(v) : v
        v
        
        tolerance = Default(tolerance, .0001)
        ar        = Default(ar, 48000)
        ar        = Round(ar)
        
        n_in = frameratenumerator()
        d_in = frameratedenominator()
        r_in = framerate()
        a_in = HasAudio() ? Round(audiorate()) : -1

        rR = Round(r_in)
        
        # RateType
        #-1 = disabled, will not adjust framerate but will convert audio sample rate as requested
        # 0 = normal, assume NTSC should be n/1001 and PAL should be n/1, but will skip conversions on sources that are within tolerance. Exact multiples of NTSC rates will be reduced (such as 90000/3003 -> 30000/1001)
        # 1 = force integer rate, causes NTSC input to rounded to 24fps, 30fps,etc.  (PAL sources behave as normal)
        # 2 = force fractional rate, causes PAL to become 25000/1001, 50000/1001    (NTSC sources behave as normal)
        # 3 = force 24p <-> 25p conversion, assumes 24p will be converted to PAL or 25p should become 23.976       (sources that are not 24 or 25 fps behave as normal)
        # 4 = force integer 24p conversion, so that 25p and 24p will be converted to exactly 24 fps                (sources that are not 24 or 25 fps behave as normal)
        
        RateType = Default(RateType, 0)
        
        isNTSC = (rR == 24 ||  rR == 48 || rR == 30 || rR == 60) ? true : false
        isPAL  = (rR == 25 ||  rR == 50)                         ? true : false

        isOK = false
        isOK = (!isNTSC && !isPAL)                                              ? true : isOK
        isOK = (isNTSC && d_in % 1001 == 0 && (RateType == 0 || RateType == 2)) ? true : isOK
        isOK = (isPAL  && n_in %   25 == 0 && (RateType == 0 || RateType == 1)) ? true : isOK
        
        isOK = (isNTSC && d_in % 1001 == 0                  && RateType == 3)   ? true : isOK
        isOK = (isNTSC && (Float(n_in) / Float(d_in) == 24) && RateType == 4)   ? true : isOK
        
        n_out = ((isNTSC && RateType != 1) || (isPAL && RateType == 2)) ? rR * 1000 : ((isPAL && RateType != 2) || (isNTSC && RateType == 1)) ? rR : n_in
        d_out = ((isNTSC && RateType != 1) || (isPAL && RateType == 2)) ? 1001      : ((isPAL && RateType != 2) || (isNTSC && RateType == 1)) ? 1  : d_in
        
        n_out = (RateType == 3 && rR == 24)               ?    25 : n_out
        n_out = (RateType == 3 && rR == 48)               ?    50 : n_out
        d_out = (RateType == 3 && (rR == 24 || rR == 48)) ?     1 : d_out
        
        n_out = (RateType == 3 && rR == 25)               ? 24000 : n_out
        n_out = (RateType == 3 && rR == 50)               ? 48000 : n_out
        d_out = (RateType == 3 && (rR == 25 || rR == 50)) ?  1001 : d_out
        
        n_out = (RateType == 4 && (rR == 24 || rR == 25))                         ?  24 : n_out
        n_out = (RateType == 4 && (rR == 48 || rR == 50))                         ?  48 : n_out
        d_out = (RateType == 4 && (rR == 24 || rR == 48 || rR == 25 || rR == 50)) ?   1 : d_out
        
        r_out = (Float(n_out) / Float(d_out))
        diff  = abs(r_in - r_out)
        
        n2 = (d_in % 1001 == 0 && d_in > 1001) ? n_in / (d_in / 1001) : -1
        d2 = (d_in % 1001 == 0 && d_in > 1001) ? 1001                 : -1
        
        isOK = (tolerance == 0 || diff > tolerance) ? false : true
        isOK = (RateType == -1)                     ? true  : isOK
        
        (isOK) ? (n2 > 0) ? AssumeFPS(n2, d2) : last : AssumeFPS(n_out, d_out, sync_audio=true)
        ar_adjusted = audiorate()
        
        (Debug) ? subtitle("Adjust FPS? " + string(!isOK),y=360) : last
        (Debug) ? subtitle("diff:" + string(diff), y=380)        : last
        
        doAudio = (ar <= 0 || a_in <=0 || (isOK && ar == a_in)) ? false : true
        

        
	Try {
		(doAudio) ? SSRC(ar) : last
                (Debug && doAudio) ? subtitle("SSRC " + String(ar_adjusted) + "Hz -> " + String(ar) + "Hz", y=400) : last
	} Catch(err_msg1) {
		Try {
			ResampleAudio(ar*2).SSRC(ar)
                        (Debug && doAudio) ? subtitle("RA+SSRC " + String(ar_adjusted) + "Hz -> " + String(ar) + "Hz", y=400) : last
		} Catch(err_msg2) {
			ResampleAudio(ar)
                        (Debug && doAudio) ? subtitle("RA+SSRC " + String(ar_adjusted) + "Hz -> " + String(ar) + "Hz", y=400) : last
		}
	}
        
        (Debug) ? subtitle(String(r_in) + " fps (" + String(n_in) + "/" + String(d_in) + ")" + " -> " + String(r_out) + " fps (" + String(n_out) + "/" + String(d_out) + ")") : last
}