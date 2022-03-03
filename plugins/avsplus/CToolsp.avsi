function CDuplicate(clip clip, float "thr", int "nt", clip "dClip", bool "write")
{
LoadPlugin(AviSynthPluginsDir + "avsplus/CTools.dll")
    CDuplicate(clip, thr, nt, dClip, write)
}

function CFieldDuplicate(clip clip, float "thr", float "thr2", int "nt", clip "dClip", bool "write", bool "inputTxt")
{
LoadPlugin(AviSynthPluginsDir + "avsplus/CTools.dll")
    CFieldDuplicate(clip, thr, thr2, nt, dClip, write, inputTxt)
}

function CDropFrame(clip clip)
{
LoadPlugin(AviSynthPluginsDir + "avsplus/CTools.dll")
    CDropFrame(clip)
}

function CReplaceFrame(clip clip)
{
LoadPlugin(AviSynthPluginsDir + "avsplus/CTools.dll")
    CReplaceFrame(clip)
}

function CInterpolate(clip clip, float "thr", int "nt", clip "dClip", clip "iClip", bool "write", bool "inputTxt")
{
LoadPlugin(AviSynthPluginsDir + "avsplus/CTools.dll")
    CInterpolate(clip, thr, nt, dClip, iClip, write, inputTxt)
}

function CTelecine(clip clip, int "thr", int "thr2", int "blkthr", int "blksize", int "mode", int "metric", int "nt", bool "sse", clip "edeint", clip "edeint2", bool "write", bool "inputTxt", bool "match")
{
LoadPlugin(AviSynthPluginsDir + "avsplus/CTools.dll")
    CTelecine(clip, thr, thr2, blkthr, blksize, mode, metric, nt, sse, edeint, edeint2, write, inputTxt, match)
}

function CTelecine2(clip clip, int "thr", int "thr2", int "blkthr", int "blksize", int "mode", int "metric", int "nt", bool "sse", clip "edeint", clip "edeint2", bool "write", bool "inputTxt")
{
LoadPlugin(AviSynthPluginsDir + "avsplus/CTools.dll")
    CTelecine2(clip, thr, thr2, blkthr, blksize, mode, metric, nt, sse, edeint, edeint2, write, inputTxt)
}

function CFieldDeBlend(clip clip, float "thr", int "nt", clip "dClip", bool "prev", bool "bob")
{
LoadPlugin(AviSynthPluginsDir + "avsplus/CTools.dll")
    CFieldDeBlend(clip, thr, nt, dClip, prev, bob)
}

function CDecimate(clip clip, bool "CTelecine", bool "CDuplicate")
{
LoadPlugin(AviSynthPluginsDir + "avsplus/CTools.dll")
    CDecimate(clip, CTelecine, CDuplicate)
}

function CSceneChange(clip clip, bool "write")
{
LoadPlugin(AviSynthPluginsDir + "avsplus/CTools.dll")
    CSceneChange(clip, write)
}

function CDecimate2(clip clip)
{
LoadPlugin(AviSynthPluginsDir + "avsplus/CTools.dll")
    CDecimate2(clip)
}

function CSetPattern(clip clip, int "start", int "end", bool "CCCCC", bool "NNCCC", bool "CNNCC", bool "CCNNC", bool "CCCNN", bool "NCCCN")
{
LoadPlugin(AviSynthPluginsDir + "avsplus/CTools.dll")
    CSetPattern(clip, start, end, CCCCC, NNCCC, CNNCC, CCNNC, CCCNN, NCCCN)
}

function CGuessPattern(clip clip)
{
LoadPlugin(AviSynthPluginsDir + "avsplus/CTools.dll")
    CGuessPattern(clip)
}

function CFieldDifference(clip clip, int "mode", int "nt", bool "sse", bool "write", clip "dClip")
{
LoadPlugin(AviSynthPluginsDir + "avsplus/CTools.dll")
    CFieldDifference(clip, mode, nt, sse, write, dClip)
}

function CTelecineNew(clip clip, float "sstr", int "nt", int "ntN", bool "bob", bool "write", bool "inputTxt", float "thr60i", int "nt60i", int "mode", float "mode2thr", bool "sse")
{
LoadPlugin(AviSynthPluginsDir + "avsplus/CTools.dll")
    CTelecineNew(clip, sstr, nt, ntN, bob, write, inputTxt, thr60i, nt60i, mode, mode2thr, sse)
}

function CDecimateNew(clip clip, bool "isBob", bool "error", bool "heuristic", clip "iClip")
{
LoadPlugin(AviSynthPluginsDir + "avsplus/CTools.dll")
    CDecimateNew(clip, isBob, error, heuristic)
}

function CPostProcessing(clip clip, float "thr", float "thr2", float "sstr", int "ntC", int "ntM", bool "isBob", clip "edeint", clip "edeint2")
{
LoadPlugin(AviSynthPluginsDir + "avsplus/CTools.dll")
    CPostProcessing(clip, thr, thr2, sstr, ntC, ntM, isBob, edeint, edeint2)
}

function CSharpen(clip clip, clip blur, int "nt", int "mode")
{
LoadPlugin(AviSynthPluginsDir + "avsplus/CTools.dll")
    CSharpen(clip, blur, nt, mode)
}

function CDeHalo(clip clip, clip blur, int "nt", int "mode")
{
LoadPlugin(AviSynthPluginsDir + "avsplus/CTools.dll")
    CDeHalo(clip, blur, nt, mode)
}

function CDegrain(clip clip, int "radius", int "nt", int "thr", clip "dClip")
{
LoadPlugin(AviSynthPluginsDir + "avsplus/CTools.dll")
    CDegrain(clip, radius, nt, thr, dClip)
}

function CAntiAliasing(clip clip, int "nt", int "mode")
{
LoadPlugin(AviSynthPluginsDir + "avsplus/CTools.dll")
    CAntiAliasing(clip, nt, mode)
}