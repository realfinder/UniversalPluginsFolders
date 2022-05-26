function sbr(clip input, int "y", int "u", int "v", int "opt")
{
LoadPlugin(AviSynthPluginsDir + "26/sbr.dll")
        sbr(input, y, u, v, opt)
}

function sbrV(clip input, int "y", int "u", int "v", int "opt")
{
LoadPlugin(AviSynthPluginsDir + "26/sbr.dll")
        sbrV(input, y, u, v, opt)
}