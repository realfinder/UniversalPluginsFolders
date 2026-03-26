Function FillBorders (clip clip, int_array "left", int_array "top", int_array "right", int_array "bottom", int "mode", int "y", int "u", int "v", int "a", bool "interlaced", int "ts", int "ts_mode", array "fade_value")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/FillBorders.dll")
        FillBorders (clip, left=left, top=top, right=right, bottom=bottom, mode=mode, y=y, u=u, v=v, a=a, interlaced=interlaced, ts=ts, ts_mode=ts_mode, fade_value=fade_value)
}


function FillMargins(clip clip, int "left", int "top", int "right", int "bottom", int "y", int "u", int "v")
{
LoadPlugin(AviSynthPlugins64Dir + "36x/FillBorders.dll")
        FillMargins(clip, left, top, right, bottom,y=y,u=u,v=v)
}