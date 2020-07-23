function SmoothD(clip clip, int "quant", int "num_shift", int "adaptive_shift", int "zero_weight")
{
LoadPlugin(AviSynthPlugins64Dir + "25/SmoothD.dll")
        SmoothD(clip, quant, num_shift, adaptive_shift, zero_weight)
}