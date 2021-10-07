function timecodefps(clip clip, string "timecodes", int "fpsnum", int "fpsden", bool "report", float "threshone", float "threshmore", bool "start")  {
Load_Stdcall_plugin(AviSynthPlugins64Dir + "cplugin/timecodefps.dll")
    timecodefps(clip, timecodes, fpsnum, fpsden, report, threshone, threshmore, start)
}