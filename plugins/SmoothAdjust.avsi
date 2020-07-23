function SmoothLevels(clip clip, int "input_low", float "gamma", int "input_high", int "output_low", int "output_high", int "chroma", int "limiter", bool "TVrange", string "preset", int "Lmode", int "darkSTR", int "brightSTR", int "Ecurve", int "Ecenter", int "protect", int "interp", int "dither", bool "HQ", int "useMT", int "useOPT", bool "debug", int "screenW", int "screenH", bool "scale" )
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/SmoothAdjust.dll") : LoadPlugin(AviSynthPluginsDir + "26/SmoothAdjust.dll")
        SmoothLevels(clip, input_low, gamma, input_high, output_low, output_high, chroma, limiter, TVrange, preset, Lmode, darkSTR, brightSTR, Ecurve, Ecenter, protect, interp, dither, HQ, useMT, useOPT, debug, screenW, screenH, scale )
}

function SmoothTweak(clip clip, int "brightness", float "contrast", float "saturation", int "hue1", int "hue2", bool "limiter", bool "TVrange", int "Lmode", int "limitSTR", int "Ecenter", int "interp", int "dither", bool "HQ", int "useMT", int "useOPT", bool "debug", int "screenW", int "screenH", bool "scale" )
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/SmoothAdjust.dll") : LoadPlugin(AviSynthPluginsDir + "26/SmoothAdjust.dll")
        SmoothTweak(clip, brightness, contrast, saturation, hue1, hue2, limiter, TVrange, Lmode, limitSTR, Ecenter, interp, dither, HQ, useMT, useOPT, debug, screenW, screenH, scale )
}

function SmoothCurve(clip clip, string "Ycurve", string "Ucurve", string "Vcurve", int "mode", bool "limiter", bool "TVrange", int "interp", int "dither", bool "HQ", int "useMT", int "useOPT", bool "debug", int "screenW", int "screenH", bool "scale" )
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/SmoothAdjust.dll") : LoadPlugin(AviSynthPluginsDir + "26/SmoothAdjust.dll")
        SmoothCurve(clip, Ycurve, Ucurve, Vcurve, mode, limiter, TVrange, interp, dither, HQ, useMT, useOPT, debug, screenW, screenH, scale )
}

function SmoothCustom(clip clip, string "Yexpr", string "Uexpr", string "Vexpr", bool "limiter", bool "TVrange", int "interp", int "dither", bool "HQ", int "useMT", int "useOPT", bool "debug", int "screenW", int "screenH", bool "scale" )
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/SmoothAdjust.dll") : LoadPlugin(AviSynthPluginsDir + "26/SmoothAdjust.dll")
        SmoothCustom(clip, Yexpr, Uexpr, Vexpr, limiter, TVrange, interp, dither, HQ, useMT, useOPT, debug, screenW, screenH, scale )
}

function SmoothTools(clip clip, string "filename", int "interp", int "dither", bool "HQ", int "useMT", int "useOPT", bool "debug", int "screenW", int "screenH", bool "scale" )
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/SmoothAdjust.dll") : LoadPlugin(AviSynthPluginsDir + "26/SmoothAdjust.dll")
        SmoothTools(clip, filename, interp, dither, HQ, useMT, useOPT, debug, screenW, screenH, scale )
}

function SmoothLevels16(clip clip, int "input_low", float "gamma", int "input_high", int "output_low", int "output_high", int "chroma", int "limiter", bool "TVrange", string "preset", int "Lmode", int "darkSTR", int "brightSTR", int "Ecurve", int "Ecenter", int "protect", int "interp", int "dither", bool "HQ", int "useMT", int "useOPT", bool "debug", int "screenW", int "screenH", bool "scale" )
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/SmoothAdjust.dll") : LoadPlugin(AviSynthPluginsDir + "26/SmoothAdjust.dll")
        SmoothLevels16(clip, input_low, gamma, input_high, output_low, output_high, chroma, limiter, TVrange, preset, Lmode, darkSTR, brightSTR, Ecurve, Ecenter, protect, interp, dither, HQ, useMT, useOPT, debug, screenW, screenH, scale )
}

function SmoothTweak16(clip clip, int "brightness", float "contrast", float "saturation", int "hue1", int "hue2", bool "limiter", bool "TVrange", int "Lmode", int "limitSTR", int "Ecenter", int "interp", int "dither", bool "HQ", int "useMT", int "useOPT", bool "debug", int "screenW", int "screenH", bool "scale" )
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/SmoothAdjust.dll") : LoadPlugin(AviSynthPluginsDir + "26/SmoothAdjust.dll")
        SmoothTweak16(clip, brightness, contrast, saturation, hue1, hue2, limiter, TVrange, Lmode, limitSTR, Ecenter, interp, dither, HQ, useMT, useOPT, debug, screenW, screenH, scale )
}

function SmoothCurve16(clip clip, string "Ycurve", string "Ucurve", string "Vcurve", int "mode", bool "limiter", bool "TVrange", int "interp", int "dither", bool "HQ", int "useMT", int "useOPT", bool "debug", int "screenW", int "screenH", bool "scale" )
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/SmoothAdjust.dll") : LoadPlugin(AviSynthPluginsDir + "26/SmoothAdjust.dll")
        SmoothCurve16(clip, Ycurve, Ucurve, Vcurve, mode, limiter, TVrange, interp, dither, HQ, useMT, useOPT, debug, screenW, screenH, scale )
}

function SmoothCustom16(clip clip, string "Yexpr", string "Uexpr", string "Vexpr", bool "limiter", bool "TVrange", int "interp", int "dither", bool "HQ", int "useMT", int "useOPT", bool "debug", int "screenW", int "screenH", bool "scale" )
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/SmoothAdjust.dll") : LoadPlugin(AviSynthPluginsDir + "26/SmoothAdjust.dll")
        SmoothCustom16(clip, Yexpr, Uexpr, Vexpr, limiter, TVrange, interp, dither, HQ, useMT, useOPT, debug, screenW, screenH, scale )
}

function SmoothTools16(clip clip, string "filename", int "interp", int "dither", bool "HQ", int "useMT", int "useOPT", bool "debug", int "screenW", int "screenH", bool "scale" )
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/SmoothAdjust.dll") : LoadPlugin(AviSynthPluginsDir + "26/SmoothAdjust.dll")
        SmoothTools16(clip, filename, interp, dither, HQ, useMT, useOPT, debug, screenW, screenH, scale )
}