Function neo_smo_CCD(clip clip, float "threshold", int "temporal_radius", int_array "points", float "scale", clip "ref")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/neo-smo.dll")
        neo_smo_CCD(clip, threshold, temporal_radius, points=points, scale=scale, ref=ref)
}


Function neo_smo_Clense(clip clip, clip "previous", clip "next", int_array "planes")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/neo-smo.dll")
        neo_smo_Clense(clip, previous, next, planes=planes)
}


Function neo_smo_ForwardClense(clip clip, int_array "planes")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/neo-smo.dll")
        neo_smo_ForwardClense(clip, planes=planes)
}


Function neo_smo_BackwardClense(clip clip, int_array "planes")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/neo-smo.dll")
        neo_smo_BackwardClense(clip, planes=planes)
}


Function neo_smo_Cnr4(clip clip, string "mode", int "radius", int_array "sense", int_array "str", float_array "pow", int "tmode", int "wmode", bool "scenechange", clip "ref")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/neo-smo.dll")
        neo_smo_Cnr4(clip, mode, radius, sense=sense, str=str, pow=pow, tmode=tmode, wmode=wmode, scenechange=scenechange, ref=ref)
}


Function neo_smo_DCTFilter(clip clip, array "factors", string "planes")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/neo-smo.dll")
        neo_smo_DCTFilter(clip, factors=factors, planes=planes)
}


Function neo_smo_Deen(clip clip, string "mode", int_array "radius", float_array "threshold", float_array "temporal_threshold", float_array "minimum", int "scenechange", bool "scalep", int_array "planes")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/neo-smo.dll")
        neo_smo_Deen(clip, mode, radius=radius, threshold=threshold, temporal_threshold=temporal_threshold, minimum=minimum, scenechange=scenechange, scalep=scalep, planes=planes)
}


Function neo_smo_MiniDeen(clip clip, int_array "radius", int_array "threshold", bool "scalep", int_array "planes")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/neo-smo.dll")
        neo_smo_MiniDeen(clip, radius=radius, threshold=threshold, scalep=scalep, planes=planes)
}


Function neo_smo_DegrainMedian(clip clip, int_array "limit", int_array "mode", bool "interlaced", bool "norow", bool "scalep")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/neo-smo.dll")
        neo_smo_DegrainMedian(clip, limit=limit, mode=mode, interlaced=interlaced, norow=norow, scalep=scalep)
}


Function neo_smo_FluxSmoothT(clip clip, float_array "temporal_threshold", int_array "planes", bool "scalep")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/neo-smo.dll")
        neo_smo_FluxSmoothT(clip, temporal_threshold=temporal_threshold, planes=planes, scalep=scalep)
}


Function neo_smo_FluxSmoothST(clip clip, float_array "temporal_threshold", float_array "spatial_threshold", int_array "planes", bool "scalep")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/neo-smo.dll")
        neo_smo_FluxSmoothST(clip, temporal_threshold=temporal_threshold, spatial_threshold=spatial_threshold, planes=planes, scalep=scalep)
}


Function neo_smo_RemoveGrain(clip clip, int_array "mode")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/neo-smo.dll")
        neo_smo_RemoveGrain(clip, mode=mode)
}


Function neo_smo_Repair(clip clip, clip repairclip, int_array "mode")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/neo-smo.dll")
        neo_smo_Repair(clip, repairclip, mode=mode)
}


Function neo_smo_Median(clip clip, int_array "radius", int_array "planes")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/neo-smo.dll")
        neo_smo_Median(clip, radius=radius, planes=planes)
}


Function neo_smo_InterQuartileMean(clip clip, int_array "radius", int_array "planes")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/neo-smo.dll")
        neo_smo_InterQuartileMean(clip, radius=radius, planes=planes)
}


Function neo_smo_SmartMedian(clip clip, int_array "radius", float_array "threshold", bool "scalep", int_array "planes")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/neo-smo.dll")
        neo_smo_SmartMedian(clip, radius=radius, threshold=threshold, scalep=scalep, planes=planes)
}


Function neo_smo_TemporalMedian(clip clip, int "radius", int_array "planes", bool "scenechange")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/neo-smo.dll")
        neo_smo_TemporalMedian(clip, radius, planes=planes, scenechange=scenechange)
}


Function neo_smo_TemporalSoften(clip clip, int "radius", float_array "threshold", int "scenechange", bool "scalep", int_array "planes")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/neo-smo.dll")
        neo_smo_TemporalSoften(clip, radius, threshold=threshold, scenechange=scenechange, scalep=scalep, planes=planes)
}


Function neo_smo_TemporalRepair(clip clip, clip repairclip, int_array "mode", int_array "planes")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/neo-smo.dll")
        neo_smo_TemporalRepair(clip, repairclip, mode=mode, planes=planes)
}


Function neo_smo_TTempSmooth(clip clip, int "maxr", int_array "thresh", int_array "mdiff", int "strength", float "scthresh", bool "fp", clip "pfclip", int_array "planes")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/neo-smo.dll")
        neo_smo_TTempSmooth(clip, maxr, thresh=thresh, mdiff=mdiff, strength=strength, scthresh=scthresh, fp=fp, pfclip=pfclip, planes=planes)
}


Function neo_smo_VerticalCleaner(clip clip, int_array "mode")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/neo-smo.dll")
        neo_smo_VerticalCleaner(clip, mode=mode)
}