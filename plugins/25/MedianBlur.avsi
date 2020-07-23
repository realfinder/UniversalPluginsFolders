function MedianBlur(clip clip, int "radiusy", int "radiusu", int "radiusv", bool "calcborder")
{
LoadPlugin(AviSynthPluginsDir + "25/MedianBlur.dll")
        MedianBlur(clip, radiusy, radiusu, radiusv, calcborder)
}

function MedianBlurB(clip clip, int "radiusy", int "radiusu", int "radiusv", int "thresholdy", int "thresholdu", int "thresholdv", bool "calcborder")
{
LoadPlugin(AviSynthPluginsDir + "25/MedianBlur.dll")
        MedianBlurB(clip, radiusy, radiusu, radiusv, thresholdy, thresholdu, thresholdv, calcborder)
}

function medianblurcw(clip clip, int "radiusy", int "radiusu", int "radiusv", int "weighty", int "weightu", int "weightv", bool "calcborder")
{
LoadPlugin(AviSynthPluginsDir + "25/MedianBlur.dll")
        medianblurcw(clip, radiusy, radiusu, radiusv, weighty, weightu, weightv, calcborder)
}

function medianblurt(clip clip, int "radiusy", int "radiusu", int "radiusv", int "temporalradius", bool "mc", bool "calcborder", bool "markscenechange", int "blksize", int "pel", int "lambda", int "thSCD1", int "thSCD2", int "searchparam", bool "spfull", bool "bsfull")
{
LoadPlugin(AviSynthPluginsDir + "25/MedianBlur.dll")
        medianblurt(clip, radiusy, radiusu, radiusv, temporalradius, mc, calcborder, markscenechange, blksize, pel, lambda, thSCD1, thSCD2, searchparam, spfull, bsfull)
}