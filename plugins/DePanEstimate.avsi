function DePanEstimate(clip clip, int "range", float "trust", int "winx", int "winy", int "wleft", int "wtop", int "dxmax", int "dymax", float "zoommax", float "stab", float "pixaspect", bool "info", string "log", bool "debug", bool "show", string "extlog")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/DePanEstimate.dll") : LoadPlugin(AviSynthPluginsDir + "26/DePanEstimate.dll")
        DePanEstimate(clip, range, trust, winx, winy, wleft, wtop, dxmax, dymax, zoommax, stab, pixaspect, info, log, debug, show, extlog)
}