function RawSource(string "file", int "width", int "height", string "pixel_type", int "fpsnum", int "fpsden", string "index", bool "show")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/RawSource_2.5x.dll") : LoadPlugin(AviSynthPluginsDir + "rawsource/rawsource26a4-20130826/RawSource26.dll")
        RawSource(file, width, height, pixel_type, fpsnum, fpsden, index, show)
}

function RawSourcePlus(string "file", int "width", int "height", string "pixel_type", int "fpsnum", int "fpsden", string "index", bool "show")
{
LoadPlugin(AviSynthPluginsDir + "avsplus/RawSourcePlus.dll")
        RawSourcePlus(file, width, height, pixel_type, fpsnum, fpsden, index, show)
}