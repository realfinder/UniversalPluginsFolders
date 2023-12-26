Function VMAF(clip reference, clip distorted, string log_path, int "log_format", int_array "model", int_array "feature", string "cambi_opt")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/VMAF.dll")
        VMAF(reference, distorted, log_path, log_format, model=model, feature=feature, cambi_opt=cambi_opt)
}

Function VMAF2(clip reference, clip "distorted", int_array "feature", string "cambi_opt")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/VMAF.dll")
        VMAF2(reference, distorted, feature=feature, cambi_opt=cambi_opt)
}