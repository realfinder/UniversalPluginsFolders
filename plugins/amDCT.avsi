function amDCT(clip clip, clip "pf1", clip "bf1", int "quant", int "adapt", int "shift", int "matrix", int "qtype", int "sharpWPos", int "sharpWAmt", int "expand", int "sharpTPos", int "sharpTAmt", int "quality", int "brightStart", int "brightAmt", int "darkStart", int "darkAmt", int "showMask", int "T2", int "ncpu")
{
LoadPlugin(AviSynthPluginsDir + "25/amDCT.dll")
    amDCT(clip, pf1, bf1, quant, adapt, shift, matrix, qtype, sharpWPos, sharpWAmt, expand, sharpTPos, sharpTAmt, quality, brightStart, brightAmt, darkStart, darkAmt, showMask, T2, ncpu)
}