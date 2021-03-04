function assrender(clip clip, string file, string "vfr", int "hinting", float "scale", float "line_spacing", float "dar", float "sar", int "top", int "bottom", int "left", int "right", string "charset", int "debuglevel", string "fontdir", string "srt_font", string "colorspace")
{
AvsPlusVersionNumber > 2294 ? Load_Stdcall_plugin(AviSynthPluginsDir + "cplugin/plus/assrender.dll") : Load_Stdcall_plugin(AviSynthPluginsDir + "cplugin/assrender.dll")
        assrender(clip, file, vfr, hinting, scale, line_spacing, dar, sar, top, bottom, left, right, charset, debuglevel, fontdir, srt_font, colorspace)
}