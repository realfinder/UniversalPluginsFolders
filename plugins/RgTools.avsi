function VerticalCleaner(clip clip, int "mode", int "modeU", int "modeV", bool "planar") 
{
sisavs26=!(VersionNumber() < 2.60)
!sisavs26 ? LoadPlugin(AviSynthPluginsDir + "25/VerticalCleanerSSE2.dll") : LoadPlugin(AviSynthPluginsDir + "26/RgTools.dll")
        !sisavs26 ? VerticalCleaner(clip, mode, mode, modeU, modeV, planar) : VerticalCleaner(clip, mode, modeU, modeV, planar)
}

function RSharpen(clip clip, int "mode", int "modeU", int "modeV", int "strength", int "strengthU", int "strengthV", bool "planar") 
{
LoadPlugin(AviSynthPluginsDir + "25/RSharpenSSE3.dll")
        RSharpen(clip, mode, modeU, modeV, strength, strengthU, strengthV, planar) 
}

function MotionSharpen(clip clip, bool "grey", bool "reduceflicker", bool "planar", int "cache")
{
LoadPlugin(AviSynthPluginsDir + "25/RSharpenTSSE3.dll")
        MotionSharpen(clip, grey, reduceflicker, planar, cache)
}

function Repair(clip clip1, clip clip2, int "mode", int "modeU", int "modeV", bool "planar")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/RepairSSE2.dll") : LoadPlugin(AviSynthPluginsDir + "26/RgTools.dll")
        Repair(clip1, clip2, mode, modeU, modeV, planar)
}

function TemporalRepair(clip clip1, clip clip2, int "mode", int "smooth", bool "grey", bool "planar") 
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/RepairSSE2.dll") : LoadPlugin(AviSynthPluginsDir + "26/RgTools.dll")
        TemporalRepair(clip1, clip2, mode, smooth, grey, planar)
}

function MCClense(clip clip, clip clipf, clip clipb, bool "grey", bool "planar")
{
LoadPlugin(AviSynthPluginsDir + "25/RemoveGrainSSE2.dll")
        MCClense(clip, clipf, clipb, grey, planar)
}

function Clense(clip clip, clip "previous", clip "next", bool "grey", bool "reduceflicker", bool "planar", int "cache")
{
sisavs25 = VersionNumber() < 2.60
sisavs25 ? LoadPlugin(AviSynthPluginsDir + "25/RemoveGrainSSE2.dll") : LoadPlugin(AviSynthPluginsDir + "26/RgTools.dll")
        sisavs25 ? Clense(clip, grey, reduceflicker, planar, cache) : Clense(clip, previous, next, grey, reduceflicker, planar, cache)
}

function RemoveGrain(clip clip, int "mode", int "modeU", int "modeV", bool "planar")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/RemoveGrainSSE2.dll") : LoadPlugin(AviSynthPluginsDir + "26/RgTools.dll")
        RemoveGrain(clip, mode, modeU, modeV, planar)
}

function ForwardClense(clip clip, bool "grey", bool "planar", int "cache")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/RemoveGrainSSE2.dll") : LoadPlugin(AviSynthPluginsDir + "26/RgTools.dll")
        ForwardClense(clip, grey, planar, cache)
}

function BackwardClense(clip clip, bool "grey", bool "planar", int "cache")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/RemoveGrainSSE2.dll") : LoadPlugin(AviSynthPluginsDir + "26/RgTools.dll")
        BackwardClense(clip, grey, planar, cache)
}