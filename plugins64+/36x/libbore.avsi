Function bore_SinglePlane(clip input, int "left", int "right", int "top", int "bottom", clip "weight_mask", int "plane")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/libbore.dll")
        bore_SinglePlane(input, left, right, top, bottom, weight_mask, plane)
}


Function bore_MultiPlane(clip input, int "left", int "right", int "top", int "bottom", clip "weight_mask", int "plane")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/libbore.dll")
        bore_MultiPlane(input, left, right, top, bottom, weight_mask, plane)
}


Function bore_SinglePlaneLimited(clip input, int "left", int "right", int "top", int "bottom", clip "weight_mask", int "plane", int "ref_line_size")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/libbore.dll")
        bore_SinglePlaneLimited(input, left, right, top, bottom, weight_mask, plane, ref_line_size)
}


Function bore_SinglePlaneWeighted(clip input, int "left", int "right", int "top", int "bottom", clip "weight_mask", int "plane", int "ref_line_size", float "sigmaS", float "sigmaR", float "sigmaD")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/libbore.dll")
        bore_SinglePlaneWeighted(input, left, right, top, bottom, weight_mask, plane, ref_line_size, sigmaS, sigmaR, sigmaD)
}


Function bore_SinglePlaneDebug(clip input, int "left", int "right", int "top", int "bottom", clip "weight_mask", int "plane")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/libbore.dll")
        bore_SinglePlaneDebug(input, left, right, top, bottom, weight_mask, plane)
}