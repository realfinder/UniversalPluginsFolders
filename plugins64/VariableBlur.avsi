function VariableBlur(clip clip, int "radY", int "radC", int "Y", int "U", int "V")
{
LoadPlugin(AviSynthPlugins64Dir + "25/VariableBlur.dll")
        AverageBlur(clip, radY, radC, Y, U, V)
}

function BinomialBlur(clip clip, float "varY", float "varC", int "Y", int "U", int "V", bool "useMMX")
{
LoadPlugin(AviSynthPlugins64Dir + "25/VariableBlur.dll")
        BinomialBlur(clip, varY, varC, Y, U, V, useMMX)
}

function GaussianBlur(clip clip, float "varY", float "varC", int "border", bool "integrate", int "Y", int "U", int "V", int "gfunc", int "gfuncc", int "pcr", int "pcrc", int "nthreads")
{
LoadPlugin(AviSynthPlugins64Dir + "25/VariableBlur.dll")
        GaussianBlur(clip, varY, varC, border, integrate, Y, U, V, gfunc, gfuncc, pcr, pcrc, nthreads)
}

function Unsharp(clip clip, float "varY", float "varC", float "strength", int "border", bool "integrate", int "Y", int "U", int "V", int "gfunc", int "gfuncc", int "pcr", int "pcrc", int "nthreads")
{
LoadPlugin(AviSynthPlugins64Dir + "25/VariableBlur.dll")
        Unsharp(clip, varY, varC, strength, border, integrate, Y, U, V, gfunc, gfuncc, pcr, pcrc, nthreads)
}