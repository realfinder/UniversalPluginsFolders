function MP_Pipeline(string s, bool "always_kill_children", bool "force25mpp") {
force25mpp = default(force25mpp, false)
force25mpp || VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/MP_Pipeline.dll") : LoadPlugin(AviSynthPluginsDir + "26/MP_Pipeline.dll")
MP_Pipeline(s, always_kill_children)
}