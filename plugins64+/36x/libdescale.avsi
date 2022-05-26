function Debilinear(clip src, int width, int height, float "src_left", float "src_top", float "src_width", float "src_height", bool "force", bool "force_h", bool "force_v", int "opt")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/libdescale.dll")
        Debilinear(src, width, height, src_left, src_top, src_width, src_height, force, force_h, force_v, opt)
}

function Debicubic(clip src, int width, int height, float "b", float "c", float "src_left", float "src_top", float "src_width", float "src_height", bool "force", bool "force_h", bool "force_v", int "opt")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/libdescaledll")
        Debicubic(src, width, height, b, c, src_left, src_top, src_width, src_height, force, force_h, force_v, opt)
}

function Delanczos(clip src, int width, int height, int "taps", float "src_left", float "src_top", float "src_width", float "src_height", bool "force", bool "force_h", bool "force_v", int "opt")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/libdescaledll")
        Delanczos(src, width, height, taps, src_left, src_top, src_width, src_height, force, force_h, force_v, opt)
}

function Despline16(clip src, int width, int height, float "src_left", float "src_top", float "src_width", float "src_height", bool "force", bool "force_h", bool "force_v", int "opt")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/libdescaledll")
        Despline16(src, width, height, src_left, src_top, src_width, src_height, force, force_h, force_v, opt)
}

function Despline36(clip src, int width, int height, float "src_left", float "src_top", float "src_width", float "src_height", bool "force", bool "force_h", bool "force_v", int "opt")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/libdescaledll")
        Despline36(src, width, height, src_left, src_top, src_width, src_height, force, force_h, force_v, opt)
}

function Despline64(clip src, int width, int height, float "src_left", float "src_top", float "src_width", float "src_height", bool "force", bool "force_h", bool "force_v", int "opt")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/libdescaledll")
        Despline64(src, width, height, src_left, src_top, src_width, src_height, force, force_h, force_v, opt)
}

function Descale(clip src, int width, int height, string "kernel", int "taps", float "b", float "c", float "src_left", float "src_top", float "src_width", float "src_height", bool "force", bool "force_h", bool "force_v", int "opt")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/libdescaledll")
        Descale(src, width, height, kernel, taps, b, c, src_left, src_top, src_width, src_height, force, force_h, force_v, opt)
}