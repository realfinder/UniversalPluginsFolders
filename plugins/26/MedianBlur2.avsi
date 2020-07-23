function MedianBlur(clip clip, int "radiusy", int "radiusu", int "radiusv")
{
LoadPlugin(AviSynthPluginsDir + "26/MedianBlur2.dll")
        MedianBlur(clip, radiusy, radiusu, radiusv)
}

function MedianBlurTemporal(clip clip, int "radiusy", int "radiusu", int "radiusv", int "temporalradius")
{
LoadPlugin(AviSynthPluginsDir + "26/MedianBlur2.dll")
        MedianBlurTemporal(clip, radiusy, radiusu, radiusv, temporalradius)
}