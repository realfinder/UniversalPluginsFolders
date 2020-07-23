function checkmate(clip clip, int "thr", int "max", int "tthr2")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPlugins64Dir + "25/checkmate.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/checkmate.dll")
        checkmate(clip, thr, max, tthr2)
}