function RestoreFPS (clip clip, float fps, float phase)
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/RestoreFPS.dll") : LoadPlugin(AviSynthPluginsDir + "26/RestoreFPS.dll")
        RestoreFPS (clip, fps, phase)
}


function RestoreFPSIVTC (clip clip, float fps, float phase, int telecine)
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/RestoreFPS.dll") : LoadPlugin(AviSynthPluginsDir + "26/RestoreFPS.dll")
        RestoreFPSIVTC (clip, fps, phase, telecine)
}


function ThresholdIncreaseFPS (clip clip, float fps, float threshold)
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/RestoreFPS.dll") : LoadPlugin(AviSynthPluginsDir + "26/RestoreFPS.dll")
        ThresholdIncreaseFPS (clip, fps, threshold)
}


function Reblend (clip clip, float weight)
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/RestoreFPS.dll") : LoadPlugin(AviSynthPluginsDir + "26/RestoreFPS.dll")
        Reblend (clip, weight)
}


function TelecineConvertFPS (clip clip, float fps)
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/RestoreFPS.dll") : LoadPlugin(AviSynthPluginsDir + "26/RestoreFPS.dll")
        TelecineConvertFPS (clip, fps)
}