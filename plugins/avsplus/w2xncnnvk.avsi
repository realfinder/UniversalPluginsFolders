Function w2xncnnvk(clip input, int "noise", int "scale", int "tile_w", int "tile_h", int "model", int "gpu_id", int "gpu_thread", bool "tta", bool "fp32", bool "list_gpu")
{
LoadPlugin(AviSynthPluginsDir + "avsplus/w2xncnnvk.dll")
        w2xncnnvk(input, noise, scale, tile_w, tile_h, model, gpu_id, gpu_thread, tta, fp32, list_gpu)
}