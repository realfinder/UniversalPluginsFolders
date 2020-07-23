function ColorMatrix(clip clip, string "mode", int "source", int "dest", int "clamp", bool "interlaced", bool "inputFR", bool "outputFR", bool "hints", string "d2v", bool "debug", int "threads", int "thrdmthd", int "opt")
{
LoadPlugin(AviSynthPlugins64Dir + "25/ColorMatrix.dll")
        ColorMatrix(clip, mode, source, dest, clamp, interlaced, inputFR, outputFR, hints, d2v, debug, threads, thrdmthd, opt)
}