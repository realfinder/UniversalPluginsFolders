function UnsharpMask16Y(clip clip, clip mask, float "edges", float "g", float "wg", float "bl", float "str", int "mode", int "bitdepth")
{
LoadPlugin(AviSynthPluginsDir + "25/HDRSharp.dll")
        UnsharpMask16Y(clip, mask, edges, g, wg, bl, str, mode, bitdepth)
}

function UnsharpMask8Y(clip clip, clip mask, float "edges", float "g", float "wg", float "bl", float "str", int "mode", int "bitdepth")
{
LoadPlugin(AviSynthPluginsDir + "25/HDRSharp.dll")
        UnsharpMask8Y(clip, mask, edges, g, wg, bl, str, mode, bitdepth)
}