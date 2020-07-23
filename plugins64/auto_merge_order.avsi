# マージ順序の自動化
function auto_merge_order(clip a, clip b, int "nmax") {
nmax=default(nmax,5)
a=flexiblemerge(a, b, nmax=nmax)
b=flexiblemerge(b, a, nmax=nmax)
return conditionalfilter(interleave(a,b), a, b, \
"averagechromav(combcheck(selecteven))", "<", "averagechromav(combcheck(selectodd))")
}

# フレーム単位で画質評価・選択
function auto_frame_select_ex(clip a, clip b) {
return conditionalfilter(interleave(a,b), a, b, \
"averagechromav(combcheck(selecteven))", "<", "averagechromav(combcheck(selectodd))")
}