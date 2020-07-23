function Spline144Resize(clip clip, int target_width, int target_height, float "src_left", float "src_top", float "src_width", float "src_height")
{
LoadPlugin(AviSynthPluginsDir + "25/SplineResize.dll")
        Spline144Resize(clip, target_width, target_height, src_left, src_top, src_width, src_height)
}

function Spline100Resize(clip clip, int target_width, int target_height, float "src_left", float "src_top", float "src_width", float "src_height")
{
LoadPlugin(AviSynthPluginsDir + "25/SplineResize.dll")
        Spline100Resize(clip, target_width, target_height, src_left, src_top, src_width, src_height)
}


function SplineResize(clip clip, int target_width, int target_height, float "src_left", float "src_top", float "src_width", float "src_height", int "taps")
{
LoadPlugin(AviSynthPluginsDir + "25/SplineResize.dll")
        SplineResize(clip, target_width, target_height, src_left, src_top, src_width, src_height, taps)
}