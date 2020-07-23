function Yadif(clip clip, int "mode", int "order", bool "planar", int "opt") 
{
Load_Stdcall_plugin(AviSynthPlugins64Dir + "cplugin/yadif.dll")
        Yadif(clip, mode, order, planar, opt)
}