function Matrix(clip clip, int "from", int "to", float "rg", float "gg", float "bg", float "a", float "b", float "ao", float "bo", int "bitdepth")
{
LoadPlugin(AviSynthPlugins64Dir + "25/HDRMatrix.dll")
        Matrix(clip, from, to, rg, gg, bg, a, b, ao, bo, bitdepth)
}