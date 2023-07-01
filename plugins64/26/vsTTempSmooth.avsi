function vsTTempSmooth(clip clip, int "maxr", int "ythresh", int "uthresh", int "vthresh", int "ymdiff", int "umdiff" , int "vmdiff", int "strength", float "scthresh", bool "fp", int "y", int "u", int "v", clip "pfclip", int "opt")
{
LoadPlugin(AviSynthPlugins64Dir + "26/vsTTempSmooth.dll")
        vsTTempSmooth(clip, maxr, ythresh, uthresh, vthresh, ymdiff, umdiff, vmdiff, strength, scthresh, fp, y, u, v, pfclip, opt)
}