Function libplacebo_Deband(clip input, int "iterations", float "threshold", float "radius", float "grainY", float "grainC", int "dither", int "lut_size", bool "temporal", int_array "planes", int "device", bool "list_device", float_array "grain_neutral")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/avs_libplacebo.dll")
        libplacebo_Deband(input, iterations, threshold, radius, grainY, grainC, dither, lut_size, temporal, planes=planes, device=device, list_device=list_device, grain_neutral=grain_neutral)
}

Function libplacebo_Resample(clip input, int width, int height, string "filter", float "radius", float "clamp", float "taper", float "blur", float "param1", float "param2", float "sx", float "sy", float "antiring", float "lut_entries", float "cutoff", bool "sigmoidize", bool "linearize", float "sigmoid_center", float "sigmoid_slope", int "trc", int "cplace", int "device", bool "list_device", float "src_width", float "src_height")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/avs_libplacebo.dll")
        libplacebo_Resample(input, width, height, filter, radius, clamp, taper, blur, param1, param2, sx, sy, antiring, lut_entries, cutoff, sigmoidize, linearize, sigmoid_center, sigmoid_slope, trc, cplace, device, list_device, src_width, src_height)
}

Function libplacebo_Shader(clip input, string shader, int "width", int "height", int "chroma_loc", int "matrix", int "trc",  string "filter", float "radius", float "clamp", float "taper", float "blur", float "param1", float "param2", float "antiring", float "lut_entries", float "cutoff", bool "sigmoidize", bool "linearize", float "sigmoid_center", float "sigmoid_slope", string "shader_param", int "device", bool "list_device")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/avs_libplacebo.dll")
        libplacebo_Shader(input, shader, width, height, chroma_loc, matrix, trc, filter, radius, clamp, taper, blur, param1, param2, antiring, lut_entries, cutoff, sigmoidize, linearize, sigmoid_center, sigmoid_slope, shader_param, device, list_device)
}

Function libplacebo_Tonemap(clip input, int "src_csp", float "dst_csp", float "src_max", float "src_min", float "dst_max", float "dst_min", bool "dynamic_peak_detection", float "smoothing_period", float "scene_threshold_low", float "scene_threshold_high", float "percentile", string "gamut_mapping_mode", string "tone_mapping_function", string_array "tone_constants", int "metadata", float "contrast_recovery", float "contrast_smoothness", bool "visualize_lut", bool "show_clipping", bool "use_dovi", int "device", bool "list_device", string "cscale", string "lut", int "lut_type", int "dst_prim", int "dst_trc", int "dst_sys")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/avs_libplacebo.dll")
        libplacebo_Tonemap(input, src_csp, dst_csp, src_max, src_min, dst_max, dst_min, dynamic_peak_detection, smoothing_period, scene_threshold_low, scene_threshold_high, percentile, gamut_mapping_mode, tone_mapping_function, tone_constants=tone_constants, metadata=metadata, contrast_recovery=contrast_recovery, contrast_smoothness=contrast_smoothness, visualize_lut=visualize_lut, show_clipping=show_clipping, use_dovi=use_dovi, device=device, list_device=list_device, cscale=cscale, lut=lut, lut_type=lut_type, dst_prim=dst_prim, dst_trc=dst_trc, dst_sys=dst_sys)
}