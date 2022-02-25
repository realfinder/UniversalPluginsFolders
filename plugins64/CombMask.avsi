function CombMask2(clip clip, int "cthresh", int "mthresh", bool "chroma", bool "expand", int "metric", int "opt")
{
LoadPlugin(AviSynthPlugins64Dir + "26/CombMask.dll")
        CombMask2(clip, cthresh, mthresh, chroma, expand, metric, opt)
}

function MaskedMerge2(clip base, clip alt, clip mask, int "MI", int "blockx", int "blocky", bool "chroma", int "opt")
{
LoadPlugin(AviSynthPlugins64Dir + "26/CombMask.dll")
        MaskedMerge2(base, alt, mask, MI, blockx, blocky, chroma, opt)
}

function IsCombed2(clip clip, int "cthresh", int "mthresh", int "MI", int "blockx", int "blocky", int "metric", int "opt")
{
LoadPlugin(AviSynthPlugins64Dir + "26/CombMask.dll")
        IsCombed2(clip, cthresh, mthresh, MI, blockx, blocky, metric, opt)
}