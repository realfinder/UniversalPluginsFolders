function vinverse(clip clip, float "sstr", int "amnt", int "uv", float "scl", int "opt", clip "clip2", int "thr")
{
avs25=VersionNumber() < 2.60
avs25 ? LoadPlugin(AviSynthPlugins64Dir + "25/vinverse.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/vinverse.dll")
        avs25 ? vinverse(clip, sstr, amnt, uv, scl) : vinverse(clip, sstr, amnt, uv, scl, opt, clip2, thr)
}

function vinverse2(clip clip, float "sstr", int "amnt", int "uv", float "scl", int "opt")
{
LoadPlugin(AviSynthPlugins64Dir + "26/vinverse.dll")
        vinverse2(clip, sstr, amnt, uv, scl, opt)
}