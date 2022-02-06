function xNLMeans(clip clip, int "a", int "s", int "d", val "h", float "sdev", int "planes", bool "lsb", clip "mask", clip "rclip", float "digits", float "diffout", float "lcomp", float "vcomp", float "wmin", float "dw", int "threads")
{
LoadPlugin(AviSynthPluginsDir + "26/xNLMeans.dll")
        xNLMeans(clip, a, s, d, h, sdev, planes, lsb, mask, rclip, digits, diffout, lcomp, vcomp, wmin, dw, threads)
}

function xNLMeans_VersionNumber()
{
LoadPlugin(AviSynthPluginsDir + "26/xNLMeans.dll")
        xNLMeans_VersionNumber()
}