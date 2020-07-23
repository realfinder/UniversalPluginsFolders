function TextSubMod(clip clip, string "file", int "charset", float "fps", string "vfr")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPlugins64Dir + "25/VSFilterMod.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/VSFilterMod.dll")
        TextSubMod(clip, file, charset, fps, vfr)
}

function VobSub(clip clip, string file)
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPlugins64Dir + "25/VSFilterMod.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/VSFilterMod.dll")
        VobSub(clip, file)
}

function MaskSubMod(string "file", int "width", int "height", float "fps", int "length", int "charset", string "vfr", string "pixel_type")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPlugins64Dir + "25/VSFilterMod.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/VSFilterMod.dll")
        MaskSubMod(file, width, height, fps, length, charset, vfr, pixel_type)
}

function TextSubModSwapUV(bool a)
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPlugins64Dir + "25/VSFilterMod.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/VSFilterMod.dll")
        TextSubModSwapUV(a)
}