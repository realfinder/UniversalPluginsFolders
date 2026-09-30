function RestoreFPS (clip clip, float fps, float phase)
{
LoadPlugin(AviSynthPlugins64Dir + "26/RestoreFPS.dll")
        RestoreFPS (clip, fps, phase)
}


function RestoreFPSIVTC (clip clip, float fps, float phase, int telecine)
{
LoadPlugin(AviSynthPlugins64Dir + "26/RestoreFPS.dll")
        RestoreFPSIVTC (clip, fps, phase, telecine)
}


function ThresholdIncreaseFPS (clip clip, float fps, float threshold)
{
LoadPlugin(AviSynthPlugins64Dir + "26/RestoreFPS.dll")
        ThresholdIncreaseFPS (clip, fps, threshold)
}


function Reblend (clip clip, float weight)
{
LoadPlugin(AviSynthPlugins64Dir + "26/RestoreFPS.dll")
        Reblend (clip, weight)
}


function TelecineConvertFPS (clip clip, float fps)
{
LoadPlugin(AviSynthPlugins64Dir + "26/RestoreFPS.dll")
        TelecineConvertFPS (clip, fps)
}