function SmoothUV(clip clip, int "radius", int "threshold", bool "interlaced") 
{
LoadPlugin(AviSynthPlugins64Dir + "26/SmoothUV.dll")
        SmoothUV(clip, radius, threshold, interlaced) 
}


function SmoothUV2(clip clip, int "radius", int "threshold", int "interlaced")
{
LoadPlugin(AviSynthPlugins64Dir + "26/SmoothUV2.dll")
        SmoothUV2(clip, radius, threshold, interlaced)
}


function SSHiQ2(clip clip, int "rY", int "rC", int "tY", int "tC", int "str", bool "HQY", bool "HQC", int "interlaced")
{
LoadPlugin(AviSynthPlugins64Dir + "26/SmoothUV2.dll")
        SSHiQ2(clip, rY, rC, tY, tC, str, HQY, HQC, interlaced)
}