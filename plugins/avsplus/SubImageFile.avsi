Function SubImageFile(clip clip, string file, int "id", int_array "palette", bool "gray", bool "info", bool "flatten")
{
LoadPlugin(AviSynthPluginsPDir + "avsplus/SubImageFile.dll")
        SubImageFile(clip, file, id, palette=palette, gray=gray, info=info, flatten=flatten)
}