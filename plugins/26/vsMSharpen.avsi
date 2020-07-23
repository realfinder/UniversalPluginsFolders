function vsMSharpen(clip clip, float "threshold", float "strength", bool "mask", bool "luma", bool "chroma")
{
LoadPlugin(AviSynthPluginsDir + "26/vsMSharpen.dll")
        vsMSharpen(clip, threshold, strength, mask, luma, chroma)
}