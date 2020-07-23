function Cnr2(clip clip, string "mode", float "scdthr", int "ln", int "lm", int "un", int "um", int "vn", int "vm", bool "log", bool "sceneChroma")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPlugins64Dir + "25/Cnr2.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/Cnr2.dll")
        Cnr2(clip, mode, scdthr, ln, lm, un, um, vn, vm, log, sceneChroma)
}