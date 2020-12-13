function ExInpaint(clip clip, clip "mask", int "color", int "dilate" ,int "xsize", int "ysize", int "radius", int "steps") 
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/ExInpaint.dll") : LoadPlugin(AviSynthPluginsDir + "26/ExInpaint.dll")
        ExInpaint(clip, mask, color, dilate, xsize, ysize, radius, steps)
}