function Auto_Gamma(clip clip, float "a", float "b", int "tolerance", int "crush", bool "limitedRange", int "mode", int "linear", bool "sixtyFour")
{
LoadPlugin(AviSynthPlugins64Dir + "cplugin/C_Auto_Gamma_x64.dll")
        Auto_Gamma(clip, a, b, tolerance, crush, limitedRange, mode, linear, sixtyFour)
}