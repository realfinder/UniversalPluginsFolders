function AddGrainC(clip clip, float "var", float "uvar", float "hcorr", float "vcorr", int "seed", bool "constant", bool "sse2")  {
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPlugins64Dir + "25/AddGrainC.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/AddGrainC.dll")
    AddGrainC(clip, var, uvar, hcorr, vcorr, seed, constant, sse2) 
}

function AddGrain(clip clip, float "var", float "hcorr", float "vcorr", float "uvar", int "seed", bool "constant", bool "sse2")   {
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPlugins64Dir + "25/AddGrainC.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/AddGrainC.dll")
    AddGrain(clip, var, hcorr, vcorr, uvar, seed, constant, sse2) 
}