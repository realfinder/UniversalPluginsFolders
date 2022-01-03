function hqdn3d(clip clip, float "ls", float "cs", float "lt", float "ct", int "restart", int "y", int "u", int "v", bool "mt")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPlugins64Dir + "25/hqdn3d.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/hqdn3d.dll")
        VersionNumber() < 2.60 ? hqdn3d(clip, ls, cs, lt, ct, restart) :  hqdn3d(clip, ls, cs, lt, ct, restart, y, u, v, mt)
}