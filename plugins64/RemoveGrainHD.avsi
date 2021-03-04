function Quantile(clip clip, int "radius", int "rank", int "radius_y", int "yradius_y", int "rank_y", int "radius_u", int "yradius_u", int "rank_u", int "radius_v", int "yradius_v", int "rank_v", bool "planar")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPlugins64Dir + "25/RemoveGrainHD.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/RemoveGrainHD.dll")
        Quantile(clip, radius, rank, radius_y, yradius_y, rank_y, radius_u, yradius_u, rank_u, radius_v, yradius_v, rank_v, planar)
}

function RemoveGrainHD(clip clip, clip "repair", int "radius", int "rank", int "radius_y", int "yradius_y", int "rank_y", int "urank_y", int "radius_u", int "yradius_u", int "rank_u", int "urank_u", int "radius_v", int "yradius_v", int "rank_v", int "urank_v", bool "planar") 
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPlugins64Dir + "25/RemoveGrainHD.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/RemoveGrainHD.dll")
        RemoveGrainHD(clip, repair, radius, rank, radius_y, yradius_y, rank_y, urank_y, radius_u, yradius_u, rank_u, urank_u, radius_v, yradius_v, rank_v ,urank_v, planar)
}

function TemporalRemoveGrainHD(clip clip, clip "repair", int "radius", int "rank", int "radius_y", int "yradius_y", int "rank_y", int "urank_y", int "radius_u", int "yradius_u", int "rank_u", int "urank_u", int "radius_v", int "yradius_v", int "rank_v", int "urank_v", int "weighted", bool "planar")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPlugins64Dir + "25/RemoveGrainHD.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/RemoveGrainHD.dll")
        TemporalRemoveGrainHD(clip, repair, radius, rank, radius_y, yradius_y, rank_y, urank_y, radius_u, yradius_u, rank_u, urank_u, radius_v, yradius_v, rank_v, urank_v, weighted, planar)
}

function SmartMedian(clip clip, int "radius", int "pixels", int "radius_y", int "yradius_y", int "pixels_y", int "radius_u", int "yradius_u", int "pixels_u", int "radius_v", int "yradius_v", int "pixels_v", bool "planar")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPlugins64Dir + "25/RemoveGrainHD.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/RemoveGrainHD.dll")
        SmartMedian(clip, radius, pixels, radius_y, yradius_y, pixels_y, radius_u, yradius_u, pixels_u, radius_v, yradius_v, pixels_v, planar)
}

function SmartMedian2(clip input1, clip input2, int "radius", int "pixels", int "radius_y", int "yradius_y", int "pixels_y", int "radius_u", int "yradius_u", int "pixels_u", int "radius_v", int "yradius_v", int "pixels_v", int "weight", bool "planar")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPlugins64Dir + "25/RemoveGrainHD.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/RemoveGrainHD.dll")
        SmartMedian2(input1, input2, radius, pixels, radius_y, yradius_y, pixels_y, radius_u, yradius_u, pixels_u, radius_v, yradius_v, pixels_v, weight, planar)
}

function RankRepair(clip filtered, clip original, int "radius", int "radius_y", int "yradius_y", int "radius_u", int "yradius_u", int "radius_v", int "yradius_v", bool "restore_chroma", bool "planar")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPlugins64Dir + "25/RemoveGrainHD.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/RemoveGrainHD.dll")
        RankRepair(filtered, original, radius, radius_y, yradius_y, radius_u, yradius_u, radius_v, yradius_v, restore_chroma, planar)
}