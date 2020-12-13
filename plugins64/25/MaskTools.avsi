function Binarize(clip clip, int "threshold", bool "upper", int "offX", int "offY", int "w", int "h", int "Y", int "U", int "V", bool "mmx", bool "isse")
{
LoadPlugin(AviSynthPlugins64Dir + "25/MaskTools.dll")
        Binarize(clip, threshold, upper, offX, offY, w, h, Y, U, V, mmx, isse)
}

function CombMask(clip clip, int "thY1", int "thY2", int "Y", int "U", int "V", bool "usemmx")
{
LoadPlugin(AviSynthPlugins64Dir + "25/MaskTools.dll")
        CombMask(clip, thY1, thY2, Y, U, V, usemmx)
}

function DEdgeMask(clip clip, int "thY1", int "thY2", int "thC1", int "thC2", string "matrix", float "divisor", bool "setdivisor", bool "vmode", int "offX", int "offY", int "w", int "h", int "Y", int "U", int "V", bool "mmx", bool "isse")
{
LoadPlugin(AviSynthPlugins64Dir + "25/MaskTools.dll")
        DEdgeMask(clip, thY1, thY2, thC1, thC2, matrix, divisor, setdivisor, vmode, offX, offY, w, h, Y, U, V, mmx, isse)
}

function FitY2U(clip clip, string "resizer")
{
LoadPlugin(AviSynthPlugins64Dir + "25/MaskTools.dll")
        FitY2U(clip, resizer)
}

function FitY2V(clip clip, string "resizer")
{
LoadPlugin(AviSynthPlugins64Dir + "25/MaskTools.dll")
        FitY2V(clip, resizer)
}

function FitY2UV(clip clip, string "resizer")
{
LoadPlugin(AviSynthPlugins64Dir + "25/MaskTools.dll")
        FitY2UV(clip, resizer)
}

function FitU2Y(clip clip, string "resizer")
{
LoadPlugin(AviSynthPlugins64Dir + "25/MaskTools.dll")
        FitU2Y(clip, resizer)
}

function FitV2Y(clip clip, string "resizer")
{
LoadPlugin(AviSynthPlugins64Dir + "25/MaskTools.dll")
        FitV2Y(clip, resizer)
}

function Inpand(clip clip, int "offX", int "offY", int "w", int "h", int "Y", int "U", int "V", bool "mmx", bool "isse")
{
LoadPlugin(AviSynthPlugins64Dir + "25/MaskTools.dll")
        Inpand(clip, offX, offY, w, h, Y, U, V, mmx, isse)
}

function Expand(clip clip, int "offX", int "offY", int "w", int "h", int "Y", int "U", int "V", bool "mmx", bool "isse")
{
LoadPlugin(AviSynthPlugins64Dir + "25/MaskTools.dll")
        Expand(clip, offX, offY, w, h, Y, U, V, mmx, isse)
}

function Deflate(clip clip, int "offX", int "offY", int "w", int "h", int "Y", int "U", int "V", bool "mmx", bool "isse")
{
LoadPlugin(AviSynthPlugins64Dir + "25/MaskTools.dll")
        Deflate(clip, offX, offY, w, h, Y, U, V, mmx, isse)
}

function Inflate(clip clip, int "offX", int "offY", int "w", int "h", int "Y", int "U", int "V", bool "mmx", bool "isse")
{
LoadPlugin(AviSynthPlugins64Dir + "25/MaskTools.dll")
        Inflate(clip, offX, offY, w, h, Y, U, V, mmx, isse)
}

function HysteresyMask(clip mask_clip1, clip mask_clip2, int "offX", int "offY", int "w", int "h", int "Y", int "U", int "V", bool "mmx", bool "isse")
{
LoadPlugin(AviSynthPlugins64Dir + "25/MaskTools.dll")
        HysteresyMask(mask_clip1, mask_clip2, offX, offY, w, h, Y, U, V, mmx, isse)
}

function Logic(clip mask_clip1, clip mask_clip2, string "mode", int "offX", int "offY", int "w", int "h", int "Y", int "U", int "V", bool "mmx", bool "isse")
{
LoadPlugin(AviSynthPlugins64Dir + "25/MaskTools.dll")
        Logic(mask_clip1, mask_clip2, mode, offX, offY, w, h, Y, U, V, mmx, isse)
}

function YV12LUT(clip clip, string "yexpr", string "uexpr", string "vexpr", int "offX", int "offY", int "w", int "h", int "Y", int "U", int "V", bool "mmx", bool "isse")
{
LoadPlugin(AviSynthPlugins64Dir + "25/MaskTools.dll")
        YV12LUT(clip, yexpr, uexpr, vexpr, offX, offY, w, h, Y, U, V, mmx, isse)
}

function RGBLUT(clip clip, string "Rexpr", string "Gexpr", string "Bexpr", int "offX", int "offY", int "w", int "h", int "R", int "G", int "B", string "AMPFile")
{
LoadPlugin(AviSynthPlugins64Dir + "25/MaskTools.dll")
        RGBLUT(clip, Rexpr, Gexpr, Bexpr, offX, offY, w, h, R, G, B, AMPFile)
}

function YV12LUTxy(clip clipx, clip clipy, string "yexpr", string "uexpr", string "vexpr", int "offX", int "offY", int "w", int "h", int "Y", int "U", int "V", bool "mmx", bool "isse")
{
LoadPlugin(AviSynthPlugins64Dir + "25/MaskTools.dll")
        YV12LUTxy(clipx, clipy, yexpr, uexpr, vexpr, offX, offY, w, h, Y, U, V, mmx, isse)
}

function MaskedMerge(clip base_clip, clip overlay_clip, clip mask_clip, int "offX", int "offY", int "w", int "h", int "Y", int "U", int "V", bool "mmx", bool "isse")
{
LoadPlugin(AviSynthPlugins64Dir + "25/MaskTools.dll")
        MaskedMerge(base_clip, overlay_clip, mask_clip, offX, offY, w, h, Y, U, V, mmx, isse)
}

function MotionMask(clip clip, int "thY1", int "thY2", int "thC1", int "thC2", int "thSD", int "offX", int "offY", int "w", int "h", int "Y", int "U", int "V", bool "mmx", bool "isse")
{
LoadPlugin(AviSynthPlugins64Dir + "25/MaskTools.dll")
        MotionMask(clip, thY1, thY2, thC1, thC2, thSD, offX, offY, w, h, Y, U, V, mmx, isse)
}

function YV12Convolution(clip clip, string "horizontal", string "vertical", int "total", bool "saturate", int "offX", int "offY", int "w", int "h", int "Y", int "U", int "V", bool "mmx", bool "isse")
{
LoadPlugin(AviSynthPlugins64Dir + "25/MaskTools.dll")
        YV12Convolution(clip, horizontal, vertical, total, saturate, offX, offY, w, h, Y, U, V, mmx, isse)
}

function YV12Subtract(clip clip1, clip clip2, int "tol", bool "widerange", int "offX", int "offY", int "w", int "h", int "Y", int "U", int "V", bool "mmx", bool "isse")
{
LoadPlugin(AviSynthPlugins64Dir + "25/MaskTools.dll")
        YV12Subtract(clip1, clip2, tol, widerange, offX, offY, w, h, Y, U, V, mmx, isse)
}