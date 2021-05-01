function DeDup(clip clip, float "threshold", float "threshold2", int "range2", float "trigger2", bool "show", bool "dec", int "maxcopies", int "maxdrops", int "decwhich", string "log", string "times", string "timesin", string "ovr", string "debug")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPlugins64Dir + "25/DeDup.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/DeDup.dll")
        DeDup(clip, threshold, threshold2, range2, trigger2, show, dec, maxcopies, maxdrops, decwhich, log, times, timesin, ovr, debug)
}

function DupMC(clip clip, bool "chroma", string "log", int "search")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPlugins64Dir + "25/DeDup.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/DeDup.dll")
        DupMC(clip, chroma, log, search)
}