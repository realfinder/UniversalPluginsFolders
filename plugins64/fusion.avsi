function fuse(clip clip1, clip clip2, clip clipm, bool "clamp")
{
LoadPlugin(AviSynthPlugins64Dir + "25/fusion.dll")
        fuse(clip1, clip2, clip1m, clamp)
}


function fusemask(clip clip1, clip clip2, bool "exp")
{
LoadPlugin(AviSynthPlugins64Dir + "25/fusion.dll")
        fusemask(clip1, clip2, exp)
}


function fusevis(clip clip)
{
LoadPlugin(AviSynthPlugins64Dir + "25/fusion.dll")
        fusevis(clip)
}