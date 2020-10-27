function CAS(clip clip, float "sharpness", int "y", int "u", int "v", int "opt")
{
LoadPlugin(AviSynthPlugins64Dir + "26/CAS.dll")
        CAS(clip, sharpness, y, u, v, opt)
}