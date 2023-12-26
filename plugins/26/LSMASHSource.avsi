function LWLibavVideoSource(string "source", int "stream_index", int "threads", bool "cache", string "cachefile", int "seek_mode", int "seek_threshold", bool "dr", int "fpsnum", int "fpsden", bool "repeat", int "dominance", string "format", string "decoder", int "prefer_hw", int "ff_loglevel", string "cachedir", string "ff_options", bool "indexingpr")
{
LoadPlugin(AviSynthPluginsDir + "26/LSMASHSource.dll")
        LWLibavVideoSource(source, stream_index, threads, cache, cachefile, seek_mode, seek_threshold, dr, fpsnum, fpsden, repeat, dominance, format, decoder, prefer_hw, ff_loglevel, cachedir, ff_options, indexingpr)
}

function LWLibavAudioSource(string "source", int "stream_index", bool "cache", bool "av_sync", string "layout", int "rate", string "decoder", string "cachedir", float "drc_scale", string "ff_options", bool "indexingpr")
{
LoadPlugin(AviSynthPluginsDir + "26/LSMASHSource.dll")
        LWLibavAudioSource(source, stream_index, cache, av_sync, layout, rate, decoder, cachedir, drc_scale, ff_options, indexingpr)
}

function LSMASHVideoSource(string "source", int "track", int "threads", int "seek_mode", int "seek_threshold", bool "dr", int "fpsnum", int "fpsden", string "format", string "decoder", int "prefer_hw", int "ff_loglevel", string "ff_options")
{
LoadPlugin(AviSynthPluginsDir + "26/LSMASHSource.dll")
        LSMASHVideoSource(source, track, threads, seek_mode, seek_threshold, dr, fpsnum, fpsden, format, decoder, prefer_hw, ff_loglevel, ff_options)
}

function LSMASHAudioSource(string "source", int "track", bool "skip_priming", string "layout", int "rate", string "decoder", float "drc_scale", string "ff_options")
{
LoadPlugin(AviSynthPluginsDir + "26/LSMASHSource.dll")
        LSMASHAudioSource(source, track, skip_priming, layout, rate, decoder, drc_scale, ff_options)
}