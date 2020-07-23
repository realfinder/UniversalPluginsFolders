function dctfun4b(clip clip, int "luma_thresh", int "chroma_thresh")
{
LoadPlugin(AviSynthPluginsDir + "25/dctfun4b.dll")
        dctfun4b(clip, luma_thresh, chroma_thresh)
}