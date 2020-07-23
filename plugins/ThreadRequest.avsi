function ThreadRequest(clip clip, int "cache", int "queue", int "warmingup", string "name")
{
LoadPlugin(AviSynthPluginsDir + "25/ThreadRequest.dll")
        ThreadRequest(clip, cache, queue, warmingup, name)
}

function Synchronize(clip clip, int "cache", string "name")
{
LoadPlugin(AviSynthPluginsDir + "25/ThreadRequest.dll")
        Synchronize(clip, cache, name)
}