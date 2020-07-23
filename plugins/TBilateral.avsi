function TBilateral(clip clip, int "diameterL", int "diameterC", float "sDevL", float "sDevC", float "iDevL", float "iDevC", float "csL", float "csC", bool "d2", bool "chroma", bool "gui", clip "ppClip", int "kernS", int "kernI", int "resType")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/TBilateral.dll") : LoadPlugin(AviSynthPluginsDir + "26/TBilateral.dll")
        TBilateral(clip, diameterL, diameterC, sDevL, sDevC, iDevL, iDevC, csL, csC, d2, chroma, gui, ppClip, kernS, kernI, resType)
}