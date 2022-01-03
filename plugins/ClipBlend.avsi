function ClipBlend(clip clip, int "delay")  {
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/ClipBlend.dll") : LoadPlugin(AviSynthPluginsDir + "26/ClipBlend.dll")
    ClipBlend(clip, delay)
}

function ClipBlend16(clip clip, int "delay")  {
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/ClipBlend.dll") : LoadPlugin(AviSynthPluginsDir + "26/ClipBlend.dll")
    ClipBlend16(clip, delay)
}