function TDeint(clip clip, int "mode", int "order", int "field", int "mthreshL", int "mthreshC", int "map", string "ovr", int "ovrDefault", int "type", bool "debug", int "mtnmode", bool "sharp", bool "hints", Clip "clip2", bool "full", int "cthresh", bool "chroma", int "MI", bool "tryWeave", int "link", bool "denoise", int "AP", int "blockx", int "blocky", int "APType", Clip "edeint", Clip "emask", float "blim", int "metric", int "expand", int "slow", Clip "emtn", bool "tshints", int "opt")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPlugins64Dir + "25/TDeinterlace.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/TDeint.dll")
        TDeint(clip, mode, order, field, mthreshL, mthreshC, map, ovr, ovrDefault, type, debug, mtnmode, sharp, hints, clip2, full, cthresh, chroma, MI, tryWeave, link, denoise, AP, blockx, blocky, APType, edeint, emask, blim, metric, expand, slow, emtn, tshints, opt)
}

function TSwitch(clip clip, clip "c1", clip "c2", bool "debug")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPlugins64Dir + "25/TDeinterlace.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/TDeint.dll")
        TSwitch(clip, c1, c2, debug)
}