function CombMask(clip, int "thY1", int "thY2", int "y", int "u", int "v", bool "usemmx")  {
LoadPlugin(AviSynthPlugins64Dir + "26/MTCombMask.dll")
    CombMask(clip, thY1, thY2, y, u, v, usemmx)
}