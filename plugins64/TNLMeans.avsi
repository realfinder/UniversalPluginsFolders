function TNLMeans(clip clip, int "Ax", int "Ay", int "Az", int "Sx", int "Sy", int "Bx", int "By", bool "ms", int "rm", float "a", float "h", bool "sse")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPlugins64Dir + "25/TNLMeans.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/TNLMeans.dll")
        TNLMeans(clip, Ax, Ay, Az, Sx, Sy, Bx, By, ms, rm, a, h, sse)
}