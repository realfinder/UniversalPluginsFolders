# NNEDI2resize function by LaTo INV.
#
# PARAMETERS:
# -----------
# ox = destination width
# oy = destination height
# nsize,qual,pscrn,cshift = nnedi2 parameters
#
# ABOUT RESOLUTION:
# -----------------
# if output > input : use nnedi2 resizer + "cshift" resizer
# if output = input : do nothing
# if output < input : use "cshift" resizer
#
# EXAMPLE:
# --------
# NNEDI2resize(1280,720)
# NNEDI2resize(1920,1080,qual=1,cshift="spline16resize")

function NNEDI2resize(clip clp, int ox, int oy, int "nsize", int "qual", bool "pscrn", string "cshift")
{
nsize  = default( nsize,  2                )
qual   = default( qual,   3                )
pscrn  = default( pscrn,  true             )
cshift = default( cshift, "spline36resize" )

ix = clp.width()
iy = clp.height()

rx = float(ox)/float(ix)
ry = float(oy)/float(iy)
rf = (rx > ry) ? rx : ry

clp = ( rf > 1.0 ) ? clp.nnedi2_rpow2(rfactor=ceil(rf/2.0)*2, nsize=nsize, qual=qual, pscrn=pscrn, cshift=cshift, fwidth=ox, fheight=oy)
\   : ( rf < 1.0 ) ? Eval( "clp." + cshift + "(" + string(ox) + "," + string(oy) + ")" )
\   :                clp

return clp
}