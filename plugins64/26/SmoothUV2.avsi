function SmoothUV(clip clip, int "radius", int "threshold", bool "interlaced") 
{
LoadPlugin(AviSynthPlugins64Dir + "26/SmoothUV2.dll")
        SmoothUV(clip, radius, threshold, interlaced) 
}