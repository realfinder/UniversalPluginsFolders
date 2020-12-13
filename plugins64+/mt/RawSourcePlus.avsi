function RawSourcePlus(string "file", int "width", int "height", string "pixel_type", int "fpsnum", int "fpsden", string "index", bool "show")
{
LoadPlugin(AviSynthPlugins64Dir + "mt/RawSourcePlus.dll")
        RawSourcePlus(file, width, height, pixel_type, fpsnum, fpsden, index, show)
}