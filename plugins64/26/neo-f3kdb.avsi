function neo_f3kdb(clip clip, int "range", int "Y", int "Cb", int "Cr", int "grainY", int "grainC", int "sample_mode", int "seed", bool "blur_first", bool "dynamic_grain", int "opt", bool "mt", int "dither_algo", bool "keep_tv_range", int "output_depth", int "random_algo_ref", int "random_algo_grain", float "random_param_ref", float "random_param_grain", string "preset", int "y_1", int "cb_1", int "cr_1", int "y_2", int "cb_2", int "cr_2", bool "scale")
{
LoadPlugin(AviSynthPlugins64Dir + "26/neo-f3kdb.dll")
        neo_f3kdb(clip, range, Y, Cb, Cr, grainY, grainC, sample_mode, seed, blur_first, dynamic_grain, opt, mt, dither_algo, keep_tv_range, output_depth, random_algo_ref, random_algo_grain, random_param_ref, random_param_grain, preset, y_1, cb_1, cr_1, y_2, cb_2, cr_2, scale)
}