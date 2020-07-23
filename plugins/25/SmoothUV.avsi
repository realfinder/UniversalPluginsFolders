function SmoothUV(clip clip, int "radius", int "threshold", bool "field") 
{
LoadPlugin(AviSynthPluginsDir + "25/SmoothUV.dll")
        SmoothUV(clip, radius, threshold, field) 
}

function SSHiQ(clip clip, int "rY", int "rC", int "tY", int "tC", bool "HQY", bool "HQC", bool "field")
{
LoadPlugin(AviSynthPluginsDir + "25/SmoothUV.dll")
        SSHiQ(clip, rY, rC, tY, tC, HQY, HQC, field)
}