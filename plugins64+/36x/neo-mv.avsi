Function neo_mv_Super(clip clip, int_array "blksize", int_array "overlap", int_array "pad", bool "onelevel", int "sharp", int "rfilter", int "pel", clip "pelclip", string "prefix")
{
    LoadPlugin(AviSynthPlugins64PDir + "36x/neo-mv.dll")
    neo_mv_Super(clip, blksize=blksize, overlap=overlap, pad=pad, onelevel=onelevel, sharp=sharp, rfilter=rfilter, pel=pel, pelclip=pelclip, prefix=prefix)
}


Function neo_mv_Analyse(clip super, int_array "blksize", int "levels", int "search", int "searchparam", int "pelsearch", int "mvlambda", bool "chroma", int "delta", int "lsad", int "plevel", bool "globalmv", int "pnew", int "pzero", int "pglobal", int_array "overlap", int "badsad", int "badrange", bool "meander", int "trymany", bool "fields", bool "tff", string "metric", string "prefix", float "metric_weight", float "metric_threshold", bool "satd")
{
    LoadPlugin(AviSynthPlugins64PDir + "36x/neo-mv.dll")
    neo_mv_Analyse(super, blksize=blksize, levels=levels, search=search, searchparam=searchparam, pelsearch=pelsearch, mvlambda=mvlambda, chroma=chroma, delta=delta, lsad=lsad, plevel=plevel, globalmv=globalmv, pnew=pnew, pzero=pzero, pglobal=pglobal, overlap=overlap, badsad=badsad, badrange=badrange, meander=meander, trymany=trymany, fields=fields, tff=tff, metric=metric, prefix=prefix, metric_weight=metric_weight, metric_threshold=metric_threshold, satd=satd)
}


Function neo_mv_AnalyseMany(clip super, int_array "blksize", int "levels", int "search", int "searchparam", int "pelsearch", int "mvlambda", bool "chroma", int "delta", int "lsad", int "plevel", bool "globalmv", int "pnew", int "pzero", int "pglobal", int_array "overlap", int "badsad", int "badrange", bool "meander", int "trymany", bool "fields", bool "tff", string "metric", int "radius", string "prefix", float "metric_weight", float "metric_threshold", bool "satd")
{
    LoadPlugin(AviSynthPlugins64PDir + "36x/neo-mv.dll")
    neo_mv_AnalyseMany(super, blksize=blksize, levels=levels, search=search, searchparam=searchparam, pelsearch=pelsearch, mvlambda=mvlambda, chroma=chroma, delta=delta, lsad=lsad, plevel=plevel, globalmv=globalmv, pnew=pnew, pzero=pzero, pglobal=pglobal, overlap=overlap, badsad=badsad, badrange=badrange, meander=meander, trymany=trymany, fields=fields, tff=tff, metric=metric, radius=radius, prefix=prefix, metric_weight=metric_weight, metric_threshold=metric_threshold, satd=satd)
}


Function neo_mv_Recalculate(clip super, clip_array "vectors", int "thsad", bool "smooth", int_array "blksize", int "search", int "searchparam", int "mvlambda", bool "chroma", int "pnew", int_array "overlap", bool "meander", bool "fields", bool "tff", string "metric", string "prefix", float "metric_weight", float "metric_threshold", bool "satd")
{
    LoadPlugin(AviSynthPlugins64PDir + "36x/neo-mv.dll")
    neo_mv_Recalculate(super, vectors=vectors, thsad=thsad, smooth=smooth, blksize=blksize, search=search, searchparam=searchparam, mvlambda=mvlambda, chroma=chroma, pnew=pnew, overlap=overlap, meander=meander, fields=fields, tff=tff, metric=metric, prefix=prefix, metric_weight=metric_weight, metric_threshold=metric_threshold, satd=satd)
}


Function neo_mv_SCDetection(clip clip, clip "vectors", int "thscd1", float "thscd2", string "prefix")
{
    LoadPlugin(AviSynthPlugins64PDir + "36x/neo-mv.dll")
    neo_mv_SCDetection(clip, vectors, thscd1, thscd2, prefix)
}


Function neo_mv_Compensate(clip clip, clip "super", clip "vectors", int "thsad", bool "fields", float "time", int "thscd1", float "thscd2", bool "tff", string "prefix")
{
    LoadPlugin(AviSynthPlugins64PDir + "36x/neo-mv.dll")
    neo_mv_Compensate(clip, super, vectors, thsad, fields, time, thscd1, thscd2, tff, prefix)
}


Function neo_mv_Degrain(clip clip, clip "super", clip_array "vectors", int_array "thsad", int_array "thsad2", int_array "planes", float_array "limit", int "thscd1", float "thscd2", int_array "weights", string "prefix")
{
    LoadPlugin(AviSynthPlugins64PDir + "36x/neo-mv.dll")
    neo_mv_Degrain(clip, super, vectors=vectors, thsad=thsad, thsad2=thsad2, planes=planes, limit=limit, thscd1=thscd1, thscd2=thscd2, weights=weights, prefix=prefix)
}


Function neo_mv_Degrain1(clip clip, clip "super", clip_array "vectors", int_array "thsad", int_array "thsad2", int_array "planes", float_array "limit", int "thscd1", float "thscd2", int_array "weights", string "prefix")
{
    LoadPlugin(AviSynthPlugins64PDir + "36x/neo-mv.dll")
    neo_mv_Degrain1(clip, super, vectors=vectors, thsad=thsad, thsad2=thsad2, planes=planes, limit=limit, thscd1=thscd1, thscd2=thscd2, weights=weights, prefix=prefix)
}


Function neo_mv_Degrain2(clip clip, clip "super", clip_array "vectors", int_array "thsad", int_array "thsad2", int_array "planes", float_array "limit", int "thscd1", float "thscd2", int_array "weights", string "prefix")
{
    LoadPlugin(AviSynthPlugins64PDir + "36x/neo-mv.dll")
    neo_mv_Degrain2(clip, super, vectors=vectors, thsad=thsad, thsad2=thsad2, planes=planes, limit=limit, thscd1=thscd1, thscd2=thscd2, weights=weights, prefix=prefix)
}


Function neo_mv_Degrain3(clip clip, clip "super", clip_array "vectors", int_array "thsad", int_array "thsad2", int_array "planes", float_array "limit", int "thscd1", float "thscd2", int_array "weights", string "prefix")
{
    LoadPlugin(AviSynthPlugins64PDir + "36x/neo-mv.dll")
    neo_mv_Degrain3(clip, super, vectors=vectors, thsad=thsad, thsad2=thsad2, planes=planes, limit=limit, thscd1=thscd1, thscd2=thscd2, weights=weights, prefix=prefix)
}


Function neo_mv_Degrain4(clip clip, clip "super", clip_array "vectors", int_array "thsad", int_array "thsad2", int_array "planes", float_array "limit", int "thscd1", float "thscd2", int_array "weights", string "prefix")
{
    LoadPlugin(AviSynthPlugins64PDir + "36x/neo-mv.dll")
    neo_mv_Degrain4(clip, super, vectors=vectors, thsad=thsad, thsad2=thsad2, planes=planes, limit=limit, thscd1=thscd1, thscd2=thscd2, weights=weights, prefix=prefix)
}


Function neo_mv_Degrain5(clip clip, clip "super", clip_array "vectors", int_array "thsad", int_array "thsad2", int_array "planes", float_array "limit", int "thscd1", float "thscd2", int_array "weights", string "prefix")
{
    LoadPlugin(AviSynthPlugins64PDir + "36x/neo-mv.dll")
    neo_mv_Degrain5(clip, super, vectors=vectors, thsad=thsad, thsad2=thsad2, planes=planes, limit=limit, thscd1=thscd1, thscd2=thscd2, weights=weights, prefix=prefix)
}


Function neo_mv_Degrain6(clip clip, clip "super", clip_array "vectors", int_array "thsad", int_array "thsad2", int_array "planes", float_array "limit", int "thscd1", float "thscd2", int_array "weights", string "prefix")
{
    LoadPlugin(AviSynthPlugins64PDir + "36x/neo-mv.dll")
    neo_mv_Degrain6(clip, super, vectors=vectors, thsad=thsad, thsad2=thsad2, planes=planes, limit=limit, thscd1=thscd1, thscd2=thscd2, weights=weights, prefix=prefix)
}


Function neo_mv_Degrain7(clip clip, clip "super", clip_array "vectors", int_array "thsad", int_array "thsad2", int_array "planes", float_array "limit", int "thscd1", float "thscd2", int_array "weights", string "prefix")
{
    LoadPlugin(AviSynthPlugins64PDir + "36x/neo-mv.dll")
    neo_mv_Degrain7(clip, super, vectors=vectors, thsad=thsad, thsad2=thsad2, planes=planes, limit=limit, thscd1=thscd1, thscd2=thscd2, weights=weights, prefix=prefix)
}


Function neo_mv_Degrain8(clip clip, clip "super", clip_array "vectors", int_array "thsad", int_array "thsad2", int_array "planes", float_array "limit", int "thscd1", float "thscd2", int_array "weights", string "prefix")
{
    LoadPlugin(AviSynthPlugins64PDir + "36x/neo-mv.dll")
    neo_mv_Degrain8(clip, super, vectors=vectors, thsad=thsad, thsad2=thsad2, planes=planes, limit=limit, thscd1=thscd1, thscd2=thscd2, weights=weights, prefix=prefix)
}


Function neo_mv_Degrain9(clip clip, clip "super", clip_array "vectors", int_array "thsad", int_array "thsad2", int_array "planes", float_array "limit", int "thscd1", float "thscd2", int_array "weights", string "prefix")
{
    LoadPlugin(AviSynthPlugins64PDir + "36x/neo-mv.dll")
    neo_mv_Degrain9(clip, super, vectors=vectors, thsad=thsad, thsad2=thsad2, planes=planes, limit=limit, thscd1=thscd1, thscd2=thscd2, weights=weights, prefix=prefix)
}


Function neo_mv_Degrain10(clip clip, clip "super", clip_array "vectors", int_array "thsad", int_array "thsad2", int_array "planes", float_array "limit", int "thscd1", float "thscd2", int_array "weights", string "prefix")
{
    LoadPlugin(AviSynthPlugins64PDir + "36x/neo-mv.dll")
    neo_mv_Degrain10(clip, super, vectors=vectors, thsad=thsad, thsad2=thsad2, planes=planes, limit=limit, thscd1=thscd1, thscd2=thscd2, weights=weights, prefix=prefix)
}


Function neo_mv_Degrain11(clip clip, clip "super", clip_array "vectors", int_array "thsad", int_array "thsad2", int_array "planes", float_array "limit", int "thscd1", float "thscd2", int_array "weights", string "prefix")
{
    LoadPlugin(AviSynthPlugins64PDir + "36x/neo-mv.dll")
    neo_mv_Degrain11(clip, super, vectors=vectors, thsad=thsad, thsad2=thsad2, planes=planes, limit=limit, thscd1=thscd1, thscd2=thscd2, weights=weights, prefix=prefix)
}


Function neo_mv_Degrain12(clip clip, clip "super", clip_array "vectors", int_array "thsad", int_array "thsad2", int_array "planes", float_array "limit", int "thscd1", float "thscd2", int_array "weights", string "prefix")
{
    LoadPlugin(AviSynthPlugins64PDir + "36x/neo-mv.dll")
    neo_mv_Degrain12(clip, super, vectors=vectors, thsad=thsad, thsad2=thsad2, planes=planes, limit=limit, thscd1=thscd1, thscd2=thscd2, weights=weights, prefix=prefix)
}


Function neo_mv_Degrain13(clip clip, clip "super", clip_array "vectors", int_array "thsad", int_array "thsad2", int_array "planes", float_array "limit", int "thscd1", float "thscd2", int_array "weights", string "prefix")
{
    LoadPlugin(AviSynthPlugins64PDir + "36x/neo-mv.dll")
    neo_mv_Degrain13(clip, super, vectors=vectors, thsad=thsad, thsad2=thsad2, planes=planes, limit=limit, thscd1=thscd1, thscd2=thscd2, weights=weights, prefix=prefix)
}


Function neo_mv_Degrain14(clip clip, clip "super", clip_array "vectors", int_array "thsad", int_array "thsad2", int_array "planes", float_array "limit", int "thscd1", float "thscd2", int_array "weights", string "prefix")
{
    LoadPlugin(AviSynthPlugins64PDir + "36x/neo-mv.dll")
    neo_mv_Degrain14(clip, super, vectors=vectors, thsad=thsad, thsad2=thsad2, planes=planes, limit=limit, thscd1=thscd1, thscd2=thscd2, weights=weights, prefix=prefix)
}


Function neo_mv_Degrain15(clip clip, clip "super", clip_array "vectors", int_array "thsad", int_array "thsad2", int_array "planes", float_array "limit", int "thscd1", float "thscd2", int_array "weights", string "prefix")
{
    LoadPlugin(AviSynthPlugins64PDir + "36x/neo-mv.dll")
    neo_mv_Degrain15(clip, super, vectors=vectors, thsad=thsad, thsad2=thsad2, planes=planes, limit=limit, thscd1=thscd1, thscd2=thscd2, weights=weights, prefix=prefix)
}


Function neo_mv_Degrain16(clip clip, clip "super", clip_array "vectors", int_array "thsad", int_array "thsad2", int_array "planes", float_array "limit", int "thscd1", float "thscd2", int_array "weights", string "prefix")
{
    LoadPlugin(AviSynthPlugins64PDir + "36x/neo-mv.dll")
    neo_mv_Degrain16(clip, super, vectors=vectors, thsad=thsad, thsad2=thsad2, planes=planes, limit=limit, thscd1=thscd1, thscd2=thscd2, weights=weights, prefix=prefix)
}


Function neo_mv_Degrain17(clip clip, clip "super", clip_array "vectors", int_array "thsad", int_array "thsad2", int_array "planes", float_array "limit", int "thscd1", float "thscd2", int_array "weights", string "prefix")
{
    LoadPlugin(AviSynthPlugins64PDir + "36x/neo-mv.dll")
    neo_mv_Degrain17(clip, super, vectors=vectors, thsad=thsad, thsad2=thsad2, planes=planes, limit=limit, thscd1=thscd1, thscd2=thscd2, weights=weights, prefix=prefix)
}


Function neo_mv_Degrain18(clip clip, clip "super", clip_array "vectors", int_array "thsad", int_array "thsad2", int_array "planes", float_array "limit", int "thscd1", float "thscd2", int_array "weights", string "prefix")
{
    LoadPlugin(AviSynthPlugins64PDir + "36x/neo-mv.dll")
    neo_mv_Degrain18(clip, super, vectors=vectors, thsad=thsad, thsad2=thsad2, planes=planes, limit=limit, thscd1=thscd1, thscd2=thscd2, weights=weights, prefix=prefix)
}


Function neo_mv_Degrain19(clip clip, clip "super", clip_array "vectors", int_array "thsad", int_array "thsad2", int_array "planes", float_array "limit", int "thscd1", float "thscd2", int_array "weights", string "prefix")
{
    LoadPlugin(AviSynthPlugins64PDir + "36x/neo-mv.dll")
    neo_mv_Degrain19(clip, super, vectors=vectors, thsad=thsad, thsad2=thsad2, planes=planes, limit=limit, thscd1=thscd1, thscd2=thscd2, weights=weights, prefix=prefix)
}


Function neo_mv_Degrain20(clip clip, clip "super", clip_array "vectors", int_array "thsad", int_array "thsad2", int_array "planes", float_array "limit", int "thscd1", float "thscd2", int_array "weights", string "prefix")
{
    LoadPlugin(AviSynthPlugins64PDir + "36x/neo-mv.dll")
    neo_mv_Degrain20(clip, super, vectors=vectors, thsad=thsad, thsad2=thsad2, planes=planes, limit=limit, thscd1=thscd1, thscd2=thscd2, weights=weights, prefix=prefix)
}


Function neo_mv_Degrain21(clip clip, clip "super", clip_array "vectors", int_array "thsad", int_array "thsad2", int_array "planes", float_array "limit", int "thscd1", float "thscd2", int_array "weights", string "prefix")
{
    LoadPlugin(AviSynthPlugins64PDir + "36x/neo-mv.dll")
    neo_mv_Degrain21(clip, super, vectors=vectors, thsad=thsad, thsad2=thsad2, planes=planes, limit=limit, thscd1=thscd1, thscd2=thscd2, weights=weights, prefix=prefix)
}


Function neo_mv_Degrain22(clip clip, clip "super", clip_array "vectors", int_array "thsad", int_array "thsad2", int_array "planes", float_array "limit", int "thscd1", float "thscd2", int_array "weights", string "prefix")
{
    LoadPlugin(AviSynthPlugins64PDir + "36x/neo-mv.dll")
    neo_mv_Degrain22(clip, super, vectors=vectors, thsad=thsad, thsad2=thsad2, planes=planes, limit=limit, thscd1=thscd1, thscd2=thscd2, weights=weights, prefix=prefix)
}


Function neo_mv_Degrain23(clip clip, clip "super", clip_array "vectors", int_array "thsad", int_array "thsad2", int_array "planes", float_array "limit", int "thscd1", float "thscd2", int_array "weights", string "prefix")
{
    LoadPlugin(AviSynthPlugins64PDir + "36x/neo-mv.dll")
    neo_mv_Degrain23(clip, super, vectors=vectors, thsad=thsad, thsad2=thsad2, planes=planes, limit=limit, thscd1=thscd1, thscd2=thscd2, weights=weights, prefix=prefix)
}


Function neo_mv_Degrain24(clip clip, clip "super", clip_array "vectors", int_array "thsad", int_array "thsad2", int_array "planes", float_array "limit", int "thscd1", float "thscd2", int_array "weights", string "prefix")
{
    LoadPlugin(AviSynthPlugins64PDir + "36x/neo-mv.dll")
    neo_mv_Degrain24(clip, super, vectors=vectors, thsad=thsad, thsad2=thsad2, planes=planes, limit=limit, thscd1=thscd1, thscd2=thscd2, weights=weights, prefix=prefix)
}


Function neo_mv_Degrain25(clip clip, clip "super", clip_array "vectors", int_array "thsad", int_array "thsad2", int_array "planes", float_array "limit", int "thscd1", float "thscd2", int_array "weights", string "prefix")
{
    LoadPlugin(AviSynthPlugins64PDir + "36x/neo-mv.dll")
    neo_mv_Degrain25(clip, super, vectors=vectors, thsad=thsad, thsad2=thsad2, planes=planes, limit=limit, thscd1=thscd1, thscd2=thscd2, weights=weights, prefix=prefix)
}


Function neo_mv_Flow(clip clip, clip "super", clip "vectors", float "time", bool "fields", int "thscd1", float "thscd2", bool "tff", string "prefix")
{
    LoadPlugin(AviSynthPlugins64PDir + "36x/neo-mv.dll")
    neo_mv_Flow(clip, super, vectors, time, fields, thscd1, thscd2, tff, prefix)
}


Function neo_mv_FlowInter(clip clip, clip "super", clip_array "vectors", float "time", float "ml", bool "blend", int "thscd1", float "thscd2", string "prefix")
{
    LoadPlugin(AviSynthPlugins64PDir + "36x/neo-mv.dll")
    neo_mv_FlowInter(clip, super, vectors=vectors, time=time, ml=ml, blend=blend, thscd1=thscd1, thscd2=thscd2, prefix=prefix)
}


Function neo_mv_FlowFPS(clip clip, clip "super", clip_array "vectors", int "num", int "den", bool "extramask", float "ml", bool "blend", int "thscd1", float "thscd2", string "prefix")
{
    LoadPlugin(AviSynthPlugins64PDir + "36x/neo-mv.dll")
    neo_mv_FlowFPS(clip, super, vectors=vectors, num=num, den=den, extramask=extramask, ml=ml, blend=blend, thscd1=thscd1, thscd2=thscd2, prefix=prefix)
}


Function neo_mv_FlowBlur(clip clip, clip "super", clip_array "vectors", float "blur", int "prec", int "thscd1", float "thscd2", string "prefix")
{
    LoadPlugin(AviSynthPlugins64PDir + "36x/neo-mv.dll")
    neo_mv_FlowBlur(clip, super, vectors=vectors, blur=blur, prec=prec, thscd1=thscd1, thscd2=thscd2, prefix=prefix)
}


Function neo_mv_VectorLengthMask(clip vectors, float "ml", float "gamma", float "time", float "scval", int "thscd1", float "thscd2", string "prefix")
{
    LoadPlugin(AviSynthPlugins64PDir + "36x/neo-mv.dll")
    neo_mv_VectorLengthMask(vectors, ml, gamma, time, scval, thscd1, thscd2, prefix)
}


Function neo_mv_SADMask(clip vectors, float "ml", float "gamma", float "time", float "scval", int "thscd1", float "thscd2", string "prefix")
{
    LoadPlugin(AviSynthPlugins64PDir + "36x/neo-mv.dll")
    neo_mv_SADMask(vectors, ml, gamma, time, scval, thscd1, thscd2, prefix)
}


Function neo_mv_OcclusionMask(clip vectors, float "ml", float "gamma", float "time", float "scval", int "thscd1", float "thscd2", string "prefix")
{
    LoadPlugin(AviSynthPlugins64PDir + "36x/neo-mv.dll")
    neo_mv_OcclusionMask(vectors, ml, gamma, time, scval, thscd1, thscd2, prefix)
}


Function neo_mv_DepanAnalyse(clip clip, clip "vectors", clip "mask", bool "zoom", bool "rot", float "pixaspect", float "error", bool "info", float "wrong", float "zerow", int "thscd1", float "thscd2", bool "fields", bool "tff")
{
    LoadPlugin(AviSynthPlugins64PDir + "36x/neo-mv.dll")
    neo_mv_DepanAnalyse(clip, vectors, mask, zoom, rot, pixaspect, error, info, wrong, zerow, thscd1, thscd2, fields, tff)
}


Function neo_mv_DepanCompensate(clip clip, clip "data", float "offset", int "subpixel", float "pixaspect", bool "matchfields", int "mirror", int "blur", bool "info", bool "fields", bool "tff")
{
    LoadPlugin(AviSynthPlugins64PDir + "36x/neo-mv.dll")
    neo_mv_DepanCompensate(clip, data, offset, subpixel, pixaspect, matchfields, mirror, blur, info, fields, tff)
}


Function neo_mv_DepanEstimate(clip clip, float "trust", int "winx", int "winy", int "wleft", int "wtop", int "dxmax", int "dymax", float "zoommax", float "stab", float "pixaspect", bool "info", bool "show", bool "fields", bool "tff")
{
    LoadPlugin(AviSynthPlugins64PDir + "36x/neo-mv.dll")
    neo_mv_DepanEstimate(clip, trust, winx, winy, wleft, wtop, dxmax, dymax, zoommax, stab, pixaspect, info, show, fields, tff)
}


Function neo_mv_DepanStabilise(clip clip, clip "data", float "cutoff", float "damping", float "initzoom", bool "addzoom", int "prev", int "next", int "mirror", int "blur", float "dxmax", float "dymax", float "zoommax", float "rotmax", int "subpixel", float "pixaspect", int "fitlast", float "tzoom", bool "info", int "method", bool "fields")
{
    LoadPlugin(AviSynthPlugins64PDir + "36x/neo-mv.dll")
    neo_mv_DepanStabilise(clip, data, cutoff, damping, initzoom, addzoom, prev, next, mirror, blur, dxmax, dymax, zoommax, rotmax, subpixel, pixaspect, fitlast, tzoom, info, method, fields)
}


Function neo_mv_KernelInfo()
{
    LoadPlugin(AviSynthPlugins64PDir + "36x/neo-mv.dll")
    neo_mv_KernelInfo()
}