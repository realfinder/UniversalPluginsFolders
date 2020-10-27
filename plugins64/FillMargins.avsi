function FillMargins(clip clip, int "left", int "top", int "right", int "bottom", int "y", int "u", int "v")
{
LoadPlugin(AviSynthPlugins64Dir + "26/FillBorders.dll")
        FillMargins(clip, left, top, right, bottom,y=y,u=u,v=v)
}


function FillBorders(clip clip, int "left", int "top", int "right", int "bottom", int "mode", int "y", int "u", int "v")
{
LoadPlugin(AviSynthPlugins64Dir + "26/FillBorders.dll")
        FillBorders(clip, left, top, right, bottom, mode, y, u, v)
}