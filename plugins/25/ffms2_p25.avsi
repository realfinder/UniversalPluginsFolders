function FFIndex(string "source", string "cachefile", int "indexmask", int "dumpmask", string "audiofile", int "errorhandling", bool "overwrite", bool "utf8", string "demuxer")
{
LoadPlugin(AviSynthPluginsDir + "25/ffms2.dll")
        FFIndex(source, cachefile, indexmask, dumpmask, audiofile, errorhandling, overwrite, utf8, demuxer)
}

function FFVideoSource(string "source", int "track", bool "cache", \
	string "cachefile", int "fpsnum", int "fpsden", int "threads", \
	string "timecodes", int "seekmode", int "rffmode", int "width", int "height", \
	string "resizer", string "colorspace", \
	bool "utf8", string "varprefix")
{
LoadPlugin(AviSynthPluginsDir + "25/ffms2.dll")
        FFVideoSource(source, track, cache, \
	cachefile, fpsnum, fpsden, threads, \
	timecodes, seekmode, rffmode, width, height, \
	resizer, colorspace, \
	utf8, varprefix)
}


function FFAudioSource(string "source", int "track", bool "cache", string "cachefile", int "adjustdelay", bool "utf8", string "varprefix")
{
LoadPlugin(AviSynthPluginsDir + "25/ffms2.dll")
        FFAudioSource(source, track, cache, cachefile, adjustdelay, utf8, varprefix)
}

function FFGetLogLevel()
{
LoadPlugin(AviSynthPluginsDir + "25/ffms2.dll")
        FFGetLogLevel()
}

function FFGetVersion()
{
LoadPlugin(AviSynthPluginsDir + "25/ffms2.dll")
        FFGetVersion()
}

function FFSetLogLevel(int Level)
{
LoadPlugin(AviSynthPluginsDir + "25/ffms2.dll")
        FFSetLogLevel(Level)
}