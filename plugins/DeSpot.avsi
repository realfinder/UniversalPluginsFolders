function DeSpot(clip clip, int "mthres", int "mwidth", int "mheight", int "merode", bool "interlaced", bool "median", int "p1", int "p2", int "pwidth", int "pheight", bool "ranked", int "sign", int "maxpts", int "p1percent", int "dilate", bool "fitluma", int "blur", int "tsmooth", int "show", int "mark_v", bool "show_chroma", bool "motpn", int "seg", bool "color", int "mscene", int "minpts", clip "extmask", bool "planar", string "outfile", bool "mc", int "spotmax1", int "spotmax2")
{
LoadPlugin(AviSynthPluginsDir + "25/DeSpot.dll")
        DeSpot(clip, mthres, mwidth, mheight, merode, interlaced, median, p1, p2, pwidth, pheight, ranked, sign, maxpts, p1percent, dilate, fitluma, blur, tsmooth, show, mark_v, show_chroma, motpn, seg, color, mscene, minpts, extmask, planar, outfile, mc, spotmax1, spotmax2)
}

import(AviSynthPluginsDir + "25/despot-helpers.avsi")