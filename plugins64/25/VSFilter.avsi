function TextSub(clip clip, string "file", int "charset", float "fps", string "vfr")
{
LoadPlugin(AviSynthPlugins64Dir + "25/VSFilter.dll")
        TextSub(clip, file, charset, fps, vfr)
}

function VobSub(clip clip, string file)
{
LoadPlugin(AviSynthPlugins64Dir + "25/VSFilter.dll")
        VobSub(clip, file)
}

function MaskSub(string "file", int "width", int "height", float "fps", int "length", int "charset", string "vfr", string "pixel_type")
{
LoadPlugin(AviSynthPlugins64Dir + "25/VSFilter.dll")
        MaskSub(file, width, height, fps, length, charset, vfr, pixel_type)
}

function TextSubSwapUV(bool a)
{
LoadPlugin(AviSynthPlugins64Dir + "25/VSFilter.dll")
        TextSubSwapUV(a)
}