function Bitdepth(clip clip, int "from", int "to")
{
LoadPlugin(AviSynthPlugins64Dir + "25/HDRCore.dll")
        Bitdepth(clip, from, to)
}

function BitdepthLsb(clip clip, int "bitdepth")
{
LoadPlugin(AviSynthPlugins64Dir + "25/HDRCore.dll")
        BitdepthLsb(clip, bitdepth)
}

function BitdepthMsb(clip clip, int "bitdepth")
{
LoadPlugin(AviSynthPlugins64Dir + "25/HDRCore.dll")
        BitdepthMsb(clip, bitdepth)
}

function BitdepthMsbLsb(clip clip, clip "lsb", int "bitdepth")
{
LoadPlugin(AviSynthPlugins64Dir + "25/HDRCore.dll")
        BitdepthMsbLsb(clip, lsb, bitdepth)
}

function ClampHDR(clip clip, float "ay", float "by", float "au", float "bu", float "av", float "bv", int "bitdepth")
{
LoadPlugin(AviSynthPlugins64Dir + "25/HDRCore.dll")
        ClampHDR(clip, ay, by, au, bu, av, bv, bitdepth)
}

function RangeUV(clip clip, float "au", float "bu", float "aou", float "bou", float "av", float "bv", float "aov", float "bov", int "mode", int "bitdepth")
{
LoadPlugin(AviSynthPlugins64Dir + "25/HDRCore.dll")
        RangeUV(clip, au, bu, aou, bou, av, bv, aov, bov, mode, bitdepth)
}

function RangeY(clip clip, float "a", float "b", float "ao", float "bo", float "g", int "mode", int "bitdepth")
{
LoadPlugin(AviSynthPlugins64Dir + "25/HDRCore.dll")
        RangeY(clip, a, b, ao, bo, g, mode, bitdepth)
}