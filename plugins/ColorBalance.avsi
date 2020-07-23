function ColorBalance(clip clip, float "rs", float "gs", float "bs", float "rm", float "gm", float "bm", float "rh", float "gh", float "bh", bool "keep_luma", bool "clone_gimp", bool "highcolor")
{
LoadPlugin(AviSynthPluginsDir + "25/ColorBalance.dll")
        ColorBalance(clip, rs, gs, bs, rm, gm, bm, rh, gh, bh, keep_luma, clone_gimp, highcolor)
}