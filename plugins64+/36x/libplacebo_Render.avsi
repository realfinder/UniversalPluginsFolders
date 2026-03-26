Function libplacebo_Render(clip clip,\
string "preset",\
int "width",\
int "height",\
float "src_left",\
float "src_top",\
float "src_width",\
float "src_height",\
string "aspect_mode",\
string "custom_shader_path",\
string "custom_shader_param",\
string "upscaler",\
string "upscaler_kernel",\
string "upscaler_window",\
float "upscaler_radius",\
float "upscaler_clamp",\
float "upscaler_taper",\
float "upscaler_blur",\
float "upscaler_antiring",\
float "upscaler_param1",\
float "upscaler_param2",\
float "upscaler_wparam1",\
float "upscaler_wparam2",\
bool "upscaler_polar",\
string "downscaler",\
string "downscaler_kernel",\
string "downscaler_window",\
float "downscaler_radius",\
float "downscaler_clamp",\
float "downscaler_taper",\
float "downscaler_blur",\
float "downscaler_antiring",\
float "downscaler_param1",\
float "downscaler_param2",\
float "downscaler_wparam1",\
float "downscaler_wparam2",\
bool "downscaler_polar",\
string "plane_upscaler",\
string "plane_upscaler_kernel",\
string "plane_upscaler_window",\
float "plane_upscaler_radius",\
float "plane_upscaler_clamp",\
float "plane_upscaler_taper",\
float "plane_upscaler_blur",\
float "plane_upscaler_antiring",\
float "plane_upscaler_param1",\
float "plane_upscaler_param2",\
float "plane_upscaler_wparam1",\
float "plane_upscaler_wparam2",\
bool "plane_upscaler_polar",\
string "plane_downscaler",\
string "plane_downscaler_kernel",\
string "plane_downscaler_window",\
float "plane_downscaler_radius",\
float "plane_downscaler_clamp",\
float "plane_downscaler_taper",\
float "plane_downscaler_blur",\
float "plane_downscaler_antiring",\
float "plane_downscaler_param1",\
float "plane_downscaler_param2",\
float "plane_downscaler_wparam1",\
float "plane_downscaler_wparam2",\
bool "plane_downscaler_polar",\
float "antiringing_strength",\
bool "linear_scaling",\
bool "sigmoid",\
float "sigmoid_center",\
float "sigmoid_slope",\
bool "deband",\
int "deband_iterations",\
float "deband_threshold",\
float "deband_radius",\
float "deband_grain",\
string "src_csp",\
string "src_matrix",\
string "src_trc",\
string "src_prim",\
string "src_levels",\
string "src_alpha",\
string "src_cplace",\
string "dst_csp",\
string "dst_matrix",\
string "dst_trc",\
string "dst_prim",\
string "dst_levels",\
string "dst_alpha",\
string "dst_cplace",\
string "color_map_preset",\
string "gamut_mapping",\
float "perceptual_deadzone",\
float "perceptual_strength",\
float "colorimetric_gamma",\
float "softclip_knee",\
float "softclip_desat",\
int "lut3d_size_i",\
int "lut3d_size_c",\
int "lut3d_size_h",\
bool "lut3d_tricubic",\
bool "gamut_expansion",\
string "tone_mapping_function",\
string_array "tone_constants",\
bool "inverse_tone_mapping",\
int "tone_lut_size",\
float "contrast_recovery",\
float "contrast_smoothness",\
bool "peak_detect",\
string "peak_detection_preset",\
float "peak_smoothing_period",\
float "scene_threshold_low",\
float "scene_threshold_high",\
float "peak_percentile",\
float "black_cutoff",\
float "src_max",\
float "src_min",\
float "dst_max",\
float "dst_min",\
string "tone_map_metadata",\
bool "dovi_metadata",\
float "brightness",\
float "contrast",\
float "saturation",\
float "hue",\
float "gamma",\
float "temperature",\
string "deinterlace_algo",\
int "field",\
bool "spatial_check",\
bool "dither",\
string "dither_method",\
int "dither_lut_size",\
bool "dither_temporal",\
string "error_diffusion_k",\
bool "visualize_lut",\
float "visualize_lut_x0",\
float "visualize_lut_y0",\
float "visualize_lut_x1",\
float "visualize_lut_y1",\
float "visualize_hue",\
float "visualize_theta",\
bool "show_clipping",\
string "out_fmt",\
string "lut",\
string "lut_type",\
string "border",\
float_array "border_color",\
float "background_transparency",\
float "blur_radius",\
float "corner_rounding",\
int "device",\
bool "list_devices",\
string "cache_path")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/libplacebo_Render.dll")
        libplacebo_Render(clip,\
preset,\
width,\
height,\
src_left,\
src_top,\
src_width,\
src_height,\
aspect_mode,\
custom_shader_path,\
custom_shader_param,\
upscaler,\
upscaler_kernel,\
upscaler_window,\
upscaler_radius,\
upscaler_clamp,\
upscaler_taper,\
upscaler_blur,\
upscaler_antiring,\
upscaler_param1,\
upscaler_param2,\
upscaler_wparam1,\
upscaler_wparam2,\
upscaler_polar,\
downscaler,\
downscaler_kernel,\
downscaler_window,\
downscaler_radius,\
downscaler_clamp,\
downscaler_taper,\
downscaler_blur,\
downscaler_antiring,\
downscaler_param1,\
downscaler_param2,\
downscaler_wparam1,\
downscaler_wparam2,\
downscaler_polar,\
plane_upscaler,\
plane_upscaler_kernel,\
plane_upscaler_window,\
plane_upscaler_radius,\
plane_upscaler_clamp,\
plane_upscaler_taper,\
plane_upscaler_blur,\
plane_upscaler_antiring,\
plane_upscaler_param1,\
plane_upscaler_param2,\
plane_upscaler_wparam1,\
plane_upscaler_wparam2,\
plane_upscaler_polar,\
plane_downscaler,\
plane_downscaler_kernel,\
plane_downscaler_window,\
plane_downscaler_radius,\
plane_downscaler_clamp,\
plane_downscaler_taper,\
plane_downscaler_blur,\
plane_downscaler_antiring,\
plane_downscaler_param1,\
plane_downscaler_param2,\
plane_downscaler_wparam1,\
plane_downscaler_wparam2,\
plane_downscaler_polar,\
antiringing_strength,\
linear_scaling,\
sigmoid,\
sigmoid_center,\
sigmoid_slope,\
deband,\
deband_iterations,\
deband_threshold,\
deband_radius,\
deband_grain,\
src_csp,\
src_matrix,\
src_trc,\
src_prim,\
src_levels,\
src_alpha,\
src_cplace,\
dst_csp,\
dst_matrix,\
dst_trc,\
dst_prim,\
dst_levels,\
dst_alpha,\
dst_cplace,\
color_map_preset,\
gamut_mapping,\
perceptual_deadzone,\
perceptual_strength,\
colorimetric_gamma,\
softclip_knee,\
softclip_desat,\
lut3d_size_i,\
lut3d_size_c,\
lut3d_size_h,\
lut3d_tricubic,\
gamut_expansion,\
tone_mapping_function,\
tone_constants=tone_constants,\
inverse_tone_mapping=inverse_tone_mapping,\
tone_lut_size=tone_lut_size,\
contrast_recovery=contrast_recovery,\
contrast_smoothness=contrast_smoothness,\
peak_detect=peak_detect,\
peak_detection_preset=peak_detection_preset,\
peak_smoothing_period=peak_smoothing_period,\
scene_threshold_low=scene_threshold_low,\
scene_threshold_high=scene_threshold_high,\
peak_percentile=peak_percentile,\
black_cutoff=black_cutoff,\
src_max=src_max,\
src_min=src_min,\
dst_max=dst_max,\
dst_min=dst_min,\
tone_map_metadata=tone_map_metadata,\
dovi_metadata=dovi_metadata,\
brightness=brightness,\
contrast=contrast,\
saturation=saturation,\
hue=hue,\
gamma=gamma,\
temperature=temperature,\
deinterlace_algo=deinterlace_algo,\
field=field,\
spatial_check=spatial_check,\
dither=dither,\
dither_method=dither_method,\
dither_lut_size=dither_lut_size,\
dither_temporal=dither_temporal,\
error_diffusion_k=error_diffusion_k,\
visualize_lut=visualize_lut,\
visualize_lut_x0=visualize_lut_x0,\
visualize_lut_y0=visualize_lut_y0,\
visualize_lut_x1=visualize_lut_x1,\
visualize_lut_y1=visualize_lut_y1,\
visualize_hue=visualize_hue,\
visualize_theta=visualize_theta,\
show_clipping=show_clipping,\
out_fmt=out_fmt,\
lut=lut,\
lut_type=lut_type,\
border=border,\
border_color=border_color,\
background_transparency=background_transparency,\
blur_radius=blur_radius,\
corner_rounding=corner_rounding,\
device=device,\
list_devices=list_devices,\
cache_path=cache_path)
}