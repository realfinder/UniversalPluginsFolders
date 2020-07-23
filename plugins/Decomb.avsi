function Telecide(clip clip, int "back", int "guide", float "gthresh", int "post", bool "chroma", float "vthresh", float "bthresh", float "dthresh", bool "blend", int "nt", int "y0", int "y1", bool "hints", string "ovr", bool "show", bool "debug")
{
LoadPlugin(AviSynthPluginsDir + "25/Decomb.dll")
        Telecide(clip, back, guide, gthresh, post, chroma, vthresh, bthresh, dthresh, blend, nt, y0, y1, hints, ovr, show, debug)
}

function Decimate(clip clip, int "cycle", int "mode", float "threshold", float "threshold2", int "quality", string "ovr", bool "show", bool "debug")
{
LoadPlugin(AviSynthPluginsDir + "25/Decomb.dll")
        Decimate(clip, cycle, mode, threshold, threshold2, quality, ovr, show, debug)
}

function FieldDeinterlace(clip clip, bool "full", int "threshold", int "dthreshold", bool "map", bool "blend", bool "chroma", string "ovr", bool "show", bool "debug")
{
LoadPlugin(AviSynthPluginsDir + "25/Decomb.dll")
        FieldDeinterlace(clip, full, threshold, dthreshold, map, blend, chroma, ovr, show, debug)
}


function IsCombed(clip clip, int "threshold")
{
LoadPlugin(AviSynthPluginsDir + "25/Decomb.dll")
        IsCombed(clip, threshold)
}