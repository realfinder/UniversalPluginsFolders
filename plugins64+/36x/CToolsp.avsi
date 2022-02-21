function CDuplicate(clip clip, float "thr", int "nt", clip "dClip", bool "write")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/CTools.dll")
    CDuplicate(clip, thr, nt, dClip, write)
}

function CFieldDuplicate(clip clip, float "thr", float "thr2", int "nt", clip "dClip", bool "write", bool "inputTxt")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/CTools.dll")
    CFieldDuplicate(clip, thr, thr2, nt, dClip, write, inputTxt)
}

function CDropFrame(clip clip)
{
LoadPlugin(AviSynthPlugins64PDir + "36x/CTools.dll")
    CDropFrame(clip)
}

function CReplaceFrame(clip clip)
{
LoadPlugin(AviSynthPlugins64PDir + "36x/CTools.dll")
    CReplaceFrame(clip)
}

function CInterpolate(clip clip, float "thr", int "nt", clip "dClip", clip "iClip", bool "write", bool "inputTxt")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/CTools.dll")
    CInterpolate(clip, thr, nt, dClip, iClip, write, inputTxt)
}

function CTelecine(clip clip, int "thr", int "thr2", int "blkthr", int "blksize", int "mode", int "metric", int "nt", bool "sse", clip "edeint", clip "edeint2", bool "write", bool "inputTxt", bool "match")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/CTools.dll")
    CTelecine(clip, thr, thr2, blkthr, blksize, mode, metric, nt, sse, edeint, edeint2, write, inputTxt, match)
}

function CTelecine2(clip clip, int "thr", int "thr2", int "blkthr", int "blksize", int "mode", int "metric", int "nt", bool "sse", clip "edeint", clip "edeint2", bool "write", bool "inputTxt")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/CTools.dll")
    CTelecine2(clip, thr, thr2, blkthr, blksize, mode, metric, nt, sse, edeint, edeint2, write, inputTxt)
}

function CFieldDeBlend(clip clip, float "thr", int "nt", clip "dClip", bool "prev", bool "bob")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/CTools.dll")
    CFieldDeBlend(clip, thr, nt, dClip, prev, bob)
}

function CDecimate(clip clip, bool "CTelecine", bool "CDuplicate")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/CTools.dll")
    CDecimate(clip, CTelecine, CDuplicate)
}

function CSceneChange(clip clip, bool "write")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/CTools.dll")
    CSceneChange(clip, write)
}

function CDecimate2(clip clip)
{
LoadPlugin(AviSynthPlugins64PDir + "36x/CTools.dll")
    CDecimate2(clip)
}

function CSetPattern(clip clip, int "start", int "end", bool "CCCCC", bool "NNCCC", bool "CNNCC", bool "CCNNC", bool "CCCNN", bool "NCCCN")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/CTools.dll")
    CSetPattern(clip, start, end, CCCCC, NNCCC, CNNCC, CCNNC, CCCNN, NCCCN)
}

function CGuessPattern(clip clip)
{
LoadPlugin(AviSynthPlugins64PDir + "36x/CTools.dll")
    CGuessPattern(clip)
}

function CFieldDifference(clip clip, int "mode", int "nt", bool "sse", bool "write", clip "dClip")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/CTools.dll")
    CFieldDifference(clip, mode, nt, sse, write, dClip)
}

function CTelecineNew(clip clip, float "sstr", int "nt", bool "bob", bool "write", bool "inputTxt", float "thr60i", int "nt60i")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/CTools.dll")
    CTelecineNew(clip, sstr, nt, bob, write, inputTxt, thr60i, nt60i)
}

function CDecimateNew(clip clip, bool "isBob", bool "error", bool "heuristic")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/CTools.dll")
    CDecimateNew(clip, isBob, error, heuristic)
}

function CPostProcessing(clip clip, float "thr", float "thr2", float "sstr", int "ntC", int "ntM", bool "isBob", clip "edeint", clip "edeint2")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/CTools.dll")
    CPostProcessing(clip, thr, thr2, sstr, ntC, ntM, isBob, edeint, edeint2)
}