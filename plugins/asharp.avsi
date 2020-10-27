function asharp(clip clip, float "T", float "D", float "B", bool "hqbf") 
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/asharp.dll") : LoadPlugin(AviSynthPluginsDir + "26/asharp.dll")
    asharp(clip, T, D, B, hqbf) 
}