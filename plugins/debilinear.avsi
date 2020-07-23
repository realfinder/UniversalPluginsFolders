function debilinear(clip clip, int target_width, int target_height, float "src_left", float "src_top", float "src_width", float "src_height", bool "lsb_inout")
{
LoadPlugin(AviSynthPluginsDir + "25/debilinear.dll")
        debicubic(clip, target_width, target_height, src_left, src_top, src_width, src_height, lsb_inout)
}

function debilinearY(clip clip, int target_width, int target_height, float "src_left", float "src_top", float "src_width", float "src_height", bool "lsb_inout")
{
LoadPlugin(AviSynthPluginsDir + "25/debilinear.dll")
        debilinearY(clip, target_width, target_height, src_left, src_top, src_width, src_height, lsb_inout)
}