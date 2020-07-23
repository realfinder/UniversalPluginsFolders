function RestoreMotionBlocks(clip filtered, clip restore, clip "neighbour", clip "neighbour2", clip "alternative", bool "planar", bool "show", bool "debug", int "gmthreshold", int "mthreshold", int "noise", int "noisy", int "dist", int "tolerance", int "dmode", int "pthreshold", int "cthreshold", bool "grey")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/RemoveDirtSSE2.dll") : LoadPlugin(AviSynthPluginsDir + "26/RemoveDirt.dll")
        RestoreMotionBlocks(filtered, restore, neighbour, neighbour2, alternative, planar, show, debug, gmthreshold, mthreshold, noise, noisy, dist, tolerance, dmode, pthreshold, cthreshold, grey)
}

function SCSelect(clip input, clip scene_begin, clip scene_end, clip global_motion, float "dfactor", bool "debug", bool "planar", int "cache", int "gcache")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/RemoveDirtSSE2.dll") : LoadPlugin(AviSynthPluginsDir + "26/RemoveDirt.dll")
        SCSelect(input, scene_begin, scene_end, global_motion, dfactor, debug, planar, cache, gcache)
}