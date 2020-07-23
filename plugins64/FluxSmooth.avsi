function FluxSmoothT(clip clip, int "temporal_threshold", bool "luma", bool "chroma", int "opt")
{
sisavs25=VersionNumber() < 2.60
sisavs25 ? LoadPlugin(AviSynthPlugins64Dir + "25/FluxSmoothSSE2.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/FluxSmooth.dll")
        sisavs25 ? FluxSmoothT(clip, temporal_threshold) : FluxSmoothT(clip, temporal_threshold, luma, chroma, opt)
}

function FluxSmoothST(clip clip, int "temporal_threshold", int "spatial_threshold", bool "luma", bool "chroma", int "opt")
{
sisavs25=VersionNumber() < 2.60
sisavs25 ? LoadPlugin(AviSynthPlugins64Dir + "25/FluxSmoothSSE2.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/FluxSmooth.dll")
        sisavs25 ? FluxSmoothST(clip, temporal_threshold, spatial_threshold) : FluxSmoothST(clip, temporal_threshold, spatial_threshold, luma, chroma, opt)
}