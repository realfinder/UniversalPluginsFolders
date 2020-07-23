function TextSubMod(clip clip, string "file", int "charset", float "fps", string "vfr")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/VSFilterMod.dll") : LoadPlugin(AviSynthPluginsDir + "26/VSFilterMod.dll")
        TextSubMod(clip, file, charset, fps, vfr)
}

function VobSub(clip clip, string)
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/VSFilterMod.dll") : LoadPlugin(AviSynthPluginsDir + "26/VSFilterMod.dll")
        VobSub(clip, string)
}

function MaskSubMod(string "file", int "width", int "height", float "fps", int "length", int "charset", string "vfr", string "pixel_type")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/VSFilterMod.dll") : LoadPlugin(AviSynthPluginsDir + "26/VSFilterMod.dll")
        MaskSubMod(file, width, height, fps, length, charset, vfr, pixel_type)
}

function TextSubModSwapUV(bool)
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/VSFilterMod.dll") : LoadPlugin(AviSynthPluginsDir + "26/VSFilterMod.dll")
        TextSubModSwapUV(bool)
}