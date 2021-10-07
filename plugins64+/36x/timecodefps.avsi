function timecodefps(clip clip, string "timecodes", int "fpsnum", int "fpsden", bool "report", float "threshone", float "threshmore", bool "start")  {
LoadPlugin(AviSynthPlugins64PDir + "36x/timecodefps.dll")
    timecodefps(clip, timecodes, fpsnum, fpsden, report, threshone, threshmore, start)
}