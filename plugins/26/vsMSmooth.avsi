function vsMSmooth(clip clip, float "threshold", float "strength", bool "mask", bool "luma", bool "chroma")
{
LoadPlugin(AviSynthPluginsDir + "26/vsMSmooth.dll")
        vsMSmooth(clip, threshold, strength, mask, luma, chroma)
}