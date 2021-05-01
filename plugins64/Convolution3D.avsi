function Convolution3D(clip clip, int "preset")
{
LoadPlugin(AviSynthPlugins64Dir + "26/Convolution3D.dll")
        Convolution3D(clip, preset)
}

function Convolution3D(clip clip, int "matrix", int "ythresh", int "cthresh", int "t_ythresh", int "t_cthresh", float "influence", int "debug")
{
LoadPlugin(AviSynthPlugins64Dir + "26/Convolution3D.dll")
        Convolution3D(clip, matrix, ythresh, cthresh, t_ythresh, t_cthresh, influence, debug)
}