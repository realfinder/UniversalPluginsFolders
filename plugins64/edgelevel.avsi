function edgelevel(clip clip, int "strength", int "threshold", int "bc", int "wc", int "thread", int "simd")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPlugins64Dir + "25/edgelevel.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/edgelevel.dll")
    VersionNumber() < 2.60 ? edgelevel(clip, strength, threshold, bc, wc, thread) : edgelevel(clip, strength, threshold, bc, wc, thread, simd)
}