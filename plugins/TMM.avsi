function TMM(clip clip, int "mode", int "order", int "field", int "length", int "mtype", int "ttype", int "mtqL", int "mthL", int "mtqC", int "mthC", int "nt", int "minthresh", int "maxthresh", int "cstr")
{
LoadPlugin(AviSynthPluginsDir + "25/TMM.dll")
        TMM(clip, mode, order, field, length, mtype, ttype, mtqL, mthL, mtqC, mthC, nt, minthresh, maxthresh, cstr)
}