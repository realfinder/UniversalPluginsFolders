function ExactDedup(clip clip, bool "firstpass", string "dupinfo", string "times", int "maxdupcount", bool "keeplastframe", bool "show")  {
LoadPlugin(AviSynthPlugins64Dir + "26/ExactDeDup.dll")
    ExactDedup(clip, firstpass, dupinfo, times, maxdupcount, keeplastframe, show)
}