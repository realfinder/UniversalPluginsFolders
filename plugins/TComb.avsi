function TComb(clip clip, int "mode", int "fthreshL", int "fthreshC", int "othreshL", int "othreshC", bool "map", float "scthresh", bool "debug", int "opt")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/TComb.dll") : LoadPlugin(AviSynthPluginsDir + "26/TComb.dll")
        VersionNumber() < 2.60 ? TComb(clip, mode, fthreshL, fthreshC, othreshL, othreshC, map, scthresh, debug, opt) : TComb(clip, mode, fthreshL, fthreshC, othreshL, othreshC, map, scthresh, debug)
}