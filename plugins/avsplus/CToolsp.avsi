function CDuplicate(clip clip, float "thr", float "thr2", int "nt", bool "fields", clip "dClip", bool "write")
{
LoadPlugin(AviSynthPluginsDir + "avsplus/CTools.dll")
    CDuplicate(clip, thr, thr2, nt, fields, dClip, write)
}

function CReplaceDuplicate(clip clip, bool "drop")
{
LoadPlugin(AviSynthPluginsDir + "avsplus/CTools.dll")
    CReplaceDuplicate(clip, drop)
}

function CInterpolateDuplicate(clip clip, float "thr", int "nt", clip "dClip", clip "iClip")
{
LoadPlugin(AviSynthPluginsDir + "avsplus/CTools.dll")
    CInterpolateDuplicate(clip, thr, nt, dClip, iClip)
}

function CFieldDeBlend(clip clip, float "thr", float "thr2", int "nt", int "thrC", int "blksize", int "blkthr", float "sstr", clip "dClip")
{
LoadPlugin(AviSynthPluginsDir + "avsplus/CTools.dll")
    CFieldDeBlend(clip, thr, thr2, nt, thrC, blksize, blkthr, sstr, dClip)
}

function CSceneChange(clip clip, clip "sClip", int "blksize", int "thSCD1", int "thSCD2", int "minKey", int "maxLuma", bool "write", bool "inputTxt")
{
LoadPlugin(AviSynthPluginsDir + "avsplus/CTools.dll")
    CSceneChange(clip, sClip, blksize, thSCD1, thSCD2, minKey, maxLuma, write, inputTxt)
}

function CSetPattern(clip clip, int "start", int "end", bool "CCCCC", bool "NNCCC", bool "CNNCC", bool "CCNNC", bool "CCCNN", bool "NCCCN")
{
LoadPlugin(AviSynthPluginsDir + "avsplus/CTools.dll")
    CSetPattern(clip, start, end, CCCCC, NNCCC, CNNCC, CCNNC, CCCNN, NCCCN)
}

function CTelecine(clip clip, bool "bob", int "mode", int "nt", int "ntN", bool "sse", float "thr60i", int "nt60i", float "sstr", float "mode2thr", clip "dClip", bool "write", bool "inputTxt")
{
LoadPlugin(AviSynthPluginsDir + "avsplus/CTools.dll")
    CTelecine(clip, bob, mode, nt, ntN, sse, thr60i, nt60i, sstr, mode2thr, dClip, write, inputTxt)
}

function CDecimate(clip clip, bool "isBob", bool "error", bool "heuristic", clip "iClip")
{
LoadPlugin(AviSynthPluginsDir + "avsplus/CTools.dll")
    CDecimate(clip, isBob, error, heuristic)
}

function CPostProcessing(clip clip, int "thr", int "thr2", int "mode", int "blksize", int "blkthr", bool "isBob", float "sstr", int "nt", int "ntMask", clip "edeint", clip "edeint2", clip "dClip")
{
LoadPlugin(AviSynthPluginsDir + "avsplus/CTools.dll")
    CPostProcessing(clip, thr, thr2, mode, blksize, blkthr, isBob, sstr, nt, ntMask, edeint, edeint2, dClip)
}

function CSharpen(clip clip, clip blur, int "nt", int "mode", bool "Y", bool "U", bool "V")
{
LoadPlugin(AviSynthPluginsDir + "avsplus/CTools.dll")
    CSharpen(clip, blur, nt, mode, Y, U, V)
}

function CDeHalo(clip clip, clip blur, int "nt", int "mode", bool "Y", bool "U", bool "V")
{
LoadPlugin(AviSynthPluginsDir + "avsplus/CTools.dll")
    CDeHalo(clip, blur, nt, mode, Y, U, V)
}

function CDegrain(clip clip, int "radius", int "nt", int "thr", int "blksize", clip "dClip")
{
LoadPlugin(AviSynthPluginsDir + "avsplus/CTools.dll")
    CDegrain(clip, radius, nt, thr, blksize, dClip)
}

function CAntiAliasing(clip clip, int "nt", int "mode", bool "Y", bool "U", bool "V")
{
LoadPlugin(AviSynthPluginsDir + "avsplus/CTools.dll")
    CAntiAliasing(clip, nt, mode, Y, U, V)
}

function CTemporalSoften(clip clip, int "radius", bool "isb", bool "Y", bool "U", bool "V")
{
LoadPlugin(AviSynthPluginsDir + "avsplus/CTools.dll")
    CTemporalSoften(clip, radius, isb, Y, U, V)
}