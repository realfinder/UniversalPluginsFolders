Function BM3D_CPU(clip clip, clip "ref", float_array "sigma", int_array "block_step", int_array "bm_range", int "radius", int_array "ps_num", int_array "ps_range", bool "chroma")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/BM3DCPU.dll")
        BM3D_CPU(clip, ref=ref, sigma=IsArray(sigma) ? ArraySize(sigma) == 0 ? undefined : sigma : sigma, block_step=IsArray(block_step) ? ArraySize(block_step) == 0 ? undefined : block_step : block_step, bm_range=IsArray(bm_range) ? ArraySize(bm_range) == 0 ? undefined : bm_range : bm_range, radius=radius, ps_num=IsArray(ps_num) ? ArraySize(ps_num) == 0 ? undefined : ps_num : ps_num, ps_range=IsArray(ps_range) ? ArraySize(ps_range) == 0 ? undefined : ps_range : ps_range, chroma=chroma)
}


Function BM3D_CUDA(clip clip, clip "ref", float_array "sigma", int_array "block_step", int_array "bm_range", int "radius", int_array "ps_num", int_array "ps_range", bool "chroma", int "device_id", bool "fast", int "extractor_exp")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/BM3DCUDA.dll")
        BM3D_CUDA(clip, ref=ref, sigma=IsArray(sigma) ? ArraySize(sigma) == 0 ? undefined : sigma : sigma, block_step=IsArray(block_step) ? ArraySize(block_step) == 0 ? undefined : block_step : block_step, bm_range=IsArray(bm_range) ? ArraySize(bm_range) == 0 ? undefined : bm_range : bm_range, radius=radius, ps_num=IsArray(ps_num) ? ArraySize(ps_num) == 0 ? undefined : ps_num : ps_num, ps_range=IsArray(ps_range) ? ArraySize(ps_range) == 0 ? undefined : ps_range : ps_range, chroma=chroma, device_id, fast=fast, extractor_exp=extractor_exp)
}


Function BM3D_VAggregate(clip clip, int "radius")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/BM3D_VAggregate.dll")
        BM3D_VAggregate(clip, radius)
}