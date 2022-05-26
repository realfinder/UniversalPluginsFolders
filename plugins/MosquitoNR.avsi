function MosquitoNR(clip clip, int "strength", int "restore", int "radius", int "threads")  {
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/MosquitoNR.dll") : LoadPlugin(AviSynthPluginsDir + "26/MosquitoNR.dll")
    MosquitoNR(clip, strength, restore, radius, threads)
}