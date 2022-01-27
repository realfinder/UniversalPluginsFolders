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


function FFAudioSource(string "source", int "track", bool "cache", string "cachefile", int "adjustdelay", string "varprefix", float "drc_scale")
{
LoadPlugin(AviSynthPluginsDir + "26/ffms2.dll")
        FFAudioSource(source, track, cache, cachefile, adjustdelay, varprefix, drc_scale)
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
	string "varprefix", float "drc_scale") {
LoadPlugin(AviSynthPluginsDir + "26/ffms2.dll")
FFmpegSource2(source, vtrack, atrack, cache, \
	cachefile, fpsnum, fpsden, threads, \
	timecodes, seekmode, overwrite, width, height, \
	resizer, colorspace, rffmode, adjustdelay, \
	varprefix, drc_scale)
}

function FFMS2(string "source", int "vtrack", int "atrack", bool "cache", \
	string "cachefile", int "fpsnum", int "fpsden", int "threads", \
	string "timecodes", int "seekmode", bool "overwrite", int "width", int "height", \
	string "resizer", string "colorspace", int "rffmode", int "adjustdelay", \
	string "varprefix", float "drc_scale") {
LoadPlugin(AviSynthPluginsDir + "26/ffms2.dll")
FFMS2(source, vtrack, atrack, cache, \
	cachefile, fpsnum, fpsden, threads, \
	timecodes, seekmode, overwrite, width, height, \
	resizer, colorspace, rffmode, adjustdelay, \
	varprefix, drc_scale)
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