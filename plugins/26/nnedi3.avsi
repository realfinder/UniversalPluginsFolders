function nnedi3(clip clip, int "field", bool "dh", bool "Y", bool "U", bool "V", int "nsize", int "nns", int "qual", int "etype", int "pscrn", int "threads", int "opt", int "fapprox", bool "logicalCores", bool "MaxPhysCore", bool "SetAffinity", bool "A", bool "sleep", int "prefetch", int "range", int "ThreadLevel")
{
LoadPlugin(AviSynthPluginsDir + "26/nnedi3.dll")
        nnedi3(clip, field, dh, Y, U, V, nsize, nns, qual, etype, pscrn, threads, opt, fapprox, logicalCores, MaxPhysCore, SetAffinity, A, sleep, prefetch, range, ThreadLevel)
}

function nnedi3_rpow2(clip clip, int "rfactor", int "nsize", int "nns", int "qual", int "etype", int "pscrn", string "cshift", int "fwidth", int "fheight", float "ep0", float "ep1", int "threads", int "opt", int "fapprox", bool "csresize", bool "mpeg2", bool "logicalCores", bool "MaxPhysCore", bool "SetAffinity", int "threads_rs", bool "logicalCores_rs", bool "MaxPhysCore_rs", bool "SetAffinity_rs", bool "sleep", int "prefetch", int "range", int "ThreadLevel")
{
LoadPlugin(AviSynthPluginsDir + "26/nnedi3.dll")
        nnedi3_rpow2(clip, rfactor, nsize, nns, qual, etype, pscrn, cshift, fwidth, fheight, ep0, ep1, threads, opt, fapprox, csresize, mpeg2, logicalCores, MaxPhysCore, SetAffinity, threads_rs, logicalCores_rs, MaxPhysCore_rs, SetAffinity_rs, sleep, prefetch, range, ThreadLevel)
}