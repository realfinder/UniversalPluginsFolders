function TextSub(clip clip, string "file", int "charset", float "fps", string "vfr")
{
AvsPlusVersionNumber < 3276 ? VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/VSFilter.dll") : LoadPlugin(AviSynthPluginsDir + "26/VSFilter.dll") : LoadPlugin(AviSynthPluginsDir + "avsplus/VSFilter.dll")
        TextSub(clip, file, charset, fps, vfr)
}

function VobSub(clip clip, string file)
{
AvsPlusVersionNumber < 3276 ? VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/VSFilter.dll") : LoadPlugin(AviSynthPluginsDir + "26/VSFilter.dll") : LoadPlugin(AviSynthPluginsDir + "avsplus/VSFilter.dll")
        VobSub(clip, file)
}

function MaskSub(string "file", int "width", int "height", float "fps", int "length", int "charset", string "vfr", string "pixel_type")
{
AvsPlusVersionNumber < 3276 ? VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/VSFilter.dll") : LoadPlugin(AviSynthPluginsDir + "26/VSFilter.dll") : LoadPlugin(AviSynthPluginsDir + "avsplus/VSFilter.dll")
        MaskSub(file, width, height, fps, length, charset, vfr, pixel_type)
}

function TextSubSwapUV(bool a)
{
AvsPlusVersionNumber < 3276 ? VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/VSFilter.dll") : LoadPlugin(AviSynthPluginsDir + "26/VSFilter.dll") : LoadPlugin(AviSynthPluginsDir + "avsplus/VSFilter.dll")
        TextSubSwapUV(a)
}