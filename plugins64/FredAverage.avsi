function FredAverage(clip c, Bool "Invert",Bool "TV_YUV")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPlugins64Dir + "25/FredAverage.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/FredAverage.dll")
        FredAverage(c, Invert,TV_YUV)
}