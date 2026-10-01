function SCXvid(clip clip, string "log")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPlugins64Dir + "25/SCXvid.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/SCXvid.dll")
        SCXvid(clip, log)
}