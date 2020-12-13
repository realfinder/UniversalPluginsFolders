function RawSource(string "file", int "width", int "height", string "pixel_type", int "fpsnum", int "fpsden", string "index", bool "show")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPlugins64Dir + "25/RawSource_2.5x.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/RawSource26.dll")
        RawSource(file, width, height, pixel_type, fpsnum, fpsden, index, show)
}