function TEMmod(clip clip, float "threshY", float "threshC", int "type", int "link", int "chroma", bool "invert", bool "preblur", float "scale")
{
LoadPlugin(AviSynthPlugins64Dir + "26/TEMmod.dll")
        TEMmod(clip, threshY, threshC, type, link, chroma, invert, preblur, scale)
}