function FrameStore(clip clip, int "n")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPlugins64Dir + "25/FrameStore.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/FrameStore.dll")
        FrameStore(clip, n)
}