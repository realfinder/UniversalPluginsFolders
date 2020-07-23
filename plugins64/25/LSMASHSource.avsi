function LWLibavVideoSource(string "source", int "stream_index", int "threads", bool "cache", int "seek_mode", int "seek_threshold", bool "dr", int "fpsnum", int "fpsden", bool "repeat", int "dominance", bool "stacked", string "format")
{
LoadPlugin(AviSynthPlugins64Dir + "25/LSMASHSource.dll")
        LWLibavVideoSource(source, stream_index, threads, cache, seek_mode, seek_threshold, dr, fpsnum, fpsden, repeat, dominance, stacked, format)
}

function LWLibavAudioSource(string "source", int "stream_index", bool "cache", bool "av_sync", string "layout", int "rate")
{
LoadPlugin(AviSynthPlugins64Dir + "25/LSMASHSource.dll")
        LWLibavAudioSource(source, stream_index, cache, av_sync, layout, rate)
}

function LSMASHVideoSource(string "source", int "track", int "threads", int "seek_mode", int "seek_threshold", bool "dr", int "fpsnum", int "fpsden", bool "stacked", string "format")
{
LoadPlugin(AviSynthPlugins64Dir + "25/LSMASHSource.dll")
        LSMASHVideoSource(source, track, threads, seek_mode, seek_threshold, dr, fpsnum, fpsden, stacked, format)
}

function LSMASHAudioSource(string "source", int "track", bool "skip_priming", string "layout", int "rate")
{
LoadPlugin(AviSynthPlugins64Dir + "25/LSMASHSource.dll")
        LSMASHAudioSource(source, track, skip_priming, layout, rate)
}