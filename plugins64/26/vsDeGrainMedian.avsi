function vsDeGrainMedian(clip input, int "limitY", int "limitU", int "limitV", int "modeY", int "modeU", int "modeV", bool "interlaced", bool "norow", int "opt")
{
LoadPlugin(AviSynthPlugins64Dir + "26/vsDeGrainMedian.dll")
        vsDeGrainMedian(input, limitY, limitU, limitV, modeY, modeU, modeV, interlaced, norow, opt)
}