function ExInpaint(clip clip, clip "mask", int "color", int "dilate" ,int "xsize", int "ysize", int "radius", int "steps") 
{
LoadPlugin(AviSynthPlugins64Dir + "26/ExInpaint.dll")
        ExInpaint(clip, mask, color, dilate ,xsize, ysize, radius, steps)
}