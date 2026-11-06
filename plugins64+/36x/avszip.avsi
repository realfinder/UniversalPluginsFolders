function avszip_AdaptiveBinarize(clip clip, clip clip2, int "c")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/avszip.dll")
        avszip_AdaptiveBinarize(clip, clip2, c)
}


function avszip_AdaptiveGrainMask(clip clip, float "luma_scaling")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/avszip.dll")
        avszip_AdaptiveGrainMask(clip, luma_scaling)
}


function avszip_Bilateral(clip clip, clip "ref", float_array "sigmaS", float_array "sigmaR", int_array "planes", int_array "algorithm", int_array "PBFICnum")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/avszip.dll")
        avszip_Bilateral(clip, ref, sigmaS=sigmaS, sigmaR=sigmaR, planes=planes, algorithm=algorithm, PBFICnum=PBFICnum)
}


function avszip_BilateralDither(clip clip, clip "ref", int_array "radius", float_array "thr", float_array "flat", float_array "wmin", float_array "subspl", int_array "planes")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/avszip.dll")
        avszip_BilateralDither(clip, ref, radius=radius, thr=thr, flat=flat, wmin=wmin, subspl=subspl, planes=planes)
}


function avszip_BM3D(clip clip, clip "ref", float_array "sigma", int_array "block_step", int_array "bm_range", int "radius", int_array "ps_num", int_array "ps_range", bool "chroma", string_array "bm_error_s", string_array "transform_2d_s", string_array "transform_1d_s")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/avszip.dll")
        avszip_BM3D(clip, ref, sigma=sigma, block_step=block_step, bm_range=bm_range, radius=radius, ps_num=ps_num, ps_range=ps_range, chroma=chroma, bm_error_s=bm_error_s, transform_2d_s=transform_2d_s, transform_1d_s=transform_1d_s)
}


function avszip_BoxBlur(clip clip, int_array "planes", int "hradius", int "hpasses", int "vradius", int "vpasses")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/avszip.dll")
        avszip_BoxBlur(clip, planes=planes, hradius=hradius, hpasses=hpasses, vradius=vradius, vpasses=vpasses)
}


function avszip_Checkmate(clip, int "thr", int "tmax", int "tthr2")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/avszip.dll")
        avszip_Checkmate(clip, thr, tmax, tthr2)
}


function avszip_CLAHE(clip clip, int "limit", int_array "tiles")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/avszip.dll")
        avszip_CLAHE(clip, limit, tiles)
}


function avszip_ColorMap(clip clip, int "color")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/avszip.dll")
       avszip_ColorMap(clip, color)
}


function avszip_CombMask(clip clip, int "cthresh", int "mthresh", bool "expand", int "metric")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/avszip.dll")
       avszip_CombMask(clip, cthresh, mthresh, expand, metric)
}


function avszip_CombMaskMT(clip clip, int "thY1", int "thY2")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/avszip.dll")
       avszip_CombMaskMT(clip, thY1, thY2)
}


function avszip_Compress(clip clip, int "codec", int "qscale", int "quality", int "dc_prec", bool "chroma")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/avszip.dll")
       avszip_Compress(clip, codec, qscale, quality, dc_prec, chroma)
}


function avszip_Deband(clip clip, int "range", float_array "thr", float_array "grain", int "sample_mode", int "seed", bool "blur_first", bool "dynamic_grain", bool "keep_tv_range", int "random_algo_ref", int "random_algo_grain", float "random_param_ref", float "random_param_grain", float_array "thr1", float_array "thr2", float "angle_boost", float "max_angle")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/avszip.dll")
       avszip_Deband(clip, range, thr=thr, grain=grain, sample_mode=sample_mode, seed=seed, blur_first=blur_first, dynamic_grain=dynamic_grain, keep_tv_range=keep_tv_range, random_algo_ref=random_algo_ref, random_algo_grain=random_algo_grain, random_param_ref=random_param_ref, random_param_grain=random_param_grain, thr1=thr1, thr2=thr2, angle_boost=angle_boost, max_angle=max_angle)
}


function avszip_Dither(clip clip, int bitdepth, int "dither_type", int "sample_type", bool "fulls", bool "fulld")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/avszip.dll")
       avszip_Dither(clip, bitdepth, dither_type, sample_type, fulls, fulld)
}


function avszip_EEDI3(clip clip, int field, bool "dh", float "alpha", float "beta", float "gamma", int "nrad", int "mdis", bool "hp", int "vcheck", float "vthresh0", float "vthresh1", float "vthresh2", clip "sclip", clip "mclip")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/avszip.dll")
       avszip_EEDI3(clip, field, dh, alpha, beta, gamma, nrad, mdis, hp, vcheck, vthresh0, vthresh1, vthresh2, sclip, mclip)
}


function avszip_EEDI3H(clip clip, int field, bool "dh", float "alpha", float "beta", float "gamma", int "nrad", int "mdis", bool "hp", int "vcheck", float "vthresh0", float "vthresh1", float "vthresh2", clip "sclip", clip "mclip")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/avszip.dll")
       avszip_EEDI3H(clip, field, dh, alpha, beta, gamma, nrad, mdis, hp, vcheck, vthresh0, vthresh1, vthresh2, sclip, mclip)
}


function avszip_ImageRead(string_array path, bool "validate")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/avszip.dll")
       avszip_ImageRead(path, validate=validate)
}


function avszip_LimitFilter(clip flt, clip src, clip "ref", float_array "dark_thr", float_array "bright_thr", float_array "elast", int_array "planes")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/avszip.dll")
       avszip_LimitFilter(flt, src, ref, dark_thr=dark_thr, bright_thr=bright_thr, elast=elast, planes=planes)
}


function avszip_Limiter(clip clip, float_array "min", float_array "max", bool "tv_range", bool "mask", int_array "planes")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/avszip.dll")
       avszip_Limiter(clip, min=min, max=max, tv_range=tv_range, mask=mask, planes=planes)
}


function avszip_MosquitoNR(clip clip, int_array "strength", int_array "restore", int_array "radius", int_array "planes")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/avszip.dll")
       avszip_MosquitoNR(clip, strength=strength, restore=restore, radius=radius, planes=planes)
}


function avszip_NLMeans(clip clip, int "d", int "a", int "s", float "h", string "channels", int "wmode", float "wref", clip "rclip")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/avszip.dll")
       avszip_NLMeans(clip, d, a, s, h, channels, wmode, wref, rclip)
}


function avszip_PlaneAverage(clip clip, int_array exclude, clip "clipb", int_array "planes", string "prop")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/avszip.dll")
       avszip_PlaneAverage(clip, exclude, clipb=clipb, planes=planes, prop=prop)
}


function avszip_PlaneMinMax(clip clip, float "minthr", float "maxthr", clip "clipb", int_array "planes", string "prop")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/avszip.dll")
       avszip_PlaneMinMax(clip, minthr, maxthr, clipb, planes=planes, prop=prop)
}


function avszip_RFS(clip clip, clip clipb, int_array frames, bool "mismatch", int_array "planes")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/avszip.dll")
       avszip_RFS(clip, clipb, frames, mismatch=mismatch, planes=planes)
}


function avszip_SSIMULACRA2(clip reference, clip distorted)
{
LoadPlugin(AviSynthPlugins64PDir + "36x/avszip.dll")
       avszip_SSIMULACRA2(reference, distorted)
}


function avszip_Butteraugli(clip reference, clip distorted, float "intensity_target", float "hf_asymmetry", float "xmul", int "distmap")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/avszip.dll")
       avszip_Butteraugli(reference, distorted, intensity_target, hf_asymmetry, xmul, distmap)
}


function avszip_Tonemap(clip clip, int "src_csp", int "dst_csp", int "dst_prim", float "src_max", float "src_min", float "dst_max", float "dst_min", bool "dynamic_peak_detection", float "smoothing_period", float "scene_threshold_low", float "scene_threshold_high", float "percentile", float "black_cutoff", int "gamut_mapping", int "tone_mapping_function", string "tone_mapping_function_s", float "tone_mapping_param", int "metadata", bool "use_dovi", clip "dovi_el", bool "show_clipping", float "contrast_recovery", float "contrast_smoothness", int "lut_size", float "mastering_clip", float "film_strength", bool "inverse_tone_mapping", float "knee_adaptation", float "knee_minimum", float "knee_maximum", float "knee_default", float "knee_offset", float "slope_tuning", float "slope_offset", float "spline_contrast", float "reinhard_contrast", float "linear_knee", float "exposure", bool "gamut_expansion", int_array "lut3d_size", bool "lut3d_tricubic", float "perceptual_deadzone", float "perceptual_strength", float "colorimetric_gamma", float "softclip_knee", float "softclip_desat", bool "cache_frame")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/avszip.dll")
       avszip_Tonemap(clip, src_csp, dst_csp, dst_prim, src_max, src_min, dst_max, dst_min, dynamic_peak_detection, smoothing_period, scene_threshold_low, scene_threshold_high, percentile, black_cutoff, gamut_mapping, tone_mapping_function, tone_mapping_function_s, tone_mapping_param, metadata, use_dovi, dovi_el, show_clipping, contrast_recovery, contrast_smoothness, lut_size, mastering_clip, film_strength, inverse_tone_mapping, knee_adaptation, knee_minimum, knee_maximum, knee_default, knee_offset, slope_tuning, slope_offset, spline_contrast, reinhard_contrast, linear_knee, exposure, gamut_expansion, lut3d_size=lut3d_size, lut3d_tricubic=lut3d_tricubic, perceptual_deadzone=perceptual_deadzone, perceptual_strength=perceptual_strength, colorimetric_gamma=colorimetric_gamma, softclip_knee=softclip_knee, softclip_desat=softclip_desat, cache_frame=cache_frame)
}


function avszip_WNNM(clip clip, float_array "sigma", int "block_size", int "block_step", int "group_size", int "bm_range", int "radius", int "ps_num", int "ps_range", bool "residual", bool "adaptive_aggregation", clip "rclip")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/avszip.dll")
       avszip_WNNM(clip, sigma=sigma, block_size=block_size, block_step=block_step, group_size=group_size, bm_range=bm_range, radius=radius, ps_num=ps_num, ps_range=ps_range, residual=residual, adaptive_aggregation=adaptive_aggregation, rclip=rclip)
}


function avszip_XPSNR(clip reference, clip distorted, bool "temporal", bool "verbose")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/avszip.dll")
       avszip_XPSNR(reference, distorted, temporal, verbose)
}