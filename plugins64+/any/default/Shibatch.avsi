function SSRC(clip clip, bool "fast")
{
LoadPlugin(AviSynthPlugins64PDir + "any/default/Shibatch.dll")
        SSRC(clip, fast)
}

function SuperEQ(clip clip, int_array int)
{
LoadPlugin(AviSynthPlugins64PDir + "any/default/Shibatch.dll")
        SuperEQ(clip, int)
}

function SuperEQ(clip clip, string "file")
{
LoadPlugin(AviSynthPlugins64PDir + "any/default/Shibatch.dll")
        SuperEQ(clip, file)
}