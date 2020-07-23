function QTInput(string "file", int "color", int "quality", int "audio", int "mode", string "raw", int "info", int "dither", string "vfw", float "gamma", float "vfrFPS")
{
LoadPlugin(AviSynthPluginsDir + "25/QTSource.dll")
        QTInput(file, color, quality, audio, mode, raw, info, dither, vfw, gamma, vfrFPS)
}

function QTOutput(clip clip, string "file", string "format", int "quality", int "datarate", int "keyframe", string "raw", string "settings", int "audio")
{
LoadPlugin(AviSynthPluginsDir + "25/QTSource.dll")
        QTOutput(clip, file, format, quality, datarate, keyframe, raw, settings, audio)
}