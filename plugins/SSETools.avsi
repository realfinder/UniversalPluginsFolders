function AmplifyDifference(Clip Clip1, Clip Clip2, Float "factor", Float "factorU", Float "factorV", bool "grey")
{
LoadPlugin(AviSynthPluginsDir + "25/SSE3Tools.dll")
        AmplifyDifference(Clip1, Clip2, factor, factorU, factorV, grey)
}

function Difference(Clip Clip1, Clip Clip2, int "frames", int "tolerance", bool "above", bool "yuv")
{
LoadPlugin(AviSynthPluginsDir + "25/SSE3Tools.dll")
        Difference(Clip1, Clip2, frames, tolerance, above, yuv)
}

function Interleaved2Planar(clip clip, bool "grey")
{
LoadPlugin(AviSynthPluginsDir + "25/SSE3Tools.dll")
        Interleaved2Planar(Clip, grey)
}

function LimitChange(Clip Clip1, Clip Clip2, int limit, int "limitU", int "limitV")
{
LoadPlugin(AviSynthPluginsDir + "25/SSE3Tools.dll")
        LimitChange(Clip1, Clip2, limit, limitU, limitV)
}

function Planar2Interleaved(clip clip, bool "grey")
{
LoadPlugin(AviSynthPluginsDir + "25/SSE3Tools.dll")
        Planar2Interleaved(Clip, grey)
}

function Quadruple(Clip, bool "grey")
{
LoadPlugin(AviSynthPluginsDir + "25/SSE3Tools.dll")
        Quadruple(Clip, grey)
}

function ReduceFluctuations(Clip, int "limit", int "limitU", int "limitV", bool "reduceflicker")
{
LoadPlugin(AviSynthPluginsDir + "25/SSE3Tools.dll")
        ReduceFluctuations(Clip, limit, limitU, limitV, reduceflicker)
}

function Shrinkby2(Clip, bool "grey")
{
LoadPlugin(AviSynthPluginsDir + "25/SSE3Tools.dll")
        Shrinkby2(Clip, grey)
}

function TransformColor(Clip, float f1, float f2, float f3, float f4, float f5, float f6, float f7, float f8, float f9, float f10)
{
LoadPlugin(AviSynthPluginsDir + "25/SSE3Tools.dll")
        TransformColor(Clip, f1, f2, f3, f4, f5, f6, f7, f8, f9, f10)
}

function Truncate(Clip, lowerY, upperY, int "lowerU", int "upperU", int "lowerV", int "upperV")
{
LoadPlugin(AviSynthPluginsDir + "25/SSE3Tools.dll")
        Truncate(Clip, lowerY, upperY, lowerU, upperU, lowerV, upperV)
}