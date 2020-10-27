function ExInpaint(clip clip, clip "mask", int "color", int "dilate" ,int "xsize", int "ysize", int "radius", int "steps") 
{
LoadPlugin(AviSynthPluginsDir + "25/ExInpaint.dll")
        ExInpaint(clip, mask, color, dilate ,xsize, ysize, radius, steps)
}