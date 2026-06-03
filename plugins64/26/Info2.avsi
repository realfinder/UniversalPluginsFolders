function Info2(clip clip, int "size", string "font", int "background", bool "verbose", bool "glyph")
{
LoadPlugin(AviSynthPlugins64Dir + "26/Info2.dll")
        Info2(clip, size, font, background, verbose, glyph)
}

function ShowFrameNumber2( clip clip, int "offset", float "x", float "y", string "font", int "size", float "aspect", float "scale", float "white", bool "simd" )
{
LoadPlugin(AviSynthPlugins64Dir + "26/Info2.dll")
        ShowFrameNumber2( clip, offset, x, y, font, size, aspect, scale, white, simd )
}

function ShowTime2( clip clip, val "offset", float "x", float "y", string "font", int "size", float "aspect", float "scale", float "white", bool "simd" )
{
LoadPlugin(AviSynthPlugins64Dir + "26/Info2.dll")
        ShowTime2( clip, offset, x, y, font, size, aspect, scale, white, simd )
}

function ShowSMPTE2( clip clip, val "offset", float "x", float "y", string "font", int "size", float "aspect", float "scale", float "white", bool "simd" )
{
LoadPlugin(AviSynthPlugins64Dir + "26/Info2.dll")
        ShowSMPTE2( clip, offset, x, y, font, size, aspect, scale, white, simd )
}