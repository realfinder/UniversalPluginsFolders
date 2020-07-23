function TTempSmooth(clip clip, int "maxr", int "lthresh", int "cthresh", int "lmdiff", int "cmdiff", int "strength", float "scthresh", bool "fp", int "vis_blur", bool "debug", bool "interlaced", Clip "pfclip")
{
LoadPlugin(AviSynthPluginsDir + "25/TTempSmooth.dll")
        TTempSmooth(clip, maxr, lthresh, cthresh, lmdiff, cmdiff, strength, scthresh, fp, vis_blur, debug, interlaced, pfclip)
}

function TTempSmoothF(clip clip, int "maxr", int "lthresh", int "cthresh", int "strength", float "scthresh", bool "fp", int "vis_blur", bool "debug", bool "interlaced", Clip "pfclip")
{
LoadPlugin(AviSynthPluginsDir + "25/TTempSmooth.dll")
        TTempSmoothF(clip, maxr, lthresh, cthresh, strength, scthresh, fp, vis_blur, debug, interlaced, pfclip)
}