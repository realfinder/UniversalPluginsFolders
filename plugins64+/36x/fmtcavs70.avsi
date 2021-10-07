Function fmtc_bitdepth(clip c, int "bits", bool "flt", string "planes", bool "fulls", bool "fulld", int "dmode", float "ampo", float "ampn", bool "dyn", bool "staticnoise", int "cpuopt", int "patsize", bool "tpdfo", bool "tpdfn", bool "corplane")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/fmtcavs.dll")
        fmtc_bitdepth(c, bits, flt, planes, fulls, fulld, dmode, ampo, ampn, dyn, staticnoise, cpuopt, patsize, tpdfo, tpdfn, corplane)
}

Function fmtc_matrix(clip c, string "mat", string "mats", string "matd", bool "fulls", bool "fulld", val_array "coef", string "csp", string "col_fam", int "bits", int "singleout", int "cpuop")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/fmtcavs.dll")
        fmtc_matrix(c, mat, mats, matd, fulls, fulld, coef=coef, csp=csp, col_fam=col_fam, bits=bits, singleout=singleout, cpuop=cpuop)
}

Function fmtc_matrix2020cl(clip c, bool "full", string "csp", int "bits", int "cpuopt")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/fmtcavs.dll")
        fmtc_matrix2020cl(c, full, csp, bits, cpuopt)
}

Function fmtc_primaries(clip c, val_array "rs", val_array "gs", val_array "bs", val_array "ws", val_array "rd", val_array "gd", val_array "bd", val_array "wd", string "prims", string "primd", int "cpuopt")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/fmtcavs.dll")
        fmtc_primaries(c, rs=rs, gs=gs, bs=bs, ws=ws, rd=rd, gd=gd, bd=bd, wd=wd, prims=prims, primd=primd, cpuopt=cpuopt)
}

Function fmtc_resample(clip c, int "w", int "h", val_array "sx", val_array "sy", val_array "sw", val_array "sh", float "scale", float "scaleh", float "scalev", string "kernel", string "kernelh", string "kernelv", val_array "impulse", val_array "impulseh", val_array "impulsev", val_array "taps", val_array "tapsh", val_array "tapsv", val_array "a1", val_array "a2", val_array "a3", val_array "a1h", val_array "a2h", val_array "a3h", val_array "a1v", val_array "a2v", val_array "a3v", int "kovrspl", val_array "fh", val_array "fv", bool "cnorm", val_array "total", val_array "totalh", val_array "totalv", val_array "invks", val_array "invksh", val_array "invksv", val_array "invkstaps", val_array "invkstapsh", val_array "invkstapsv", string "csp", string "css", val_array "planes", bool "fulls", bool "fulld", val "center", string "cplace", string "cplaces", string "cplaced", int "interlaced", int "interlacedd", int "tff", int "tffd", bool "flt", int "cpuopt")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/fmtcavs.dll")
        fmtc_resample(c, w, h, sx=sx, sy=sy, sw=sw, sh=sh, scale=scale, scaleh=scaleh, scalev=scalev, kernel=kernel, kernelh=kernelh, kernelv=kernelv, impulse=impulse, impulseh=impulseh, impulsev=impulsev, taps=taps, tapsh=tapsh, tapsv=tapsv, a1=a1, a2=a2, a3=a3, a1h=a1h, a2h=a2h, a3h=a3h, a1v=a1v, a2v=a2v, a3v=a3v, kovrspl=kovrspl, fh=fh, fv=fv, cnorm=cnorm, total=total, totalh=totalh, totalv=totalv, invks=invks, invksh=invksh, invksv=invksv, invkstaps=invkstaps, invkstapsh=invkstapsh, invkstapsv=invkstapsv, csp=csp, css=css, planes=planes, fulls=fulls, fulld=fulld, center=center, cplace=cplace, cplaces=cplaces, cplaced=cplaced, interlaced=interlaced, interlacedd=interlacedd, tff=tff, tffd=tffd, flt=flt, cpuopt=cpuopt)
}

Function fmtc_transfer(clip c, string "transs", string "transd", float "cont", float "gcor", int "bits", bool "flt", bool "fulls", bool "fulld", int "logceis", int "logceid", int "cpuopt", float "blacklvl", val "planes")
{
LoadPlugin(AviSynthPlugins64PDir + "36x/fmtcavs.dll")
        fmtc_transfer(c, transs, transd, cont, gcor, bits, flt, fulls, fulld, logceis, logceid, cpuopt, blacklvl, planes)
}