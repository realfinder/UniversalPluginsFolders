#function ConvertFromDoubleWidth(clip clip, int "bits")
#{
#AvsPlusVersionNumber < 3276 ? LoadPlugin(AviSynthPlugins64Dir + "26/Shader165.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/Shader.dll")
#        ConvertFromDoubleWidth(clip, bits)
#}

#function ConvertFromStacked(clip clip, int "bits")
#{
#AvsPlusVersionNumber < 3276 ? LoadPlugin(AviSynthPlugins64Dir + "26/Shader165.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/Shader.dll")
#        ConvertFromStacked(clip, bits)
#}

#function ConvertToDoubleWidth(clip clip)
#{
#AvsPlusVersionNumber < 3276 ? LoadPlugin(AviSynthPlugins64Dir + "26/Shader165.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/Shader.dll")
#        ConvertToDoubleWidth(clip)
#}

#function ConvertToStacked(clip clip)
#{
#AvsPlusVersionNumber < 3276 ? LoadPlugin(AviSynthPlugins64Dir + "26/Shader165.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/Shader.dll")
#        ConvertToStacked(clip)
#}

function GetBitDepth(clip clip, string "format")
{
AvsPlusVersionNumber < 3276 ? LoadPlugin(AviSynthPlugins64Dir + "26/Shader165.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/Shader.dll")
        GetBitDepth(clip, format)
}

function ConvertFromShader(clip clip, int "Precision", string "Format", bool "lsb", int "opt")
{
AvsPlusVersionNumber < 3276 ? LoadPlugin(AviSynthPlugins64Dir + "26/Shader165.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/Shader.dll")
        ConvertFromShader(clip, Precision, Format, lsb, opt)
}

function ConvertToShader(clip clip, int "Precision", bool "lsb", bool "planar", int "opt")
{
AvsPlusVersionNumber < 3276 ? LoadPlugin(AviSynthPlugins64Dir + "26/Shader165.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/Shader.dll")
        ConvertToShader(clip, Precision, lsb, planar, opt)
}

function ExecuteShader(clip clip, clip "Clip1", clip "Clip2", clip "Clip3", clip "Clip4", clip "Clip5", clip "Clip6", clip "Clip7", clip "Clip8", clip "Clip9", int "Clip1Precision", int "Clip2Precision", int "Clip3Precision", int "Clip4Precision", int "Clip5Precision", int "Clip6Precision", int "Clip7Precision", int "Clip8Precision", int "Clip9Precision", int "Precision", int "OutputPrecision", bool "PlanarOut", int "Engines", bool "Resource")
{
AvsPlusVersionNumber < 3276 ? LoadPlugin(AviSynthPlugins64Dir + "26/Shader165.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/Shader.dll")
        ExecuteShader(clip, Clip1, Clip2, Clip3, Clip4, Clip5, Clip6, Clip7, Clip8, Clip9, Clip1Precision, Clip2Precision, Clip3Precision, Clip4Precision, Clip5Precision, Clip6Precision, Clip7Precision, Clip8Precision, Clip9Precision, Precision, OutputPrecision, PlanarOut, Engines, Resource)
}

function Shader(clip clip, string "Path", string "EntryPoint", string "ShaderModel", string "Param0", string "Param1", string "Param2", string "Param3", string "Param4", string "Param5", string "Param6", string "Param7", string "Param8", int "Clip1", int "Clip2", int "Clip3", int "Clip4", int "Clip5", int "Clip6", int "Clip7", int "Clip8", int "Clip9", int "Output", int "Width", int "Height", int "Precision", string "Defines")
{
AvsPlusVersionNumber < 3276 ? LoadPlugin(AviSynthPlugins64Dir + "26/Shader165.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/Shader.dll")
        Shader(clip, Path, EntryPoint, ShaderModel, Param0, Param1, Param2, Param3, Param4, Param5, Param6, Param7, Param8, Clip1, Clip2, Clip3, Clip4, Clip5, Clip6, Clip7, Clip8, Clip9, Output, Width, Height, Precision, Defines)
}