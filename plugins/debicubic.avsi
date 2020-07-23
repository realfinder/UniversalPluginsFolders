function debicubic(clip clip, int target_width, int target_height, float "src_left", float "src_top", float "src_width", float "src_height", bool "lsb_inout", float "b", float "c")
{
LoadPlugin(AviSynthPluginsDir + "25/debicubic.dll")
        debicubic(clip, target_width, target_height, src_left, src_top, src_width, src_height, lsb_inout, b, c)
}

function debicubicY(clip clip, int target_width, int target_height, float "src_left", float "src_top", float "src_width", float "src_height", bool "lsb_inout", float "b", float "c")
{
LoadPlugin(AviSynthPluginsDir + "25/debicubic.dll")
        debicubicY(clip, target_width, target_height, src_left, src_top, src_width, src_height, lsb_inout, b, c)
}