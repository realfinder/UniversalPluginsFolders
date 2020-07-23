function nnedi2(clip clip, int "field", bool "dh", bool "Y", bool "U", bool "V", int "nsize", int "qual", bool "pscrn", int "threads", int "opt")
{
LoadPlugin(AviSynthPluginsDir + "25/nnedi2.dll")
        nnedi2(clip, field, dh, Y, U, V, nsize, qual, pscrn, threads, opt)
}

function nnedi2_rpow2(clip clip, int "rfactor", int "nsize", int "qual", bool "pscrn", string "cshift", int "fwidth", int "fheight", float "ep0", float "ep1", int "threads", int "opt")
{
LoadPlugin(AviSynthPluginsDir + "25/nnedi2.dll")
        nnedi2_rpow2(clip, rfactor, nsize, qual, pscrn, cshift, fwidth, fheight, ep0, ep1, threads, opt)
}