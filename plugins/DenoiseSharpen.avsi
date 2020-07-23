function ClenseSharpen(clip clip, bool "grey", bool "reduceflicker", bool "planar", int "cache")
{
LoadPlugin(AviSynthPluginsDir + "25/DenoiseSharpen.dll")
        ClenseSharpen(clip, grey, reduceflicker, planar, cache)
}


function DenoiseSharpen(clip clip, int "mode", int "modeU", int "modeV", int "strength", int "strengthU", int "strengthV", bool "planar")
{
LoadPlugin(AviSynthPluginsDir + "25/DenoiseSharpen.dll")
        DenoiseSharpen(clip, mode, modeU, modeV, strength, strengthU, strengthV, planar)
}