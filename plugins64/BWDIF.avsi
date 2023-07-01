function BWDIF(clip clip, int "field", clip "edeint", int "opt", float "thr", bool "debug", bool "pass")
{
LoadPlugin(AviSynthPlugins64Dir + "26/BWDIF.dll")
        BWDIF(clip, field, edeint, opt,  thr, debug, pass)
}