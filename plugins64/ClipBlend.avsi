function ClipBlend(clip clip, int "delay")  {
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPlugins64Dir + "25/ClipBlend.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/ClipBlend.dll")
    ClipBlend(clip, delay)
}

function ClipBlend16(clip clip, int "delay")  {
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPlugins64Dir + "25/ClipBlend.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/ClipBlend.dll")
    ClipBlend16(clip, delay)
}