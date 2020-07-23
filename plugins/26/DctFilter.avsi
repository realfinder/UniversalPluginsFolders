function DCTFilter(clip clip, float a1, float a2, float a3, float a4, float a5, float a6, float a7, float a8, float "x40", float "x41", float "x42", float "x43", int "chroma", int "opt")
{
LoadPlugin(AviSynthPluginsDir + "26/DCTFilter.dll")
        DCTFilter(clip, a1, a2, a3, a4, a5, a6, a7, a8, x40, x41, x42, x43, chroma, opt)
}

function DCTFilter8(clip clip, float a1, float a2, float a3, float a4, float a5, float a6, float a7, float a8, float "x40", float "x41", float "x42", float "x43", int "chroma", int "opt")
{
LoadPlugin(AviSynthPluginsDir + "26/DCTFilter.dll")
        DCTFilter8(clip, a1, a2, a3, a4, a5, a6, a7, a8, x40, x41, x42, x43, chroma, opt)
}

function DCTFilterD(clip clip, int diagonals_count, int "x4", int "chroma", int "opt")
{
LoadPlugin(AviSynthPluginsDir + "26/DCTFilter.dll")
        DCTFilterD(clip, diagonals_count, x4, chroma, opt)
}

function DCTFilter8D(clip clip, int diagonals_count, int "x4", int "chroma", int "opt")
{
LoadPlugin(AviSynthPluginsDir + "26/DCTFilter.dll")
        DCTFilter8D(clip, diagonals_count, x4, chroma, opt)
}

function DCTFilter4(clip clip, float a1, float a2, float a3, float a4, int "chroma", int "opt")
{
LoadPlugin(AviSynthPluginsDir + "26/DCTFilter.dll")
        DCTFilter4(clip, a1, a2, a3, a4, chroma, opt)
}

function DCTFilter4D(clip clip, int diagonals_count, int "chroma", int "opt")
{
LoadPlugin(AviSynthPluginsDir + "26/DCTFilter.dll")
        DCTFilter4D(clip, diagonals_count, chroma, opt)
}