function FFIndex(string "source", string "cachefile", int "indexmask", int "errorhandling", bool "overwrite")
{
LoadPlugin(AviSynthPluginsDir + "26/ffms2.dll")
        FFIndex(source, cachefile, indexmask, errorhandling, overwrite)
}

function FFVideoSource(string "source", int "track", bool "cache", \
	string "cachefile", int "fpsnum", int "fpsden", int "threads", \
	string "timecodes", int "seekmode", int "rffmode", int "width", int "height", \
	string "resizer", string "colorspace", \
	string "varprefix")
{
LoadPlugin(AviSynthPluginsDir + "26/ffms2.dll")
        FFVideoSource(source, track, cache, \
	cachefile, fpsnum, fpsden, threads, \
	timecodes, seekmode, rffmode, width, height, \
	resizer, colorspace, \
	varprefix)
}


function FFAudioSource(string "source", int "track", bool "cache", string "cachefile", int "adjustdelay", string "varprefix")
{
LoadPlugin(AviSynthPluginsDir + "26/ffms2.dll")
        FFAudioSource(source, track, cache, cachefile, adjustdelay, varprefix)
}

function FFGetLogLevel()
{
LoadPlugin(AviSynthPluginsDir + "26/ffms2.dll")
        FFGetLogLevel()
}

function FFGetVersion()
{
LoadPlugin(AviSynthPluginsDir + "26/ffms2.dll")
        FFGetVersion()
}

function FFSetLogLevel(int Level)
{
LoadPlugin(AviSynthPluginsDir + "26/ffms2.dll")
        FFSetLogLevel(Level)
}

function FFmpegSource2(string "source", int "vtrack", int "atrack", bool "cache", \
	string "cachefile", int "fpsnum", int "fpsden", int "threads", \
	string "timecodes", int "seekmode", bool "overwrite", int "width", int "height", \
	string "resizer", string "colorspace", int "rffmode", int "adjustdelay", \
	string "varprefix") {
LoadPlugin(AviSynthPluginsDir + "26/ffms2.dll")
FFmpegSource2(source, vtrack, atrack, cache, \
	cachefile, fpsnum, fpsden, threads, \
	timecodes, seekmode, overwrite, width, height, \
	resizer, colorspace, rffmode, adjustdelay, \
	varprefix)
}

function FFMS2(string "source", int "vtrack", int "atrack", bool "cache", \
	string "cachefile", int "fpsnum", int "fpsden", int "threads", \
	string "timecodes", int "seekmode", bool "overwrite", int "width", int "height", \
	string "resizer", string "colorspace", int "rffmode", int "adjustdelay", \
	string "varprefix") {
LoadPlugin(AviSynthPluginsDir + "26/ffms2.dll")
FFMS2(source, vtrack, atrack, cache, \
	cachefile, fpsnum, fpsden, threads, \
	timecodes, seekmode, overwrite, width, height, \
	resizer, colorspace, rffmode, adjustdelay, \
	varprefix)
}

function FFImageSource(string "source", int "width", int "height", string "resizer", \
	string "colorspace", string "varprefix") {
LoadPlugin(AviSynthPluginsDir + "26/ffms2.dll")
FFImageSource(source, width, height, resizer, \
	colorspace, varprefix)
}

function FFCopyrightInfringement(string "source") {
LoadPlugin(AviSynthPluginsDir + "26/ffms2.dll")
FFCopyrightInfringement(source)
}

#######################

function FFFormatTime(int ms) {

	s = ms / 1000
	ms = ms % 1000
	m = s / 60
	s = s % 60
	h = m / 60
	m = m % 60

	return ms < 0 ? "<Unknown>" : string(h) + ":" + string(m,"%02.0f") + ":" + string(s,"%02.0f") + "." + string(ms,"%03.0f")
}

function FFColorSpace(int i) {
    i=(i<0||i>10) ? 2 : i
    return Select(i,"RGB","BT709 (ITU-R Rec.709)","Unspecified","Unspecified","FCC","BT470BG (ITU-R Rec.601)","SMPTE 170M (ITU-R Rec.601)","SMPTE 240M","YCoCg","BT2020 NCL","BT2020 NC")
}

function FFColorRange(int i) {
    i=(i<0||i>2) ? 0 : i
    return Select(i,"Unknown/Unspecified","Limited range","Full range")
}

function FFCropping(int l, int t, int r, int b) {
    return "Left="+String(l)+" Top="+String(t)+" Right="+String(r)+" Bottom="+String(b) 
}

function FFSampAR(int num, int den) {
    return num > 0 ? String(num)+":"+String(den)+((num<=0 || den<=0)?"":string(Float(num)/den," (%.3f)")) : "Unknown/Unspecified"
}

function FFPictType(int ch) {
    s=chr(ch)
    s = s + (
        \ ch==73?" (Intra)":ch==80?" (Predicted)":ch==66?" (Bi-dir predicted)":ch==83?" (S(GMC)-VOP MPEG4)"
        \ : ch==105?" (Switching Intra)":ch==112?" (Switching Predicted)":ch==98?" (FF_BI_TYPE)"
        \ : " (Unknown)")    
    return s
}

function FFInfo(clip c, bool "framenum", bool "frametype", bool "cfrtime", bool "vfrtime", string "varprefix",
    \ bool "colorspace",bool "colorrange",bool "cropping",bool "sar",bool "version",bool "showprefix") {

    framenum    = default(framenum,true)
    frametype   = default(frametype,true)
    cfrtime     = default(cfrtime,true)
    vfrtime     = default(vfrtime,true)
    varprefix   = default(varprefix, FFVAR_PREFIX)
    colorSpace  = default(colorspace,true)
    colorrange  = default(colorrange,true)
    cropping    = default(cropping,true)
    sar         = default(sar,true)
    version     = default(version,true)
    showprefix  = default(showprefix,false)

    c.frameevaluate("""
        fftempstring = "" 
        varprefix = """" + varprefix + """"
    """)

    version    ? frameevaluate("""fftempstring = fftempstring + "Version: " + FFGetVersion + "\n" """, after_frame=true) : nop() 
    framenum   ? frameevaluate("""fftempstring = fftempstring + "Frame Number: " + string(current_frame) + " of " + string(framecount()) + "\n" """, after_frame=true) : nop()
    frametype  ? frameevaluate("""fftempstring = fftempstring + "Picture Type: " + FFPictType(eval(varprefix + "FFPICT_TYPE")) + "\n" """, after_frame=true) : nop()
    cfrtime    ? frameevaluate("""fftempstring = fftempstring + "CFR Time: " + FFFormatTime(round((current_frame * 1000) / framerate())) + "\n" """, after_frame=true) : nop()
    vfrtime    ? frameevaluate("""fftempstring = fftempstring + "VFR Time: " + FFFormatTime(eval(varprefix + "FFVFR_TIME")) + "\n" """, after_frame=true) : nop()
    colorspace ? frameevaluate("""fftempstring = fftempstring + "ColorSpace: " + FFColorSpace(eval(varprefix + "FFCOLOR_SPACE")) + "\n" """, after_frame=true) : nop() 
    colorrange ? frameevaluate("""fftempstring = fftempstring + "Color Range: " + FFColorRange(eval(varprefix + "FFCOLOR_RANGE")) + "\n" """, after_frame=true) : nop() 
    cropping   ? frameevaluate("""fftempstring = fftempstring + "Cropping: " + FFCropping(eval(varprefix + "FFCROP_LEFT"),eval(varprefix + "FFCROP_TOP"),eval(varprefix + "FFCROP_RIGHT"),eval(varprefix + "FFCROP_BOTTOM")) + "\n" """, after_frame=true) : nop() 
    sar        ? frameevaluate("""fftempstring = fftempstring + "SAR: " + FFSampAR(eval(varprefix + "FFSAR_NUM"),eval(varprefix + "FFSAR_DEN")) + "\n" """, after_frame=true) : nop() 
    showprefix ? frameevaluate("""fftempstring = fftempstring + "Prefix: '" + varprefix + "'\n" """, after_frame=true) : nop() 

    return scriptclip("subtitle(fftempstring, lsp = 1)", after_frame=true)
}