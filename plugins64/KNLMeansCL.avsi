function KNLMeansCL(clip clip, int "d", int "a", int "s", float "h", string "channels", int "wmode", float "wref", clip "rclip", string "device_type", int "device_id", int "ocl_x", int "ocl_y", int "ocl_r", bool "stacked", bool "info", int "mode_9_to_15bits")
{
LoadPlugin(AviSynthPlugins64Dir + "26/KNLMeansCL.dll")
        KNLMeansCL(clip, d, a, s, h, channels, wmode, wref, rclip, device_type, device_id, ocl_x, ocl_y, ocl_r, stacked, info, mode_9_to_15bits)
}