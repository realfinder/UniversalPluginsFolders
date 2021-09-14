Function MSRCP(clip clip, float_array "sigma", float "lower_thr", float "upper_thr", bool "fulls", bool "fulld", float "chroma_protect")
{
LoadPlugin(AviSynthPluginsDir + "avsplus/Retinex.dll")
        MSRCP(clip, sigma, lower_thr, upper_thr, fulls, fulld, chroma_protect)
}

Function MSRCR(clip clip, float_array "sigma", float "lower_thr", float "upper_thr", bool "fulls", bool "fulld", float "restore")
{
LoadPlugin(AviSynthPluginsDir + "avsplus/Retinex.dll")
        MSRCR(clip, sigma, lower_thr, upper_thr, fulls, fulld, restore)
}