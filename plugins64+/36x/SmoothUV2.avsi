function SmoothUV2(clip clip, int "radius", int "threshold", int "interlaced", int "opt", int "dither")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/SmoothUV2.dll")
        SmoothUV2(clip, radius, threshold, interlaced, opt, dither)
}


function SSHiQ2(clip clip, int "rY", int "rC", int "tY", int "tC", int "strY", int "strC", bool "HQY", bool "HQC", int "interlaced", int "opt", int "dither")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/SmoothUV2.dll")
        SSHiQ2(clip, rY, rC, tY, tC, strY, strC, HQY, HQC, interlaced, opt, dither)
}