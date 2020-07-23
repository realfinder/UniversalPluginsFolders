function vinverse(clip clip, float "sstr", int "amnt", int "uv", float "scl")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/vinverse.dll") : LoadPlugin(AviSynthPluginsDir + "26/vinverse2.dll")
        vinverse(clip, sstr, amnt, uv, scl)
}

function vinverse2(clip clip, float "sstr", int "amnt", int "uv", float "scl")
{
LoadPlugin(AviSynthPluginsDir + "25/vinverse.dll")
        vinverse2(clip, sstr, amnt, uv, scl)
}