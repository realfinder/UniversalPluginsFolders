function TUnsharp(clip clip, int "strength", int "thresholdL", int "thresholdU", int "type", int "map", int "lim", int "radius", bool "gui")
{
LoadPlugin(AviSynthPluginsDir + "25/TUnsharp.dll")
        TUnsharp(clip, strength, thresholdL, thresholdU, type, map, lim, radius, gui)
}