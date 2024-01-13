Function NNEDI3CL(clip input, int "field", bool "dh", bool "dw", int_array "planes", int "nsize", int "nns", int "qual", int "etype", int "pscrn", int "device", bool "list_device", bool "info", bool "st", bool "luma")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/NNEDI3CL.dll")
        NNEDI3CL(input, field, dh, dw, planes=planes, nsize=nsize, nns=nns, qual=qual, etype=etype, pscrn=pscrn, device=device, list_device=list_device, info=info, st=st, luma=luma)
}