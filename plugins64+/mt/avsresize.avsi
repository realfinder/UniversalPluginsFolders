function z_ConvertFormat(clip clip, int "width", int "height", string "pixel_type", string "colorspace_op", string "chromaloc_op", bool "interlaced", float "src_left", float "src_top", float "src_width", float "src_height", string "resample_filter", float "filter_param_a", float "filter_param_b", string "resample_filter_uv", float "filter_param_a_uv", float "filter_param_b_uv", string "dither_type", string "cpu_type", float "nominal_luminance", bool "approximate_gamma", int "use_props", bool "scene_referred", int "bit_depth", string "chroma_subsampling")
{
LoadPlugin(AviSynthPlugins64PDir + "mt/avsresize.dll")
        z_ConvertFormat(clip, width, height, pixel_type, colorspace_op, chromaloc_op, interlaced, src_left, src_top, src_width, src_height, resample_filter, filter_param_a, filter_param_b, resample_filter_uv, filter_param_a_uv, filter_param_b_uv, dither_type, cpu_type, nominal_luminance, approximate_gamma, use_props, scene_referred, bit_depth, chroma_subsampling)
}

function z_PointResize(clip clip, int target_width, int target_height, float "src_left", float "src_top", float "src_width", float "src_height", string "chromaloc_op", string "dither", bool "interlaced")
{
LoadPlugin(AviSynthPlugins64PDir + "mt/avsresize.dll")
        z_PointResize(clip, target_width, target_height, src_left, src_top, src_width, src_height, chromaloc_op, dither, interlaced)
}

function z_BilinearResize(clip clip, int target_width, int target_height, float "src_left", float "src_top", float "src_width", float "src_height", string "chromaloc_op", string "dither", bool "interlaced")
{
LoadPlugin(AviSynthPlugins64PDir + "mt/avsresize.dll")
        z_BilinearResize(clip, target_width, target_height, src_left, src_top, src_width, src_height, chromaloc_op, dither, interlaced)
}

function z_BicubicResize(clip clip, int target_width, int target_height, float "b", float "c", float "src_left", float "src_top", float "src_width", float "src_height", string "chromaloc_op", string "dither", bool "interlaced")
{
LoadPlugin(AviSynthPlugins64PDir + "mt/avsresize.dll")
        z_BicubicResize(clip, target_width, target_height, b, c, src_left, src_top, src_width, src_height, chromaloc_op, dither, interlaced)
}

function z_LanczosResize(clip clip, int target_width, int target_height, float "src_left", float "src_top", float "src_width", float "src_height", int "taps", string "chromaloc_op", string "dither", bool "interlaced")
{
LoadPlugin(AviSynthPlugins64PDir + "mt/avsresize.dll")
        z_LanczosResize(clip, target_width, target_height, src_left, src_top, src_width, src_height, taps, chromaloc_op, dither, interlaced)
}

function z_Lanczos4Resize(clip clip, int target_width, int target_height, float "src_left", float "src_top", float "src_width", float "src_height", string "chromaloc_op", string "dither", bool "interlaced")
{
LoadPlugin(AviSynthPlugins64PDir + "mt/avsresize.dll")
        z_Lanczos4Resize(clip, target_width, target_height, src_left, src_top, src_width, src_height, chromaloc_op, dither, interlaced)
}

function z_Spline16Resize(clip clip, int target_width, int target_height, float "src_left", float "src_top", float "src_width", float "src_height", string "chromaloc_op", string "dither", bool "interlaced")
{
LoadPlugin(AviSynthPlugins64PDir + "mt/avsresize.dll")
        z_Spline16Resize(clip, target_width, target_height, src_left, src_top, src_width, src_height, chromaloc_op, dither, interlaced)
}

function z_Spline36Resize(clip clip, int target_width, int target_height, float "src_left", float "src_top", float "src_width", float "src_height", string "chromaloc_op", string "dither", bool "interlaced")
{
LoadPlugin(AviSynthPlugins64PDir + "mt/avsresize.dll")
        z_Spline36Resize(clip, target_width, target_height, src_left, src_top, src_width, src_height, chromaloc_op, dither, interlaced)
}

function z_Spline64Resize(clip clip, int target_width, int target_height, float "src_left", float "src_top", float "src_width", float "src_height", string "chromaloc_op", string "dither", bool "interlaced")
{
LoadPlugin(AviSynthPlugins64PDir + "mt/avsresize.dll")
        z_Spline64Resize(clip, target_width, target_height, src_left, src_top, src_width, src_height, chromaloc_op, dither, interlaced)
}