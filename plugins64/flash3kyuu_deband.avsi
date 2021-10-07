function f3kdb(clip clip, int "range", int "Y", int "Cb", int "Cr", int "grainY", int "grainC", int "sample_mode", int "seed", bool "blur_first", bool "dynamic_grain", int "opt", bool "mt", int "dither_algo", bool "keep_tv_range", int "input_mode",int "input_depth", int "output_mode", int "output_depth", int "random_algo_ref", int "random_algo_grain", float "random_param_ref", float "random_param_grain", string "preset")
{
sisavs25 = VersionNumber() < 2.60
sisavs25 ? LoadPlugin(AviSynthPlugins64Dir + "25/flash3kyuu_deband.dll") : LoadPlugin(AviSynthPlugins64Dir + "25/flash3kyuu_deband2015.dll")
        sisavs25 ? f3kdb(clip, range, Y, Cb, Cr, grainY, grainC, sample_mode, seed, blur_first, dynamic_grain, opt, mt, dither_algo, keep_tv_range, input_mode, input_depth, output_mode, output_depth, random_algo_ref, random_algo_grain, random_param_ref, random_param_grain) : f3kdb(clip, range, Y, Cb, Cr, grainY, grainC, sample_mode, seed, blur_first, dynamic_grain, opt, mt, dither_algo, keep_tv_range, input_mode, input_depth, output_mode, output_depth, random_algo_ref, random_algo_grain, random_param_ref, random_param_grain, preset)
}

function flash3kyuu_deband(clip clip, int "range", int "Y", int "Cb", int "Cr", int "grainY", int "grainC", int "sample_mode", int "seed", bool "blur_first", bool "dynamic_grain", int "opt", bool "mt", int "dither_algo", bool "keep_tv_range", int "input_mode",int "input_depth", int "output_mode", int "output_depth", int "random_algo_ref", int "random_algo_grain", float "random_param_ref", float "random_param_grain", string "preset")
{
sisavs25 = VersionNumber() < 2.60
sisavs25 ? LoadPlugin(AviSynthPlugins64Dir + "25/flash3kyuu_deband.dll") : LoadPlugin(AviSynthPlugins64Dir + "25/flash3kyuu_deband2015.dll")
        sisavs25 ? flash3kyuu_deband(clip, range, Y, Cb, Cr, grainY, grainC, sample_mode, seed, blur_first, dynamic_grain, opt, mt, dither_algo, keep_tv_range, input_mode, input_depth, output_mode, output_depth, random_algo_ref, random_algo_grain, random_param_ref, random_param_grain) : flash3kyuu_deband(clip, range, Y, Cb, Cr, grainY, grainC, sample_mode, seed, blur_first, dynamic_grain, opt, mt, dither_algo, keep_tv_range, input_mode, input_depth, output_mode, output_depth, random_algo_ref, random_algo_grain, random_param_ref, random_param_grain, preset)
}

function f3kdb_dither(clip clip, int "mode", bool "stacked", int "input_depth", bool "keep_tv_range")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPlugins64Dir + "25/flash3kyuu_deband.dll") : LoadPlugin(AviSynthPlugins64Dir + "25/flash3kyuu_deband2015.dll")
        f3kdb_dither(clip, mode, stacked, input_depth, keep_tv_range)
}