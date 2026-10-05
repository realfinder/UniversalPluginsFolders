function BSAudioSource(string "source", int "track", int "adjustdelay", int "threads", bool "enable_drefs", bool "use_absolute_path", float "drc_scale", int "cachemode", string "cachepath", int "cachesize", int "maxdecoders", int "variableformat")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/BestSource.dll")
        BSAudioSource(source, track, adjustdelay, threads, enable_drefs, use_absolute_path, drc_scale, cachemode, cachepath, cachesize, maxdecoders, variableformat)
}

function BSVideoSource(string "source", int "track", int "fpsnum", int "fpsden", bool "rff", int "threads", int "seekpreroll", bool "enable_drefs", bool "use_absolute_path", int "cachemode", string "cachepath", int "cachesize", string "timecodes", int "start_number", int "variableformat", int "viewid", int "maxdecoders", bool "apply_rotation")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/BestSource.dll")
        BSVideoSource(source, track, fpsnum, fpsden, rff, threads, seekpreroll, enable_drefs, use_absolute_path, cachemode, cachepath, cachesize, timecodes, start_number, variableformat, viewid, maxdecoders, apply_rotation)
}

function BSSource(string "source", int "atrack", int "vtrack", int "fpsnum", int "fpsden", bool "rff", int "threads", int "seekpreroll", bool "enable_drefs", bool "use_absolute_path", int "cachemode", string "cachepath", int "acachesize", int "vcachesize", string "timecodes", int "start_number", int "vvariableformat", int "adjustdelay", float "drc_scale", int "viewid", int "maxdecoders", bool "apply_rotation", int "avariableformat")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/BestSource.dll")
        BSSource(source, atrack, vtrack, fpsnum, fpsden, rff, threads, seekpreroll, enable_drefs, use_absolute_path, cachemode, cachepath, acachesize, vcachesize, timecodes, start_number, vvariableformat, adjustdelay, drc_scale, viewid, maxdecoders, apply_rotation, avariableformat)
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