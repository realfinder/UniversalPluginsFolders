function AutoCrop(clip clip, int "mode", int "wMultOf", int "hMultOf", int "leftAdd", int "topAdd", int "rightAdd", int "bottomAdd", int "threshold", int "samples", int "samplestartframe", int "sampleendframe", float "aspect")
{
LoadPlugin(AviSynthPlugins64Dir + "25/AutoCrop.dll")
    AutoCrop(clip, mode, wMultOf, hMultOf, leftAdd, topAdd, rightAdd, bottomAdd, threshold, samples, samplestartframe, sampleendframe, aspect)
}