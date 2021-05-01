function SmoothUV(clip clip, int "radius", int "threshold", bool "interlaced") 
{
LoadPlugin(AviSynthPluginsDir + "26/SmoothUV.dll")
        SmoothUV(clip, radius, threshold, interlaced) 
}

function SmoothUV2(clip clip, int "radius", int "threshold", int "interlaced")
{
LoadPlugin(AviSynthPluginsDir + "26/SmoothUV2.dll")
        SmoothUV2(clip, radius, threshold, interlaced)
}