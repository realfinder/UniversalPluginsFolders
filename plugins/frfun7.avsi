function frfun7(clip clip, float "lambda", float "T", float "Tuv", int "P", int "TP1", int "R1")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/frfun7.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/frfun7.dll")
        VersionNumber() < 2.60 ? frfun7(clip, lambda, T, Tuv, P) : frfun7(clip, lambda, T, Tuv, P, TP1, R1)
}