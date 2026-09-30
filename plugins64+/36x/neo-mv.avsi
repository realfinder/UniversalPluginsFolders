Function neo_mv_MSuper(clip clip, int_array "blksize", int_array "overlap", int_array "pad", bool "onelevel", int "sharp", int "rfilter", int "pel", clip "pelclip", string "prefix")
{
    LoadPlugin(AviSynthPlugins64PDir + "36x/neo-mv.dll")
    neo_mv_MSuper(clip, blksize=blksize, overlap=overlap, pad=pad, onelevel=onelevel, sharp=sharp, rfilter=rfilter, pel=pel, pelclip=pelclip, prefix=prefix)
}


Function neo_mv_MAnalyse(clip super, int_array "blksize", int "levels", int "search", int "searchparam", int "pelsearch", int "mvlambda", bool "chroma", int "delta", int "lsad", int "plevel", bool "globalmv", int "pnew", int "pzero", int "pglobal", int_array "overlap", int "badsad", int "badrange", bool "meander", int "trymany", bool "fields", bool "tff", string "metric", string "prefix", float "metric_weight", float "metric_threshold")
{
    LoadPlugin(AviSynthPlugins64PDir + "36x/neo-mv.dll")
    neo_mv_MAnalyse(super, blksize=blksize, levels=levels, search=search, searchparam=searchparam, pelsearch=pelsearch, mvlambda=mvlambda, chroma=chroma, delta=delta, lsad=lsad, plevel=plevel, globalmv=globalmv, pnew=pnew, pzero=pzero, pglobal=pglobal, overlap=overlap, badsad=badsad, badrange=badrange, meander=meander, trymany=trymany, fields=fields, tff=tff, metric=metric, prefix=prefix, metric_weight=metric_weight, metric_threshold=metric_threshold)
}


Function neo_mv_MRecalculate(clip super, clip_array "vectors", int "thsad", bool "smooth", int_array "blksize", int "search", int "searchparam", int "mvlambda", bool "chroma", int "pnew", int_array "overlap", bool "meander", bool "fields", bool "tff", string "metric", string "prefix", float "metric_weight", float "metric_threshold")
{
    LoadPlugin(AviSynthPlugins64PDir + "36x/neo-mv.dll")
    neo_mv_MRecalculate(super, vectors=vectors, thsad=thsad, smooth=smooth, blksize=blksize, search=search, searchparam=searchparam, mvlambda=mvlambda, chroma=chroma, pnew=pnew, overlap=overlap, meander=meander, fields=fields, tff=tff, metric=metric, prefix=prefix, metric_weight=metric_weight, metric_threshold=metric_threshold)
}


Function neo_mv_MSCDetection(clip clip, clip "vectors", int "thscd1", float "thscd2", string "prefix")
{
    LoadPlugin(AviSynthPlugins64PDir + "36x/neo-mv.dll")
    neo_mv_MSCDetection(clip, vectors, thscd1, thscd2, prefix)
}


Function neo_mv_MCompensate(clip clip, clip "super", clip "vectors", int "thsad", bool "fields", float "time", int "thscd1", float "thscd2", bool "tff", string "prefix")
{
    LoadPlugin(AviSynthPlugins64PDir + "36x/neo-mv.dll")
    neo_mv_MCompensate(clip, super, vectors, thsad, fields, time, thscd1, thscd2, tff, prefix)
}


Function neo_mv_MDegrain(clip clip, clip "super", clip_array "vectors", int_array "thsad", int_array "thsad2", int_array "planes", float_array "limit", int "thscd1", float "thscd2", int_array "weights", string "prefix")
{
    LoadPlugin(AviSynthPlugins64PDir + "36x/neo-mv.dll")
    neo_mv_MDegrain(clip, super, vectors=vectors, thsad=thsad, thsad2=thsad2, planes=planes, limit=limit, thscd1=thscd1, thscd2=thscd2, weights=weights, prefix=prefix)
}


Function neo_mv_MFlow(clip clip, clip "super", clip "vectors", float "time", bool "fields", int "thscd1", float "thscd2", bool "tff", string "prefix")
{
    LoadPlugin(AviSynthPlugins64PDir + "36x/neo-mv.dll")
    neo_mv_MFlow(clip, super, vectors, time, fields, thscd1, thscd2, tff, prefix)
}


Function neo_mv_MFlowInter(clip clip, clip "super", clip_array "vectors", float "time", float "ml", bool "blend", int "thscd1", float "thscd2", string "prefix")
{
    LoadPlugin(AviSynthPlugins64PDir + "36x/neo-mv.dll")
    neo_mv_MFlowInter(clip, super, vectors=vectors, time=time, ml=ml, blend=blend, thscd1=thscd1, thscd2=thscd2, prefix=prefix)
}


Function neo_mv_MFlowFPS(clip clip, clip "super", clip_array "vectors", int "num", int "den", bool "extramask", float "ml", bool "blend", int "thscd1", float "thscd2", string "prefix")
{
    LoadPlugin(AviSynthPlugins64PDir + "36x/neo-mv.dll")
    neo_mv_MFlowFPS(clip, super, vectors=vectors, num=num, den=den, extramask=extramask, ml=ml, blend=blend, thscd1=thscd1, thscd2=thscd2, prefix=prefix)
}


Function neo_mv_MFlowBlur(clip clip, clip "super", clip_array "vectors", float "blur", int "prec", int "thscd1", float "thscd2", string "prefix")
{
    LoadPlugin(AviSynthPlugins64PDir + "36x/neo-mv.dll")
    neo_mv_MFlowBlur(clip, super, vectors=vectors, blur=blur, prec=prec, thscd1=thscd1, thscd2=thscd2, prefix=prefix)
}


Function neo_mv_MMask(clip vectors, float "ml", float "gamma", float "time", float "scval", int "thscd1", float "thscd2", string "prefix")
{
    LoadPlugin(AviSynthPlugins64PDir + "36x/neo-mv.dll")
    neo_mv_MMask(vectors, ml, gamma, time, scval, thscd1, thscd2, prefix)
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