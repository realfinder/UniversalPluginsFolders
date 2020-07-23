function removeblend(clip clip, int "threshold", float "dthresh", int "pixels", bool "info", bool "interlaced", bool "tff", int "mode", bool "show", float "cthresh", float "bthresh", float "othresh", bool "decomb", int "pt")
{
LoadPlugin(AviSynthPluginsDir + "25/removeblend.dll")
        removeblend(clip, threshold, dthresh, pixels, info, interlaced, tff, mode, show, cthresh, bthresh, othresh, decomb, pt)
}