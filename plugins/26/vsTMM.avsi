function vsTMM(clip clip, int "mode", int "order", int "field", int "length", int "mtype", int "ttype", int "mtqL", int "mthL", int "mtqC", int "mthC", int "nt", int "minthresh", int "maxthresh", int "cstr", int "athresh", int "metric", int "expand", bool "binary", bool "link", bool "eight", int "y", int "u", int "v", int "opt")
{
LoadPlugin(AviSynthPluginsDir + "26/vsTMM.dll")
        vsTMM(clip, mode, order, field, length, mtype, ttype, mtqL, mthL, mtqC, mthC, nt, minthresh, maxthresh, cstr, athresh, metric, expand, binary, link, eight, y, u, v, opt)
}