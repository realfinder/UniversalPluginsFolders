function MT(clip clip, string "filter", int "threads", int "overlap", bool "splitvertical")
{
LoadPlugin(AviSynthPlugins64Dir + "25/MT.dll")
        MT(clip, filter, threads, overlap, splitvertical)
}


function MTi(clip clip, string "filter")
{
LoadPlugin(AviSynthPlugins64Dir + "25/MT.dll")
        MTi(clip, filter)
}

function MTsource(string "filter", int "delta", int "threads", int "max_fetch")
{
LoadPlugin(AviSynthPlugins64Dir + "25/MT.dll")
        MTsource(filter, delta, threads, max_fetch)
}