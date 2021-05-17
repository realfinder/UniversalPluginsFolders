function Bifrost(clip clip, clip "altclip", float "luma_thresh", int "variation", bool "conservative_mask", bool "interlaced", int "blockx", int "blocky") 
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPlugins64Dir + "25/Bifrost.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/Bifrost.dll")
    Bifrost(clip, altclip, luma_thresh, variation, conservative_mask, interlaced, blockx, blocky) 
}