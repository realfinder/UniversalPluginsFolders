function DotKillS(clip input, int "iterations")
{
LoadPlugin(AviSynthPluginsDir + "26/DotKill.dll")
        DotKillS(input, iterations)
}

function DotKillZ(clip input, int "order", int "offset")
{
LoadPlugin(AviSynthPluginsDir + "26/DotKill.dll")
        DotKillZ(input, order, offset)
}

function DotKillT(clip input, int "order", int "offset", int "dupthresh", int "tratio", bool "show")
{
LoadPlugin(AviSynthPluginsDir + "26/DotKill.dll")
        DotKillT(input, order, offset, dupthresh, tratio, show)
}