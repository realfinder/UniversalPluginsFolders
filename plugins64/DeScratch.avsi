function descratch(clip clip, int "mindif", int "asym", int "maxgap", int "maxwidth", int "minlen", int "maxlen", float "maxangle", int "blurlen", int "keep", int "border", int "modeY", int "modeU", int "modeV", int "mindifUV", bool "mark", int "minwidth", int "left", int "right")  {
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPlugins64Dir + "25/descratch.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/descratch.dll")
    descratch(clip, mindif, asym, maxgap, maxwidth, minlen, maxlen, maxangle, blurlen, keep, border, modeY, modeU, modeV, mindifUV, mark, minwidth, left, right)
}