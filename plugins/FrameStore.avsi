function FrameStore(clip clip, int "n")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/FrameStore.dll") : LoadPlugin(AviSynthPluginsDir + "26/FrameStore.dll")
        FrameStore(clip, n)
}