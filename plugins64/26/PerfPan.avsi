function PerfPan(clip c, clip "perforation", float "blank_threshold", int "reference_frame", int "max_search", string "log", bool "plot_scores", string "hintfile", bool "copy_on_limit")
{
LoadPlugin(AviSynthPlugins64Dir + "26/PerfPan.dll")
        PerfPan(c, perforation, blank_threshold, reference_frame, max_search, log, plot_scores, hintfile, copy_on_limit)
}