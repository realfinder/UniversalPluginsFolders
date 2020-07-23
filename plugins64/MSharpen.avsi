function MSharpen(clip clip, int "threshold", int "strength", bool "highq", bool "mask")
{
LoadPlugin(AviSynthPlugins64Dir + "26/msharpen.dll")
        MSharpen(clip, threshold, strength, highq, mask)
}