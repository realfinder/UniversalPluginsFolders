function TFM(clip clip, int "order", int "field", int "mode", int "PP", string "ovr", string "input", string "output", string "outputC", bool "debug", bool "display", int "slow", bool "mChroma", int "cNum", int "cthresh", int "MI", bool "chroma", int "blockx", int "blocky", int "y0", int "y1", int "mthresh", Clip "clip2", string "d2v", int "ovrDefault", int "flags", float "scthresh", int "micout", int "micmatching", string "trimIn", bool "hint", int "metric", bool "batch", bool "ubsco", bool "mmsco", int "opt")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPlugins64Dir + "25/TIVTC.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/TIVTC.dll")
        TFM(clip, order, field, mode, PP, ovr, input, output, outputC, debug, display, slow, mChroma, cNum, cthresh, MI, chroma, blockx, blocky, y0, y1, mthresh, clip2, d2v, ovrDefault, flags, scthresh, micout, micmatching, trimIn, hint, metric, batch, ubsco, mmsco, opt)
}

function FieldDiff(clip clip, int "nt", bool "chroma", bool "display", bool "debug", bool "sse", int "opt")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPlugins64Dir + "25/TIVTC.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/TIVTC.dll")
        FieldDiff(clip, nt, chroma, display, debug, sse, opt)
}

function CFieldDiff(clip clip, int "nt", bool "chroma", bool "debug", bool "sse", int "opt")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPlugins64Dir + "25/TIVTC.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/TIVTC.dll")
        CFieldDiff(clip, nt, chroma, debug, sse, opt)
}

function FrameDiff(clip clip, int "mode", bool "prevf", int "nt", int "blockx", int "blocky", bool "chroma", float "thresh", int "display", bool "debug", bool "norm", bool "denoise", bool "ssd", int "opt")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPlugins64Dir + "25/TIVTC.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/TIVTC.dll")
        FrameDiff(clip, mode, prevf, nt, blockx, blocky, chroma, thresh, display, debug, norm, denoise, ssd, opt)
}

function CFrameDiff(clip clip, int "mode", bool "prevf", int "nt", int "blockx", int "blocky", bool "chroma", bool "debug", bool "norm", bool "denoise", bool "ssd", bool "rpos", int "opt")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPlugins64Dir + "25/TIVTC.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/TIVTC.dll")
        CFrameDiff(clip, mode, prevf, nt, blockx, blocky, chroma, debug, norm, denoise, ssd, rpos, opt)
}

function MergeHints(clip clip, clip "hintClip", bool "debug")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPlugins64Dir + "25/TIVTC.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/TIVTC.dll")
        MergeHints(clip, hintClip, debug)
}

function RequestLinear(clip clip, int "rlim", int "clim", int "elim", bool "rall", bool "debug")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPlugins64Dir + "25/TIVTC.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/TIVTC.dll")
        RequestLinear(clip, rlim, clim, elim, rall, debug)
}

function ShowCombedTIVTC(clip clip, int "cthresh", bool "chroma", int "MI", int "blockx", int "blocky", int "metric", bool "debug", int "display", bool "fill", int "opt")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPlugins64Dir + "25/TIVTC.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/TIVTC.dll")
        ShowCombedTIVTC(clip, cthresh, chroma, MI, blockx, blocky, metric, debug, display, fill, opt)
}

function IsCombedTIVTC(clip clip, int "cthresh", int "MI", bool "chroma", int "blockx", int "blocky", int "metric", int "opt")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPlugins64Dir + "25/TIVTC.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/TIVTC.dll")
        IsCombedTIVTC(clip, cthresh, MI, chroma, blockx, blocky, metric, opt)
}

function TDecimate(clip clip, int "mode", int "cycleR", int "cycle", float "rate", float "dupThresh", float "vidThresh", float "sceneThresh", int "hybrid", int "vidDetect", int "conCycle", int "conCycleTP", String "ovr", String "output", String "input", String "tfmIn", String "mkvOut", int "nt", int "blockx", int "blocky", bool "debug", bool "display", int "vfrDec", bool "batch", bool "tcfv1", bool "se", bool "chroma", bool "exPP", int "maxndl", bool "m2PA", bool "denoise", bool "noblend", bool "ssd", int "hint", Clip "clip2", int "sdlim", int "opt", String "orgOut")
{
VersionNumber() < 2.60 ? LoadPlugin(AviSynthPlugins64Dir + "25/TIVTC.dll") : LoadPlugin(AviSynthPlugins64Dir + "26/TIVTC.dll")
        TDecimate(clip, mode, cycleR, cycle, rate, dupThresh, vidThresh, sceneThresh, hybrid, vidDetect, conCycle, conCycleTP, ovr, output, input, tfmIn, mkvOut, nt, blockx, blocky, debug, display, vfrDec, batch, tcfv1, se, chroma, exPP, maxndl, m2PA, denoise, noblend, ssd, hint, clip2, sdlim, opt, orgOut)
}