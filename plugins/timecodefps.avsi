function timecodefps(clip clip, string "timecodes", int "fpsnum", int "fpsden", bool "report", float "threshone", float "threshmore", bool "start")  {
AvsPlusVersionNumber < 3382 ? Load_Stdcall_plugin(AviSynthPluginsDir + "cplugin/timecodefps.dll") : LoadPlugin(AviSynthPluginsDir + "avsplus/timecodefps.dll")
    timecodefps(clip, timecodes, fpsnum, fpsden, report, threshone, threshmore, start)
}