function D2VSource(string "d2v", int "idct", bool "showQ", int "info", int "upConv", bool "i420", bool "iCC", bool "nocrop", int "rff")
{
LoadPlugin(AviSynthPlugins64Dir + "26/D2VSource.dll")
        D2VSource(d2v, idct, showQ, info, upConv, i420, iCC, nocrop, rff)
}