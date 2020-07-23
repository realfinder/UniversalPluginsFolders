function vsTTempSmooth(clip clip, int "maxr", int "ythresh", int "uthresh", int "vthresh", int "ymdiff", int "umdiff" , int "vmdiff", int "strength", float "scthresh", bool "fp", bool "y", bool "u", bool "v", clip "pfclip")
{
LoadPlugin(AviSynthPlugins64Dir + "26/vsTTempSmooth.dll")
        vsTTempSmooth(clip, maxr, ythresh, uthresh, vthresh, ymdiff, umdiff, vmdiff, strength, scthresh, fp, y, u, v, pfclip)
}