function vsTEdgeMask(clip clip, float "threshY", float "threshU", float "threshV", int "type", int "link", float "scale", int "y", int "u", int "v", int "opt")
{
LoadPlugin(AviSynthPlugins64Dir + "26/vsTEdgeMask.dll")
        vsTEdgeMask(clip, threshY, threshU, threshV, type, link, scale, y, u, v, opt)
}