function DeCross(clip clip, int "ThresholdY", int "Noise", int "Margin", bool "Debug")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPluginsDir + "25/DeCross.dll") : LoadPlugin(AviSynthPluginsDir + "26/DeCross.dll")
        DeCross(clip, ThresholdY, Noise, Margin, Debug)
}