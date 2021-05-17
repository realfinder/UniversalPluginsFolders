function vsCnr2(clip input, string "mode", float "scdthr", int "ln", int "lm", int "un", int "um", int "vn", int "vm", bool "sceneChroma")
{
LoadPlugin(AviSynthPlugins64Dir + "26/vsCnr2.dll")
        vsCnr2(input, mode, scdthr, ln, lm, un, um, vn, vm, sceneChroma)
}