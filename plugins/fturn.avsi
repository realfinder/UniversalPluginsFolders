function fturn180(clip clip, bool "chroma")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/fturn-25.dll") : LoadPlugin(AviSynthPluginsDir + "26/fturn-26.dll")
        fturn180(clip, chroma)
}

function fturnleft(clip clip, bool "chroma", bool "mt")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/fturn-25.dll") : LoadPlugin(AviSynthPluginsDir + "26/fturn-26.dll")
        fturnleft(clip, chroma, mt)
}

function fturnright(clip clip, bool "chroma", bool "mt")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/fturn-25.dll") : LoadPlugin(AviSynthPluginsDir + "26/fturn-26.dll")
        fturnright(clip, chroma, mt)
}