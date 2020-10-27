function DeDot(clip clip, int "luma2d", int "lumaT", int "chromaT1", int "chromaT2")
{
LoadPlugin(AviSynthPlugins64Dir + "26/DeDot.dll")
        DeDot(clip, luma2d, lumaT, chromaT1, chromaT2)
}