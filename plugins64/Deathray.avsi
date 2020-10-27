function deathray(clip clip, float "hY", float "hUV", int "tY", int "tUV", float "s", int "x", bool "l", bool "c", bool "z", bool "b")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPlugins64Dir + "25/deathray.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/deathray.dll")
        deathray(clip, hY, hUV, tY, tUV, s, x, l, c, z, b)
}