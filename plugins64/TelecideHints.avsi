function TelecideHints(clip clip1, clip clip2, clip "cleanclip", clip "unknownclip")
{
LoadPlugin(AviSynthPlugins64Dir + "25/TelecideHints.dll")
        TelecideHints(clip1, clip2, cleanclip, unknownclip)
}

function IsHinted(clip clip)
{
LoadPlugin(AviSynthPlugins64Dir + "25/TelecideHints.dll")
        IsHinted(clip)
}

function KillHints(clip clip)
{
LoadPlugin(AviSynthPlugins64Dir + "25/TelecideHints.dll")
        KillHints(clip)
}