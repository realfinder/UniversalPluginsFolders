function SmoothDeinterlace(clip clip, int "lacethresh", int "edgethresh", int "staticthresh", int "staticavg", bool "tff", bool "doublerate", bool "blend", bool "showlace", bool "log", float "logpercent", string "logfile")
{
LoadPlugin(AviSynthPlugins64Dir + "25/SmoothDeinterlacer.dll")
        SmoothDeinterlace(clip, lacethresh, edgethresh, staticthresh, staticavg, tff, doublerate, blend, showlace, log, logpercent, logfile)
}