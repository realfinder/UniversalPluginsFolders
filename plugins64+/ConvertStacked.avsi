function ConvertToStacked(clip clip)
{
LoadPlugin(AviSynthPlugins64PDir + "any/default/ConvertStacked.dll")
        ConvertToStacked(clip)
}

function ConvertToDoubleWidth(clip clip)
{
LoadPlugin(AviSynthPlugins64PDir + "any/default/ConvertStacked.dll")
        ConvertToDoubleWidth(clip)
}

function ConvertFromStacked(clip clip, int "bits")
{
LoadPlugin(AviSynthPlugins64PDir + "any/default/ConvertStacked.dll")
        ConvertFromStacked(clip, bits)
}

function ConvertFromDoubleWidth(clip clip, int "bits")
{
LoadPlugin(AviSynthPlugins64PDir + "any/default/ConvertStacked.dll")
        ConvertFromDoubleWidth(clip, bits)
}