function BSAudioSource(string "source", int "track", int "adjustdelay", int "threads", bool "enable_drefs", bool "use_absolute_path", float "drc_scale", int "cachemode", string "cachepath", int "cachesize")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/BestSource.dll")
        BSAudioSource(source, track, adjustdelay, threads, enable_drefs, use_absolute_path, drc_scale, cachemode, cachepath, cachesize)
}

function BSVideoSource(string "source", int "track", int "fpsnum", int "fpsden", bool "rff", int "threads", int "seekpreroll", bool "enable_drefs", bool "use_absolute_path", int "cachemode", string "cachepath", int "cachesize", string "hwdevice", int "extrahwframes", string "timecodes", int "start_number")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/BestSource.dll")
        BSVideoSource(source, track, fpsnum, fpsden, rff, threads, seekpreroll, enable_drefs, use_absolute_path, cachemode, cachepath, cachesize, hwdevice, extrahwframes, timecodes, start_number)
}

function BSSource(string "source", int "atrack", int "vtrack", int "fpsnum", int "fpsden", bool "rff", int "threads", int "seekpreroll", bool "enable_drefs", bool "use_absolute_path", int "cachemode", string "cachepath", int "acachesize", int "vcachesize", string "hwdevice", int "extrahwframes", string "timecodes", int "start_number", int "adjustdelay", float "drc_scale")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/BestSource.dll")
        BSSource(source, atrack, vtrack, fpsnum, fpsden, rff, threads, seekpreroll, enable_drefs, use_absolute_path, cachemode, cachepath, acachesize, vcachesize, hwdevice, extrahwframes, timecodes, start_number, adjustdelay, drc_scale)
}

function BSSetDebugOutput(bool "enable")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/BestSource.dll")
        BSSetDebugOutput(enable)
}

function BSSetFFmpegLogLevel(int "level")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/BestSource.dll")
        BSSetFFmpegLogLevel(level)
}