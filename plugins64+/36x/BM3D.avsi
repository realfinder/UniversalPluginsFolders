Function BM3D_CPU(clip clip, clip "ref", float_array_nz "sigma", int_array_nz "block_step", int_array_nz "bm_range", int "radius", int_array_nz "ps_num", int_array_nz "ps_range", bool "chroma")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/BM3DCPU.dll")
        BM3D_CPU(clip, ref=ref, sigma=sigma, block_step=block_step, bm_range=bm_range, radius=radius, ps_num=ps_num, ps_range=ps_range, chroma=chroma)
}


Function BM3D_CUDA(clip clip, clip "ref", float_array_nz "sigma", int_array_nz "block_step", int_array_nz "bm_range", int "radius", int_array_nz "ps_num", int_array_nz "ps_range", bool "chroma", int "device_id", bool "fast", int "extractor_exp")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/BM3DCUDA.dll")
        BM3D_CUDA(clip, ref=ref, sigma=sigma, block_step=block_step, bm_range=bm_range, radius=radius, ps_num=ps_num, ps_range=ps_range, chroma=chroma, device_id=device_id, fast=fast, extractor_exp=extractor_exp)
}


Function BM3D_VAggregate(clip clip, int "radius")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/BM3D_VAggregate.dll")
        BM3D_VAggregate(clip, radius)
}