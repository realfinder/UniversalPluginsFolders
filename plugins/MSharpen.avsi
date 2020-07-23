function MSharpen(clip clip, int "threshold", int "strength", bool "highq", bool "mask")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/MSharpen.dll") : LoadPlugin(AviSynthPluginsDir + "26/msharpen.dll")
        MSharpen(clip, threshold, strength, highq, mask)
}