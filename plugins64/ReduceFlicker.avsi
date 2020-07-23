function ReduceFlicker(clip clip, int "strength", bool "aggressive", bool "grey", int "opt", bool "raccess", bool "luma")
{
LoadPlugin(AviSynthPlugins64Dir + "26/ReduceFlicker.dll")
        ReduceFlicker(clip, strength, aggressive, grey, opt, raccess, luma)
}