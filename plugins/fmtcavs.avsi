Function fmtc_bitdepth(clip c, int "bits", bool "flt", val "planes", bool "fulls", bool "fulld", int "dmode", float "ampo", float "ampn", bool "dyn", bool "staticnoise", int "cpuopt", int "patsize", bool "tpdfo", bool "tpdfn", bool "corplane")
{
LoadPlugin(AviSynthPluginsDir + "avsplus/fmtcavs.dll")
        fmtc_bitdepth(c, bits, flt, planes, fulls, fulld, dmode, ampo, ampn, dyn, staticnoise, cpuopt, patsize, tpdfo, tpdfn, corplane)
}

Function fmtc_matrix(clip c, string "mat", string "mats", string "matd", bool "fulls", bool "fulld", val "coef", string "csp", string "col_fam", int "bits", int "singleout", int "cpuop")
{
LoadPlugin(AviSynthPluginsDir + "avsplus/fmtcavs.dll")
        fmtc_matrix(c, mat, mats, matd, fulls, fulld, coef, csp, col_fam, bits, singleout, cpuop)
}

Function fmtc_matrix2020cl(clip c, bool "full", string "csp", int "bits", int "cpuopt")
{
LoadPlugin(AviSynthPluginsDir + "avsplus/fmtcavs.dll")
        fmtc_matrix2020cl(c, full, csp, bits, cpuopt)
}

Function fmtc_primaries(clip c, val "rs", val "gs", val "bs", val "ws", val "rd", val "gd", val "bd", val "wd", string "prims", string "primd", int "cpuopt")
{
LoadPlugin(AviSynthPluginsDir + "avsplus/fmtcavs.dll")
        fmtc_primaries(c, rs, gs, bs, ws, rd, gd, bd, wd, prims, primd, cpuopt)
}

Function fmtc_resample(clip c, int "w", int "h", val "sx", val "sy", val "sw", val "sh", float "scale", float "scaleh", float "scalev", string "kernel", string "kernelh", string "kernelv", val "impulse", val "impulseh", val "impulsev", val "taps", val "tapsh", val "tapsv", val "a1", val "a2", val "a3", val "a1h", val "a2h", val "a3h", val "a1v", val "a2v", val "a3v", int "kovrspl", val "fh", val "fv", bool "cnorm", val "total", val "totalh", val "totalv", val "invks", val "invksh", val "invksv", val "invkstaps", val "invkstapsh", val "invkstapsv", string "csp", string "css", val "planes", int "fulls", int "fulld", val "center", string "cplace", string "cplaces", string "cplaced", int "interlaced", int "interlacedd", int "tff", int "tffd", bool "flt", int "cpuopt")
{
LoadPlugin(AviSynthPluginsDir + "avsplus/fmtcavs.dll")
        fmtc_resample(c, w, h, sx, sy, sw, sh, scale, scaleh, scalev, kernel, kernelh, kernelv, impulse, impulseh, impulsev, taps, tapsh, tapsv, a1, a2, a3, a1h, a2h, a3h, a1v, a2v, a3v, kovrspl, fh, fv, cnorm, total, totalh, totalv, invks, invksh, invksv, invkstaps, invkstapsh, invkstapsv, csp, css, planes, fulls, fulld, center, cplace, cplaces, cplaced, interlaced, interlacedd, tff, tffd, flt, cpuopt)
}

Function fmtc_transfer(clip c, string "transs", string "transd", float "cont", float "gcor", int "bits", bool "flt", bool "fulls", bool "fulld", int "logceis", int "logceid", int "cpuopt", float "blacklvl", val "planes")
{
LoadPlugin(AviSynthPluginsDir + "avsplus/fmtcavs.dll")
        fmtc_transfer(c, transs, transd, cont, gcor, bits, flt, fulls, fulld, logceis, logceid, cpuopt, blacklvl, planes)
}