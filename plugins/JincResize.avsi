function JincResize(clip clip, int target_width, int target_height, float "src_left", float "src_top", float "src_width", float "src_height", int "quant_x", int "quant_y", int "tap", float "blur", string "cplace", int "threads", int "opt")
{
LoadPlugin(AviSynthPluginsDir + "26/JincResize.dll")
        JincResize(clip, target_width, target_height, src_left, src_top, src_width, src_height, quant_x, quant_y, tap, blur, cplace, threads, opt)
}

function Jinc36Resize(clip clip, int target_width, int target_height, float "src_left", float "src_top", float "src_width", float "src_height", int "quant_x", int "quant_y", string "cplace", int "threads")
{
LoadPlugin(AviSynthPluginsDir + "26/JincResize.dll")
        Jinc36Resize(clip, target_width, target_height, src_left, src_top, src_width, src_height, quant_x, quant_y, cplace, threads)
}

function Jinc64Resize(clip clip, int target_width, int target_height, float "src_left", float "src_top", float "src_width", float "src_height", int "quant_x", int "quant_y", string "cplace", int "threads")
{
LoadPlugin(AviSynthPluginsDir + "26/JincResize.dll")
        Jinc64Resize(clip, target_width, target_height, src_left, src_top, src_width, src_height, quant_x, quant_y, cplace, threads)
}

function Jinc144Resize(clip clip, int target_width, int target_height, float "src_left", float "src_top", float "src_width", float "src_height", int "quant_x", int "quant_y", string "cplace", int "threads")
{
LoadPlugin(AviSynthPluginsDir + "26/JincResize.dll")
        Jinc144Resize(clip, target_width, target_height, src_left, src_top, src_width, src_height, quant_x, quant_y, cplace, threads)
}

function Jinc256Resize(clip clip, int target_width, int target_height, float "src_left", float "src_top", float "src_width", float "src_height", int "quant_x", int "quant_y", string "cplace", int "threads")
{
LoadPlugin(AviSynthPluginsDir + "26/JincResize.dll")
        Jinc256Resize(clip, target_width, target_height, src_left, src_top, src_width, src_height, quant_x, quant_y, cplace, threads)
}