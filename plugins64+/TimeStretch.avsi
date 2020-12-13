function TimeStretch(clip clip, float "tempo", float "rate", float "pitch", int "sequence", int "seekwindow", int "overlap", bool "quickseek", int "aa")
{
LoadPlugin(AviSynthPlugins64PDir + "any/default/TimeStretch.dll")
        TimeStretch(clip, tempo, rate, pitch, sequence, seekwindow, overlap, quickseek, aa)
}