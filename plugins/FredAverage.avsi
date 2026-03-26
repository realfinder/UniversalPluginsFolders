function FredAverage(clip c, Bool "Invert",Bool "TV_YUV")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/FredAverage.dll") : LoadPlugin(AviSynthPluginsDir + "26/FredAverage.dll")
        FredAverage(c, Invert,TV_YUV)
}