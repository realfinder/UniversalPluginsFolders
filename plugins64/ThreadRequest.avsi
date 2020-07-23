function ThreadRequest(clip clip, int "cache", int "queue", int "warmingup", string "name")
{
LoadPlugin(AviSynthPlugins64Dir + "25/ThreadRequest.dll")
        ThreadRequest(clip, cache, queue, warmingup, name)
}

function Synchronize(clip clip, int "cache", string "name")
{
LoadPlugin(AviSynthPlugins64Dir + "25/ThreadRequest.dll")
        Synchronize(clip, cache, name)
}