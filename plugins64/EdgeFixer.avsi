function ContinuityFixer(clip clip, int "left", int "top", int "right", int "bottom", int "radius")
{
LoadPlugin(AviSynthPlugins64Dir + "26/EdgeFixer.dll")
        ContinuityFixer(clip, left, top, right, bottom, radius)
}

function ReferenceFixer(clip clip, clip ref, int "left", int "top", int "right", int "bottom", int "radius")
{
LoadPlugin(AviSynthPlugins64Dir + "26/EdgeFixer.dll")
        ReferenceFixer(clip, ref, left, top, right, bottom, radius)
}