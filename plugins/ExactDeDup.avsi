function ExactDedup(clip clip, bool "firstpass", string "dupinfo", string "times", int "maxdupcount", bool "keeplastframe", bool "show")  {
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/ExactDeDup.dll") : LoadPlugin(AviSynthPluginsDir + "26/ExactDeDup.dll")
    ExactDedup(clip, firstpass, dupinfo, times, maxdupcount, keeplastframe, show)
}