function FFIndex(string "source", string "cachefile", int "indexmask", int "dumpmask", string "audiofile", int "errorhandling", bool "overwrite", bool "utf8")
{
Load_Stdcall_plugin(AviSynthPluginsDir + "cplugin/ffms2.dll")
        FFIndex(source, cachefile, indexmask, dumpmask, audiofile, errorhandling, overwrite, utf8)
}

function FFVideoSource(string "source", int "track", bool "cache", \
	string "cachefile", int "fpsnum", int "fpsden", int "threads", \
	string "timecodes", int "seekmode", int "rffmode", int "width", int "height", \
	string "resizer", string "colorspace", \
	bool "utf8", string "varprefix")
{
Load_Stdcall_plugin(AviSynthPluginsDir + "cplugin/ffms2.dll")
        FFVideoSource(source, track, cache, \
	cachefile, fpsnum, fpsden, threads, \
	timecodes, seekmode, rffmode, width, height, \
	resizer, colorspace, \
	utf8, varprefix)
}


function FFAudioSource(string "source", int "track", bool "cache", string "cachefile", int "adjustdelay", bool "utf8", string "varprefix")
{
Load_Stdcall_plugin(AviSynthPluginsDir + "cplugin/ffms2.dll")
        FFAudioSource(source, track, cache, cachefile, adjustdelay, utf8, varprefix)
}

function FFGetLogLevel()
{
Load_Stdcall_plugin(AviSynthPluginsDir + "cplugin/ffms2.dll")
        FFGetLogLevel()
}

function FFGetVersion()
{
Load_Stdcall_plugin(AviSynthPluginsDir + "cplugin/ffms2.dll")
        FFGetVersion()
}

function FFSetLogLevel(int Level)
{
Load_Stdcall_plugin(AviSynthPluginsDir + "cplugin/ffms2.dll")
        FFSetLogLevel(Level)
}