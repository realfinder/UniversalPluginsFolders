Function MSRCP(clip clip, float_array "sigma", float "lower_thr", float "upper_thr", bool "fulls", bool "fulld", float "chroma_protect")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/Retinex.dll")
        MSRCP(clip, sigma=sigma, lower_thr=lower_thr, upper_thr=upper_thr, fulls=fulls, fulld=fulld, chroma_protect=chroma_protect)
}

Function MSRCR(clip clip, float_array "sigma", float "lower_thr", float "upper_thr", bool "fulls", bool "fulld", float "restore")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/Retinex.dll")
        MSRCR(clip, sigma=sigma, lower_thr=lower_thr, upper_thr=upper_thr, fulls=fulls, fulld=fulld, restore=restore)
}