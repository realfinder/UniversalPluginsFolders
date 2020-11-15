function TTempSmooth(clip clip, int "maxr", int "lthresh", int "cthresh", int "lmdiff", int "cmdiff", int "strength", float "scthresh", bool "fp", int "vis_blur", bool "debug", bool "interlaced", Clip "pfclip")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPlugins64Dir + "25/TTempSmooth.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/TTempSmooth.dll")
        TTempSmooth(clip, maxr, lthresh, cthresh, lmdiff, cmdiff, strength, scthresh, fp, vis_blur, debug, interlaced, pfclip)
}

function TTempSmoothF(clip clip, int "maxr", int "lthresh", int "cthresh", int "strength", float "scthresh", bool "fp", int "vis_blur", bool "debug", bool "interlaced", Clip "pfclip")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPlugins64Dir + "25/TTempSmooth.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/TTempSmooth.dll")
        TTempSmoothF(clip, maxr, lthresh, cthresh, strength, scthresh, fp, vis_blur, debug, interlaced, pfclip)
}