Function SubImageFile(clip clip, string file, int "id", int_array "palette", bool "gray", bool "info", bool "flatten")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/SubImageFile.dll")
        SubImageFile(clip, file, id, palette=palette, gray=gray, info=info, flatten=flatten)
}