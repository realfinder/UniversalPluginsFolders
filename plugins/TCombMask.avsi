function TCombMask(clip clip, int "athreshL", int "athreshC", int "mthreshL", int "mthreshC", int "edgethreshL", int "edgethreshC", bool "denoise", bool "lcLinked", int "map", int "mtnChk", int "ametric", int "field", int "low", int "high", bool "chkPrg", int "athreshLP", int "athreshCP", int "mthreshLP", int "mthreshCP", int "edgethreshLP", int "edgethreshCP", bool "denoiseP", int "mtnChkP", int "ametricP", bool "chroma", int "MI", bool "debug", int "opt")
{
LoadPlugin(AviSynthPluginsDir + "25/TCombMask.dll")
        TCombMask(clip, athreshL, athreshC, mthreshL, mthreshC, edgethreshL, edgethreshC, denoise, lcLinked, map, mtnChk, ametric, field, low, high, chkPrg, athreshLP, athreshCP, mthreshLP, mthreshCP, edgethreshLP, edgethreshCP, denoiseP, mtnChkP, ametricP, chroma, MI, debug, opt)
}

function IsCombedT(clip clip, int "athreshL", int "athreshC", int "mthreshL", int "mthreshC", int "edgethreshL", int "edgethreshC", bool "denoise", bool "chroma", int "mtnChk", int "ametric", int "MI", bool "debug", int "opt")
{
LoadPlugin(AviSynthPluginsDir + "25/TCombMask.dll")
        IsCombedT(clip, athreshL, athreshC, mthreshL, mthreshC, edgethreshL, edgethreshC, denoise, chroma, mtnChk, ametric, MI, debug, opt)
}

function TMaskedMerge(clip clip, clip clip1, clip clip2, int "value", int "opt")
{
LoadPlugin(AviSynthPluginsDir + "25/TCombMask.dll")
        TMaskedMerge(clip, clip1, clip2, value, opt)
}

function TMaskedMerge3(clip clip, clip clip1, clip clip2, int "value1", int "value2", int "opt")
{
LoadPlugin(AviSynthPluginsDir + "25/TCombMask.dll")
        TMaskedMerge3(clip, clip1, clip2, value1, value2, opt)
}

function TFieldBlank(clip clip, int "field", int "value", int "opt")
{
LoadPlugin(AviSynthPluginsDir + "25/TCombMask.dll")
        TFieldBlank(clip, field, value, opt)
}

function TMaskBlank(clip clip, int "value", int "opt")
{
LoadPlugin(AviSynthPluginsDir + "25/TCombMask.dll")
        TMaskBlank(clip, value, opt)
}