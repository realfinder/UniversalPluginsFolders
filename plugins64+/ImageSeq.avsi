function ImageReader(string "file", int "start", int "end", float "fps", bool "use_DevIL", bool "info", string "pixel_type")
{
LoadPlugin(AviSynthPlugins64PDir + "any/default/ImageSeq.dll")
        ImageReader(file, start, end, fps, use_DevIL, info, pixel_type)
}

function ImageSource(string "file", int "start", int "end", float "fps", bool "use_DevIL", bool "info", string "pixel_type")
{
LoadPlugin(AviSynthPlugins64PDir + "any/default/ImageSeq.dll")
        ImageSource(file, start, end, fps, use_DevIL, info, pixel_type)
}

function ImageSourceAnim(string "file", float "fps", bool "use_DevIL", bool "info", string "pixel_type")
{
LoadPlugin(AviSynthPlugins64PDir + "any/default/ImageSeq.dll")
        ImageSourceAnim(file, fps, use_DevIL, info, pixel_type)
}

function ImageWriter(clip clip, string "file", int "start", int "end", string "type", bool "info")
{
LoadPlugin(AviSynthPlugins64PDir + "any/default/ImageSeq.dll")
        ImageWriter(clip, file, start, end, type, info)
}