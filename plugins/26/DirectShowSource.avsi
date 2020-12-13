function DirectShowSource(string source, float "fps", bool "seek", bool "audio", bool "video", bool "convertfps", bool "seekzero", int "timeout", string "pixel_type", int "framecount", string "logfile", int "logmask")
{
LoadPlugin(AviSynthPluginsDir + "26/DirectshowSource.dll")
        DirectShowSource(source, fps, seek, audio, video, convertfps, seekzero, timeout, pixel_type, framecount, logfile, logmask)
}