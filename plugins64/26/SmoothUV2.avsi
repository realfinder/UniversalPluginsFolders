function SmoothUV(clip clip, int "radius", int "threshold", bool "interlaced") 
{
LoadPlugin(AviSynthPlugins64Dir + "26/SmoothUV2.dll")
        SmoothUV(clip, radius, threshold, interlaced) 
}


function SmoothUV2(clip clip, int "radius", int "threshold", int "interlaced")
{
LoadPlugin(AviSynthPlugins64Dir + "26/SmoothUV2.dll")
        SmoothUV2(clip, radius, threshold, interlaced)
}