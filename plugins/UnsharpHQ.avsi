function UnsharpHQ(clip clip, int "THRESHOLD",float "SHARPSTR",float "SMOOTH",bool "SHOW")  {
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/UnsharpHQ.dll") : LoadPlugin(AviSynthPluginsDir + "26/unsharpHQmod.dll")
    UnsharpHQ(clip, THRESHOLD,SHARPSTR,SMOOTH,SHOW)
}