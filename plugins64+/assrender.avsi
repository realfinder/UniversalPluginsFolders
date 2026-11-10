function assrender(clip clip, string file, string "vfr", int "hinting", float "scale", float "line_spacing", int "frame_width", int "frame_height", float "dar", float "sar", bool "set_default_storage_size", int "top", int "bottom", int "left", int "right", string "charset", int "debuglevel", string "fontdir", string "srt_font", string "colorspace")
{
Load_Stdcall_plugin(AviSynthPlugins64PDir + "mt/assrender.dll")
        assrender(clip, file, vfr, hinting, scale, line_spacing, frame_width, frame_height, dar, sar, set_default_storage_size, top, bottom, left, right, charset, debuglevel, fontdir, srt_font, colorspace)
}