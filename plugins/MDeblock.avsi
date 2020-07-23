function MDeblock(clip clip, string "mode", int "width", int "height", int "cwidth", int "cheight", int "leftcrop", int "topcrop")
{
LoadPlugin(AviSynthPluginsDir + "25/MDeblockS.dll")
        MDeblock(clip, mode, width, height, cwidth, cheight, leftcrop, topcrop)
}