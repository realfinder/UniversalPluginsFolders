function SmoothD2(clip clip, clip "ZWmask", int "quant", int "num_shift", int "Matrix", int "Qtype", int "ZW", int "ZWce", int "ZWlmDark", int "ZWlmBright", int "ncpu")
{
LoadPlugin(AviSynthPlugins64Dir + "25/SmoothD2.dll")
        SmoothD2(clip, ZWmask, quant, num_shift, Matrix, Qtype, ZW, ZWce, ZWlmDark, ZWlmBright, ncpu)
}