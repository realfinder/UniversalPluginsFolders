function DeinterlaceSwitch(clip progressive, clip deinterlaced, bool "info", bool "visualize")
{
LoadPlugin(AviSynthPlugins64Dir + "26/DeinterlaceSwitch.dll")
        DeinterlaceSwitch(progressive, deinterlaced, info, visualize)
}

function LineDoubleSwitch(clip progressive, clip corrected, bool "info", bool "visualize")
{
LoadPlugin(AviSynthPlugins64Dir + "26/DeinterlaceSwitch.dll")
        LineDoubleSwitch(progressive, corrected, info, visualize)
}