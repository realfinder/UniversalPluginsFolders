function DeGrainMedian(clip clip, int "limitY", int "limitUV", int "mode", bool "interlaced", bool "norow" )
{
LoadPlugin(AviSynthPluginsDir + "25/DeGrainMedian.dll")
        DeGrainMedian(clip, limitY, limitUV, mode, interlaced, norow)
}