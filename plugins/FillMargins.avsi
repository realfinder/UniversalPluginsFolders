function FillMargins(clip clip, int "left", int "top", int "right", int "bottom", int "y", int "u", int "v")
{
left=default(left,0)
top=default(top,0)
right=default(right,0)
bottom=default(bottom,0)
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/FillMargins.dll") : LoadPlugin(AviSynthPluginsDir + "26/FillBorders.dll")
        FillMargins(clip, left, top, right, bottom,y=y,u=u,v=v)
}


function FillBorders(clip clip, int "left", int "top", int "right", int "bottom", int "mode", int "y", int "u", int "v")
{
LoadPlugin(AviSynthPluginsDir + "26/FillBorders.dll")
        FillBorders(clip, left, top, right, bottom, mode, y, u, v)
}