function BestAudioSource(string "source", int "track", bool "exactsamples", bool "enable_drefs", bool "use_absolute_path", float "drc_scale", string "varprefix")
{
LoadPlugin(AviSynthPlugins64Dir + "26/BestAudioSource.dll")
        BestAudioSource(source, track, exactsamples, enable_drefs, use_absolute_path, drc_scale, varprefix)
}