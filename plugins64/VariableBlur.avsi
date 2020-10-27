function VariableBlur(clip clip, int "radY", int "radC", int "Y", int "U", int "V")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPlugins64Dir + "25/VariableBlur.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/VariableBlur.dll")
        AverageBlur(clip, radY, radC, Y, U, V)
}

function BinomialBlur(clip clip, float "varY", float "varC", int "Y", int "U", int "V", bool "useMMX")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPlugins64Dir + "25/VariableBlur.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/VariableBlur.dll")
        BinomialBlur(clip, varY, varC, Y, U, V, useMMX)
}

function GaussianBlur(clip clip, float "varY", float "varC", int "border", bool "integrate", int "Y", int "U", int "V", int "gfunc", int "gfuncc", int "pcr", int "pcrc", int "nthreads")
{
sisavs25=VersionNumber() < 2.60
sisavs25 ? LoadPlugin(AviSynthPlugins64Dir + "25/VariableBlur.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/VariableBlur.dll")
        sisavs25 ? GaussianBlur(clip, varY, varC, border, integrate, Y, U, V, gfunc, gfuncc, pcr, pcrc) : GaussianBlur(clip, varY, varC, border, integrate, Y, U, V, gfunc, gfuncc, pcr, pcrc, nthreads)
}

function Unsharp(clip clip, float "varY", float "varC", float "strength", int "border", bool "integrate", int "Y", int "U", int "V", int "gfunc", int "gfuncc", int "pcr", int "pcrc", int "nthreads")
{
sisavs25=VersionNumber() < 2.60
sisavs25 ? LoadPlugin(AviSynthPlugins64Dir + "25/VariableBlur.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/VariableBlur.dll")
        sisavs25 ? Unsharp(clip, varY, varC, strength, border, integrate, Y, U, V, gfunc, gfuncc, pcr, pcrc) : Unsharp(clip, varY, varC, strength, border, integrate, Y, U, V, gfunc, gfuncc, pcr, pcrc, nthreads)
}