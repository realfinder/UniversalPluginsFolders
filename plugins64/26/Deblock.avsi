function Deblock(clip clip, int "quant", int "aOffset", int "bOffset")
{
LoadPlugin(AviSynthPlugins64Dir + "26/Deblock.dll")
        Deblock(clip, quant, aOffset, bOffset)
}