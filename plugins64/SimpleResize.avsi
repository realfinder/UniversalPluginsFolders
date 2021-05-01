function SimpleResize(clip clip, int width, int height)
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPlugins64Dir + "25/SimpleResize.dll") : LoadPlugin(AviSynthPlugins64Dir + "25/SimpleResize.dll")
        SimpleResize(clip, width, height)
}


function InterlacedResize(clip clip, int width, int height)
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPlugins64Dir + "25/SimpleResize.dll") : LoadPlugin(AviSynthPlugins64Dir + "25/SimpleResize.dll")
        InterlacedResize(clip, width, height)
}


function WarpedResize(clip clip, int width, int height, float hWarp, float vWarp)
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPlugins64Dir + "25/SimpleResize.dll") : LoadPlugin(AviSynthPlugins64Dir + "25/SimpleResize.dll")
        WarpedResize(clip, width, height, hWarp, vWarp)
}


function InterlacedWarpedResize(clip clip, int width, int height, float hWarp, float vWarp)
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/SimpleResize.dll") : LoadPlugin(AviSynthPlugins64Dir + "25/SimpleResize.dll")
        InterlacedWarpedResize(clip, width, height, hWarp, vWarp)
}