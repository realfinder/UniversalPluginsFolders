function NicAC3Source(string file, int "channels", int "drc") 
{
LoadPlugin(AviSynthPluginsDir + "25/NicAudio.dll")
        NicAC3Source(file, channels, drc) 
}

function NicDTSSource(string file, int "channels", int "drc") 
{
LoadPlugin(AviSynthPluginsDir + "25/NicAudio.dll")
        NicDTSSource(file, channels, drc) 
}

function NicMPG123Source(string file, bool "normalize")
{
LoadPlugin(AviSynthPluginsDir + "25/NicAudio.dll")
        NicMPG123Source(file, normalize)
}

function NicLPCMSource(string file, int "samplerate", int "samplebits", int "channels")
{
LoadPlugin(AviSynthPluginsDir + "25/NicAudio.dll")
        NicLPCMSource(file, samplerate, samplebits, channels)
}

function RaWavSource(string file, int "samplerate", int "samplebits", int "channels")
{
LoadPlugin(AviSynthPluginsDir + "25/NicAudio.dll")
        RaWavSource(file, samplerate, samplebits, channels)
}