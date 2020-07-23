function _2DCleanYUY2(clip clip, int "interlaced", int "thresholdY", int "radiusX", int "radiusY", int "dmode", int "thresholdU", int "thresholdV")
{
LoadPlugin(AviSynthPluginsDir + "25/_2DCleanYUY2_for_25.dll")
        _2DCleanYUY2(clip, interlaced, thresholdY, radiusX, radiusY, dmode, thresholdU, thresholdV)
}