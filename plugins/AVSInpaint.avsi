function DistanceFunction(clip Clip, float "Scale", float "PixelAspect")
{
Load_Stdcall_plugin(AviSynthPluginsDir + "cplugin/AVSInpaint.dll")
        DistanceFunction(Clip, Scale, PixelAspect)
}

function AnalyzeLogo(clip Clip, clip "Mask", bool "ComputeAlpha", float "DeviationWeight", float "SubsamplingWeight")
{
Load_Stdcall_plugin(AviSynthPluginsDir + "cplugin/AVSInpaint.dll")
        AnalyzeLogo(Clip, Mask, ComputeAlpha, DeviationWeight, SubsamplingWeight)
}

function DeblendLogo(clip Clip, clip Logo, clip "Alpha")
{
Load_Stdcall_plugin(AviSynthPluginsDir + "cplugin/AVSInpaint.dll")
        DeblendLogo(Clip, Logo, Alpha)
}

function InpaintLogo(clip Clip, clip "Mask", float "Radius", float "Sharpness", float "PreBlur", float "PostBlur", float "ChromaWeight", float "PreBlurSize", float "PostBlurSize", bool "ChromaTensor", float "PixelAspect", int "Steps")
{
Load_Stdcall_plugin(AviSynthPluginsDir + "cplugin/AVSInpaint.dll")
        InpaintLogo(Clip, Mask, Radius, Sharpness, PreBlur, PostBlur, ChromaWeight, PreBlurSize, PostBlurSize, ChromaTensor, PixelAspect, Steps)
}