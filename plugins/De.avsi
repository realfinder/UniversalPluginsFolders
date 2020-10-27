function DeDot(clip clip, int "luma2d", int "lumaT", int "chromaT1", int "chromaT2")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/De.dll") : LoadPlugin(AviSynthPluginsDir + "26/DeDot.dll")
        DeDot(clip, luma2d, lumaT, chromaT1, chromaT2)
}