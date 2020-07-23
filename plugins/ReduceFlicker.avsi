function ReduceFlicker(clip clip, int "strength", bool "aggressive", bool "grey", int "opt", bool "raccess", bool "luma", bool "planar")
{
sisavs25 = VersionNumber() < 2.60
sisavs25 ? LoadPlugin(AviSynthPluginsDir + "25/ReduceFlickerSSE3.dll") : LoadPlugin(AviSynthPluginsDir + "26/ReduceFlicker.dll")
        sisavs25 ? ReduceFlicker(clip, strength, aggressive, grey, planar) : ReduceFlicker(clip, strength, aggressive, grey, opt, raccess, luma)
}

function ReduceFluctuations(clip clip, clip "previous", clip "next", int "limit", int "limitU", int "limitV", int "limitA", int "recursive", bool "planar")
{
sisavs25 = VersionNumber() < 2.60
sisavs25 ? LoadPlugin(AviSynthPluginsDir + "25/ReduceFlickerSSE3.dll") : nop()
        sisavs25 ? ReduceFluctuations(clip, previous, next, limit, limitU, limitV, limitA, recursive, planar) : nop()
}

function LockClense(clip clip, int "limit", int "limitU", int "limitV", int "limitA", bool "clense", int "recursive", bool "planar")
{
sisavs25 = VersionNumber() < 2.60
sisavs25 ? LoadPlugin(AviSynthPluginsDir + "25/ReduceFlickerSSE3.dll") : nop()
        sisavs25 ? LockClense(clip, limit, limitU, limitV, limitA, clense, recursive, planar) : nop()
}