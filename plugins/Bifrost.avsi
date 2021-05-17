function Bifrost(clip clip, clip "altclip", float "luma_thresh", int "variation", bool "conservative_mask", bool "interlaced", int "blockx", int "blocky") 
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/Bifrost.dll") : LoadPlugin(AviSynthPluginsDir + "26/Bifrost.dll")
    Bifrost(clip, altclip, luma_thresh, variation, conservative_mask, interlaced, blockx, blocky) 
}