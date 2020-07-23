function DctFilter(clip clip, float a1, float a2, float a3, float a4, float a5, float a6, float a7, float a8, int "chroma", int "fdct", int "idct", int "offx", int "offy")
{
LoadPlugin(AviSynthPluginsDir + "25/DctFilter.dll")
        DctFilter(clip, a1, a2, a3, a4, a5, a6, a7, a8, chroma, fdct, idct, offx, offy)
}

function DctFilterD(clip clip, int diagonals_count)
{
LoadPlugin(AviSynthPluginsDir + "25/DctFilter.dll")
        DctFilterD(clip, diagonals_count)
}

function DctAddConstant(clip clip, float a1, float a2, float a3, float a4)
{
LoadPlugin(AviSynthPluginsDir + "25/DctFilter.dll")
        DctAddConstant(clip, a1, a2, a3, a4)
}