function TextSubMod(clip clip, string "file", int "charset", float "fps", string "vfr", bool "utf8", bool "accurate")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPlugins64Dir + "25/VSFilterMod.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/VSFilterMod.dll")
        VersionNumber() < 2.60 ? TextSubMod(clip, file, charset, fps, vfr) : TextSubMod(clip, file, charset, fps, vfr, utf8, accurate)
}

function VobSub(clip clip, string file, bool "utf8", bool "accurate")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPlugins64Dir + "25/VSFilterMod.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/VSFilterMod.dll")
        VersionNumber() < 2.60 ? VobSub(clip, file) : VobSub(clip, file, utf8, accurate)
}

function MaskSubMod(string "file", int "width", int "height", float "fps", int "length", int "charset", string "vfr", bool "utf8", bool "accurate")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPlugins64Dir + "25/VSFilterMod.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/VSFilterMod.dll")
        VersionNumber() < 2.60 ? MaskSubMod(file, width, height, fps, length, charset, vfr) : MaskSubMod(file, width, height, fps, length, charset, vfr, utf8, accurate)
}

function TextSubModSwapUV(bool a)
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPlugins64Dir + "25/VSFilterMod.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/VSFilterMod.dll")
        TextSubModSwapUV(a)
}