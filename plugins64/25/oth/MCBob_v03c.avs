# MCBob v0.3: 
#
# Another approach to motion compensated bobbing, build by Didée.
#
#   ( Between-all-chairs version with some quick hacks )
#   ( v0.3c: as stated above, but worse ;-) )
#
# Features:
#
# - No residual combing, due to STT (Shape Transposition Technology)
# - Works without thresholds (with adaptive thresholds instead of fixed ones)
# - Motion Search between fields of same parity, for maximum flicker/bob reduction in motion areas
# - Motion Masking adaptive to local complexity, for maximum flicker/bob reduction in static areas
# - spatial Interpolation overweights spatio-temporal interpolation
#     ( in areas where the information obtained from temporal neighbors in itself was only spatially 
#       interpolated, use a mix of spatial and spatio-temporal interpolation )
# - error correction for temporal interpolation is fully self adaptive
#
# Prerequisites:
#
# - MVTools, preferably v1.4.13 (or newer)
# - MaskTools v2.0
# - EEDI2
# - RemoveGrain/Repair package
# - ReduceFlicker (if temp-NR for ME is used)
# - MedianBlur by tsp

function MCBob(clip clp, float "EdiPre", int "EdiPost", int "blocksize", int "MEdepth", float "sharpness", int "mtnmode", float "mtnth1", float "mtnth2", float "errth1", float "errth2", float "MEspatNR", float "MEtempNR")
{
    EdiPre    = default( EdiPre,    1.0 )  #  What bob to start with: 0.0 = dumbbob, 1.0 = EEdiBob, inbetween = mix of both
    EdiPost   = default( EdiPost,     1 )  #  0 = no EEDI PP / 1 = Framesized EEdi PP / Average two Fieldbased EEdi PP's
    bs        = default( blocksize,  16 )  #  Blocksize for motion search
    me        = default( MEdepth,     2 )  #  Search effort of motion search
    sharpness = (EdiPost==2)
     \        ? default( sharpness, 0.7 )  
     \        : default( sharpness, 1.0 )  #  use slight sharpening before STT routine
    
    mtnmode   = default( mtnmode,     0 )  #  0 = use only same-parity motion check, 1|2 use an additional 
                                           #  inter-parity check: 1 = on vertical edges / 2 = not on horizontal edges
    mtnth1    = default( mtnth1,   0.20 )  #  below this %age of local min/max is static
    mtnth2    = default( mtnth2,   0.40 )  #  above this %age of local min/max is motion
    errth1    = default( errth1,   0.40 )  #  similar for error detection
    errth2    = default( errth2,   0.60 )  #  of motion interpolation errors
    MEspatNR  = default( MEspatNR, 0.00 )  #  amount of spatial NR (for motion search only)
    MEtempNR  = default( MEtempNR, 0.00 )  #  amount of temporal NR (for motion search only)

    order = (clp.GetParity == True) ? 0 : 1
    ORDR  = (order==0) ? "TFF" : "BFF"

    ox    = clp.width()
    oy    = clp.height()
    ERTH1 = string(errth1)
    ERTH2 = string(errth2)
    MNTH1 = string(mtnth1)
    MNTH2 = string(mtnth2)
    SSTR  = string(sharpness)
    idx_1 = 10
    idx_2 = (MEspatNR==0.0 && MEtempNR==0.0) ? idx_1 : idx_1+2
    idx_3 = idx_2 + 2


# Create basic operations that we will work with
# ==============================================

# Basic Field & Bob clips
# -----------------------
    flatbob   = clp.Bob(1,0)
    normbob   = clp.Bob(0.0,0.5) 
    ofields   = clp.SeparateFields()
    oweave    = clp.DoubleWeave()
    edibobbed = clp.EEDIbob()
    bobbed    = (EdiPre == 0.0) ? normbob
     \        : (EdiPre == 1.0) ? edibobbed
     \        :                   normbob.merge(edibobbed,EdiPre)


# Mask to check if motion compensation has delivered only the neighbor's spatial interpolated part
# ------------------------------------------------------------------------------------------------
    black    = Blankclip(ofields).mt_lut("0").Trim(1,1).Loop(Framecount(clp))
    white    = Blankclip(ofields).mt_lut("255").Trim(1,1).Loop(Framecount(clp))
    interpol = Interleave(black,white,white,black).AssumeFieldbased().AssumeParity(ORDR).Weave()


# Vertical Edge mask, needed for more safe motion masking
# -------------------------------------------------------
    Vedge  = bobbed.mt_Edge("1 0 -1 2 0 -2 1 0 -1",0,255,0,255,U=1,V=1)
    Vedge2 = Vedge.mt_Inpand(mode="vertical").mt_Inpand(mode="vertical").mt_Expand(mode="vertical").mt_Expand(mode="vertical")
    Vedge  = mt_Lutxy(Vedge,Vedge2,yexpr="y 2 - 2 * x > x y 2 - 2 * ?") #.mt_Expand()

    Hedge  = bobbed.mt_Edge("1 2 1 0 0 0 -1 -2 -1",0,255,0,255,U=1,V=1)
    Hedge = Hedge.mt_logic(Hedge.temporalsoften(1,255,0,255,2),"max")


# If requested, do flicker reduction before searching motion vectors
# -------------------------------------------------------------------
    (MEspatNR==0.0) ? bobbed : bobbed.Merge(bobbed.minblur(2,uv=3),MEspatNR)
    (MEtempNR==0.0) ? last : last.Merge(reduceflicker(2),MEtempNR)
    srch=last


# Perform Motion Search
# ---------------------
    lmbda = 128
    pnw   =  40
    bw_vec2 = srch.SelectEven().MVAnalyse(isb=true, truemotion=false,delta=1,lambda=lmbda,pel=2,searchparam=me,sharp=2,blksize=bs,overlap=1*bs/2,pnew=pnw,idx=idx_1)
    fw_vec2 = srch.SelectEven().MVAnalyse(isb=false,truemotion=false,delta=1,lambda=lmbda,pel=2,searchparam=me,sharp=2,blksize=bs,overlap=1*bs/2,pnew=pnw,idx=idx_1)
    bw_vec3 = srch.SelectOdd() .MVAnalyse(isb=true, truemotion=false,delta=1,lambda=lmbda,pel=2,searchparam=me,sharp=2,blksize=bs,overlap=1*bs/2,pnew=pnw,idx=idx_1+1)
    fw_vec3 = srch.SelectOdd() .MVAnalyse(isb=false,truemotion=false,delta=1,lambda=lmbda,pel=2,searchparam=me,sharp=2,blksize=bs,overlap=1*bs/2,pnew=pnw,idx=idx_1+1)


# Create RAW motion interpolation
# -------------------------------
    alt_1   = bobbed.SelectEven().MVFlowInter(bw_vec2,fw_vec2,time=50.0,thSCD1=64*18,thSCD2=227,idx=idx_2)
    alt_2   = bobbed.SelectOdd() .MVFlowInter(bw_vec3,fw_vec3,time=50.0,thSCD1=64*18,thSCD2=227,idx=idx_2+1).DuplicateFrame(0)
    alt     = Interleave(alt_2,alt_1)


# Create motion interpolation of "nothing new" mask
# -------------------------------------------------
    interpol_1   = interpol.SelectEven().MVFlowInter(bw_vec2,fw_vec2,time=50.0,thSCD1=64*8,thSCD2=127,idx=idx_3)
    interpol_2   = interpol.SelectOdd() .MVFlowInter(bw_vec3,fw_vec3,time=50.0,thSCD1=64*8,thSCD2=127,idx=idx_3+1).DuplicateFrame(0)
    interpol_comp= Interleave(interpol_2,interpol_1)
    nothing_new  = mt_lutxy(interpol,interpol_comp,"x y * 255 / 255 / 1 2 / ^ 160 *")


# Error check of motion interpolation
# ===================================
# Errors that are neutralized by errors in direct vertical neighborhood are not considered, because bob-typical.
# Remaining error is checked against [min,max] of local error to decide if it's valid or not.
#
# Build error mask, neutralize vertical-only errors
# ---------------------------------------------------
    altD     = mt_Makediff(bobbed,alt,U=3,V=3)
    altDmin  = altD.mt_Inpand(mode="vertical",U=3,V=3)
    altDmin  = altDmin.mt_Deflate().mt_Merge(altDmin,Vedge,U=4,V=4)
    altDmax  = altD.mt_Expand(mode="vertical",U=3,V=3)
    altDmax  = altDmax.mt_Inflate().mt_Merge(altDmax,Vedge,U=4,V=4)
    altDmm   = mt_Lutxy(altDmax.mt_Expand(mode="horizontal",U=3,V=3),altDmin.mt_Inpand(mode="horizontal",U=3,V=3),"x y -",U=3,V=3)
    altDmm   = altDmm.mt_Inflate().mt_Merge(altDmm,Vedge,U=4,V=4)
    altD1    = altD .mt_Lutxy(altDmin,"x 128 - y 128 - * 0 < 128 x 128 - abs y 128 - abs < x y ? ?",U=3,V=3)
    altD1    = altD1.mt_Lutxy(altDmax,"x 128 - y 128 - * 0 < 128 x 128 - abs y 128 - abs < x y ? ?",U=3,V=3)
    altD2    = altD.Repair(altD1,1)


# Build correction mask by combining:  error mask  +  "nothing new" mask  +  a scenechange mask
# ---------------------------------------------------------------------------------------------
    corrmask = mt_Lutxy(altD2,altDmm,"x 128 - abs 2 - y 2 + / "+ERTH1+" - "+ERTH2+" "+ERTH1+" - / 255 *",U=3,V=3).mt_Expand(U=3,V=3)
    sc       = corrmask.BilinearResize(64,64)
    sc       = mt_LutF(sc,sc,mode="average",expr="x 255 0.6 * > 255 0 ?").PointResize(ox,oy)
    corrmask = corrmask.mt_Logic(nothing_new,"max",U=2,V=2)
    corrmask = corrmask.mt_Logic(sc,"max",U=2,V=2)


# Create a first bob from motion interpolation, not yet error corrected ...
# -------------------------------------------------------------------------
# ***( temporarily changed ... yet unsure what works best )***

    Interleave(bobbed,alt).AssumeParity(ORDR)
    SeparateFields().SelectEvery(8,0,3,5,6).Weave()
    naked= last
    naked2 = last.vinverse(1.6) # flatbob # 
    
    naked_mm = naked.mt_Edge("min/max",0,255,0,255,U=1,V=1)
    edibb_mm = edibobbed.mt_Edge("min/max",0,255,0,255,U=1,V=1).mt_Expand(mode="vertical")
    check2   = mt_LutXY(naked_mm,edibb_mm,"x y / 3 - 5 3 - / 255 *")
    corrmask = corrmask.mt_Logic(check2,"max",U=2,V=2)


# ... and build a motion mask from this one.
# ------------------------------------------
# ***( temporarily changed ... tickertapes might suffer. )***

    stc = bobbed .removegrain(2)# oweave.removegrain(11)
    mm         = stc.mt_Edge("min/max",0,255,0,255,U=3,V=3)
   #  mm = mm .mt_Logic(mm.DuplicateFrame(0),"max",U=3,V=3).mt_Logic(mm.DeleteFrame(0),"max",U=3,V=3)
    #  max = stc.mt_expand(U=3,V=3)
    #  max = max.mt_logic(max.Duplicateframe(0),"max",U=3,V=3).mt_logic(max.Duplicateframe(0).Duplicateframe(0),"max",U=3,V=3)
    #  min = stc.mt_inpand(U=3,V=3)
    #  min = min.mt_logic(min.Duplicateframe(0),"min",U=3,V=3).mt_logic(min.Duplicateframe(0).Duplicateframe(0),"min",U=3,V=3)
    #  mm = mt_LutXY(max,min,"x y -",U=3,V=3)
    diff2prev1 = mt_LutXY(stc,stc.DuplicateFrame(0),"x y - abs",U=3,V=3)
    diff2prev2 = mt_LutXY(stc,stc.DuplicateFrame(0).DuplicateFrame(0),"x y - abs",U=3,V=3)

    diff2prev12 = (mtnmode==0) ? diff2prev2 :
     \            (mtnmode==1) ? diff2prev2 .mt_Merge(diff2prev1,Vedge,U=2,V=2)
     \                         : diff2prev1 .mt_Merge(diff2prev2,Hedge,U=2,V=2)

    motn       = diff2prev12.mt_Logic(diff2prev12.DeleteFrame(0),"max",U=3,V=3).mt_Logic(diff2prev12.DeleteFrame(0).DeleteFrame(0),"max",U=3,V=3)
    notstatic  = mt_LutXY(motn,mm,"x 1 - y 1 + / "+MNTH1+" - "+MNTH2+" "+MNTH1+" - / 255 *",U=3,V=3).mt_Expand(U=3,V=3).mt_Inpand(U=3,V=3)
   # notstatic  = notstatic.mt_Logic(notstatic.RemoveGrain(4),"max",U=3,V=3).mt_Expand(U=3,V=3).mt_Inpand(U=3,V=3)


# Now do the error correction of the "naked" MC-bob
# -------------------------------------------------
    naked .mt_Merge(edibobbed,corrmask,luma=false,U=3,V=3) .Vinverse(2.7-sharpness)
    repaired = last


# If requested, sharpen the corrected MC-bob up a little 
# ( pre-sharpen for EdiPost = 0 | 1 )
# ------------------------------------------------------
    shrpbase  = last#.MinBlur(1,1).Merge(RemoveGrain(12,-1),0.23)
    shrp      = mt_LutXY(shrpbase,shrpbase.RemoveGrain(11,-1),"x x y - abs 16 / 1 1 x y - abs 1 4 / ^ + / ^ 16 * "+SSTR+" * x y - x y - abs 1.3 + / * 1 x y - abs 16 / 1 4 / ^ + / +",U=2,V=2)
    # \ .Repair(repaired,1,0)
    shrpD     = mt_Makediff(shrpbase,shrp)

    (sharpness==0.0 || EdiPost==2) ? last : last .mt_Makediff(MergeLuma(shrpD.MinBlur(1,uv=1),shrpD.RemoveGrain(12,-1),0.24),U=2,V=2)


# If requested, do additional PP via EEDI2
# ----------------------------------------
oweave.mt_merge(last,notstatic,luma=false,U=3,V=3)
    AssumeTFF()
    edisingle  = eedi2().LanczosResize(ox,oy,0,-0.5,ox,2*oy+0.001,taps=3)
    edidouble  = merge(SeparateFields().SelectEven().eedi2(field=1),SeparateFields().SelectOdd().EEDI2(field=0),0.5)
    edidoubleD = mt_makediff(last,edidouble,U=3,V=3)
    (EdiPost==1) ? edisingle : \
    (EdiPost==2) ? edidouble : last

# ( post-sharpen for EdiPost = 2 )
# ------------------------------------------------------
    edidoubleshrpD = mt_makediff(edidouble,sharpness==1.0?edidouble.removegrain(20):edidouble.removegrain(20).merge(edidouble,1.0-sharpness),U=3,V=3)
    edidoubleshrpD = edidoubleshrpD.repair(edidoubleD,13)
    (EdiPost==2) ? edidouble.mt_adddiff(edidoubleshrpD,U=3,V=3) : last


# STT (Shape Transposition Technology) Routine:
# =============================================
# Simply weaving the corrected output with the original fields is bad, because the risk of 
# creating unwanted residual combing is too high.
# Instead, the vertical "shape" is taken off the corrected output, and transposed 
# onto the fixed "poles" of the original fields' scanlines. Et Voila.
# ----------------------------------------------------------------------------------------
    synthbob   = last.AssumeParity(ORDR).SeparateFields().SelectEvery(4,0,3).Weave().Bob(1,0)
    mapped_new = flatbob.mt_makediff(mt_makediff(synthbob,last,U=3,V=3),U=3,V=3)
    newfields  = mapped_new.AssumeParity(ORDR).SeparateFields().SelectEvery(4,1,2)
    mappedbob  = Interleave(ofields,newfields).SelectEvery(4,0,1,3,2).AssumeParity(ORDR).Weave()


# Finally, for static areas use just original fields
# --------------------------------------------------
    mappedbob
    #bobbed
    
    oweave.mt_merge(last,notstatic.mt_inpand(Y=2,U=2,V=2),luma=false,U=3,V=3)


# Lastly, set correct parity for the bobbed clip
# ----------------------------------------------
    (order==0) ? AssumeTFF() : AssumeBFF()
    
    return(last)
}

# ===============================================

############################
#  Helper functions below  #
############################


## Function EEDIbob, courtesty of scharfis_brain:

    # slow, but accurate EEDI-bob, always dumb ;)
    # altering maxd changes the search radius for connecting diagonal lines

    Function EEDIbob(clip Input, int "maxd")
    {
	    #GetParity(Input) ? Input.SeparateFields().EEDI2(Field = 3, maxd = maxd, pp = 0, estr = 0, dstr = 0, mthresh = 0, vthresh = 0, lthresh = 0) : Input.SeparateFields().EEDI2(Field = 2, maxd = maxd, pp = 0, estr = 0, dstr = 0, mthresh = 0, vthresh = 0, lthresh = 0)
	    GetParity(Input) ? Input.SeparateFields().EEDI2(Field = 3, maxd = maxd) : Input.SeparateFields().EEDI2(Field = 2, maxd = maxd)

	    AssumeFrameBased()
	    GetParity(Input) ? AssumeTFF() : AssumeBFF()
    }


# Helper to simplify script
function AssumeParity(clip clp, string "order")
{
order == "TFF" ? clp.assumeTFF() : clp.assumeBFF()
return(last)
}

# Kill Combing Function
function Vinverse(clip clp, float "sstr", int "amnt", int "uv")
{
uv   = default(uv,3)
sstr = default(sstr,2.7)
amnt = default(amnt,255)
uv2  = (uv==2) ? 1 : uv
STR  = string(sstr)
AMN  = string(amnt)
vblur  = clp.mt_convolution("1","50 99 50",U=uv,V=uv)
vblurD = mt_makediff(clp,vblur,U=uv2,V=uv2)
Vshrp  = mt_lutxy(vblur,vblur.mt_convolution("1","1 4 6 4 1",U=uv2,V=uv2),expr="x x y - "+STR+" * +",U=uv2,V=uv2)
VshrpD = mt_makediff(Vshrp,vblur,U=uv2,V=uv2)
VlimD  = mt_lutxy(VshrpD,VblurD,expr="x 128 - y 128 - * 0 < x 128 - abs y 128 - abs < x y ? 128 - 0.25 * 128 + x 128 - abs y 128 - abs < x y ? ?",U=uv2,V=uv2)
mt_adddiff(Vblur,VlimD,U=uv,V=uv)
(amnt>254) ? last : (amnt==0) ? clp : mt_lutxy(clp,last,expr="x "+AMN+" + y < x "+AMN+" + x "+AMN+" - y > x "+AMN+" - y ? ?",U=uv,V=uv) 
return(last)
}

# Nifty Gauss/Median combination
function MinBlur(clip clp, int r, int "uv")
{
uv   = default(uv,3)
uv2  = (uv==2) ? 1 : uv
rg4  = (uv==3) ? 4 : -1
rg11 = (uv==3) ? 11 : -1
rg20 = (uv==3) ? 20 : -1
medf = (uv==3) ? 1 : -200

RG11D = (r==1) ? mt_makediff(clp,clp.removegrain(11,rg11),U=uv2,V=uv2)
 \    : (r==2) ? mt_makediff(clp,clp.removegrain(11,rg11).removegrain(20,rg20),U=uv2,V=uv2)
 \    :          mt_makediff(clp,clp.removegrain(11,rg11).removegrain(20,rg20).removegrain(20,rg20),U=uv2,V=uv2)
RG4D  = (r==1) ? mt_makediff(clp,clp.removegrain(4,rg4),U=uv2,V=uv2)
 \    : (r==2) ? mt_makediff(clp,clp.medianblur(2,2*medf,2*medf),U=uv2,V=uv2)
 \    :          mt_makediff(clp,clp.medianblur(3,3*medf,3*medf),U=uv2,V=uv2)
DD    = mt_lutxy(RG11D,RG4D,"x 128 - y 128 - * 0 < 128 x 128 - abs y 128 - abs < x y ? ?",U=uv2,V=uv2)
clp.mt_makediff(DD,U=uv,V=uv)
return(last)
}