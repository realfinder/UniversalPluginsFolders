function DitherPost(clip clip, clip "clsb", int "mode", float "ampo", float "ampn", int "pat", bool "dyn", bool "prot", clip "mask", float "thr", bool "stacked", bool "interlaced", int "y", int "u", int "v", bool "staticnoise", bool "slice")
{
LoadPlugin(AviSynthPlugins64Dir + "25/25b/dither.dll")
        DitherPost(clip, clsb, mode, ampo, ampn, pat, dyn, prot, mask, thr, stacked, interlaced, y, u, v, staticnoise, slice)
}

function SmoothGrad(clip clip, clip "clsb", int "radius", float "thr", bool "stacked", clip "ref", float "elast", int "y", int "u", int "v" )
{
LoadPlugin(AviSynthPlugins64Dir + "25/25b/dither.dll")
        SmoothGrad(clip, clsb, radius, thr, stacked, ref, elast, y, u, v)
}

function SmoothGrad(clip clip, clip "clsb", int "radius", float "thr", bool "stacked", clip "ref", float "elast", int "y", int "u", int "v" )
{
LoadPlugin(AviSynthPlugins64Dir + "25/25b/dither.dll")
        SmoothGrad(clip, clsb, radius, thr, stacked, ref, elast, y, u, v)
}

function Dither_box_filter16(clip clip, int "radius", int "y", int "u", int "v")
{
LoadPlugin(AviSynthPlugins64Dir + "25/25b/dither.dll")
        Dither_box_filter16(clip, radius, y, u, v)
}

function Dither_bilateral16(clip clip, clip "ref", int "radius", float "thr", float "flat", float "wmin", float "subspl", int "y", int "u", int "v")
{
LoadPlugin(AviSynthPlugins64Dir + "25/25b/dither.dll")
        Dither_bilateral16(clip, ref, radius, thr, flat, wmin, subspl, y, u, v)
}

function Dither_limit_dif16(clip flt, clip src, clip "ref", float "thr", float "elast", int "y", int "u", int "v")
{
LoadPlugin(AviSynthPlugins64Dir + "25/25b/dither.dll")
        Dither_limit_dif16(flt, src, ref, thr, elast, y, u, v)
}

function Dither_resize16(clip clip, int "width", int "height", float "src_left", float "src_top", float "src_width", float "src_height", string "kernel", float "fh", float "fv", int "taps", float "a1", float "a2", float "a3", int "kovrspl", bool "cnorm", bool "center", string "cplace", int "y", int "u", int "v", string "kernelh", string "kernelv", float "totalh", float "totalv", bool "invks", bool "invksh", bool "invksv", int "invkstaps", string "cplaces", string "cplaced", string "csp")
{
LoadPlugin(AviSynthPlugins64Dir + "25/25b/dither.dll")
        Dither_resize16(clip, width, height, src_left, src_top, src_width, src_height, kernel, fh, fv, taps, a1, a2, a3, kovrspl, cnorm, center, cplace, y, u, v, kernelh, kernelv, totalh, totalv, invks, invksh, invksv, invkstaps, cplaces, cplaced, csp)
}

function Dither_out(clip clip, bool "bigendian")
{
LoadPlugin(AviSynthPlugins64Dir + "25/25b/dither.dll")
        Dither_out(clip, bigendian)
}

function Dither_removegrain16(clip clip, int "mode", int "modeU", int "modeV")
{
LoadPlugin(AviSynthPlugins64Dir + "25/25b/dither.dll")
        Dither_removegrain16(clip, mode, modeU, modeV)
}

function Dither_repair16(clip src1, clip src2, int "mode", int "modeU", int "modeV")
{
LoadPlugin(AviSynthPlugins64Dir + "25/25b/dither.dll")
        Dither_repair16(src1, src2, mode, modeU, modeV)
}

function Dither_median16(clip clip, int "rx", int "ry", int "rt", int "ql", int "qh", int "y", int "u", int "v")
{
LoadPlugin(AviSynthPlugins64Dir + "25/25b/dither.dll")
        Dither_median16(clip, rx, ry, rt, ql, qh, y, u, v)
}

function Dither_add16(clip src1, clip src2, bool "wrap", int "y", int "u", int "v", bool "dif")
{
LoadPlugin(AviSynthPlugins64Dir + "25/25b/dither.dll")
        DDither_add16(src1, src2, wrap, y, u, v, dif)
}

function Dither_sub16(clip src1, clip src2, bool "wrap", int "y", int "u", int "v", bool "dif")
{
LoadPlugin(AviSynthPlugins64Dir + "25/25b/dither.dll")
        Dither_sub16(src1, src2, wrap, y, u, v, dif)
}

function Dither_max_dif16(clip src1, clip src2, clip ref, int "y", int "u", int "v", bool "dif")
{
LoadPlugin(AviSynthPlugins64Dir + "25/25b/dither.dll")
        Dither_max_dif16(src1, src2, ref, y, u, v, dif)
}

function Dither_min_dif16(clip src1, clip src2, clip ref, int "y", int "u", int "v", bool "dif")
{
LoadPlugin(AviSynthPlugins64Dir + "25/25b/dither.dll")
        Dither_min_dif16(src1, src2, ref, y, u, v, dif)
}

function Dither_merge16(clip src1, clip src2, clip mask, bool "luma", int "y", int "u", int "v")
{
LoadPlugin(AviSynthPlugins64Dir + "25/25b/dither.dll")
        Dither_merge16(src1, src2, mask, luma, y, u, v)
}