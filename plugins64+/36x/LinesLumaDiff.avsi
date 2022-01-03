Function LinesLumaDiff(clip clip, string "output", int "left", int "top", int "right", int "bottom", float "tl", float "tt", float "tr", float "tb")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/LinesLumaDiff.dll")
        LinesLumaDiff(clip, output, left, top, right, bottom, tl, tt, tr, tb)
}