# LSharpAAF() by Leinad4Mind
# v1.50 updated in 2011-12-06
# Requirements: awarpsharp2; EEDI2.dll; FastLineDarkenMOD.avsi; LSFmod.v1.9.avsi; MaskTools.dll; mt_masktools-26.dll; mvtools.dll;
# nnedi2.dll; RemoveGrain*.dll; Repair*.dll; SangNom.dll; UnFilter.dll
# * HD; HDS; S; SSE2; SSE3; T; TSSE2; TSSE3
# 
# All AA Scripts are in this script, so there are no need to download them separately; Except some of them that you can find in AnimeIVTC, as maa, daa.
#
# This is an Anti-Aliasing Combo with some Extras like FastLineDarkenMOD, Presharpening, Postsharpening and Postsmoothing
# 
# Thanks to @ Didée, thetoof, Mystery Keeper, Soulhunter, MisterHatt, martino, mf, Akirasuto, SpikeSpiegel, ScharfisBrain, LaTo & Sagekilla 
#
# Example: LSharpAAF(StrDrk=18, ShPre=100, ShPost=280, SmPost=80, aatype="ediaa")
# OR: LSharpAAF(18,100,280,80,"ediaa")

FUNCTION LSharpAAF(clip a, int "StrDrk", int "ShPre", int "ShPost", int "SmPost", bool "stabilize", int "tradius", bool "MT", int "aapel", int "aaov", int "aablk", string "aatype"){
StrDrk = default(StrDrk,38) #FastLineDarkenMOD
ShPre = default(ShPre,18) #Presharpening
ShPost = default(ShPost,300) #Postsharpening
SmPost = default(SmPost,100) #Postsmoothing
stabilize= default(stabilize,false ) # Use post stabilization with Motion Compensation
tradius	= default(tradius,2) # 2 = MDegrain2 / 3 = MDegrain3 
MT=default(MT,false) # Use josey_wells' branch of MVTools
aapel	= default(aapel,1) # accuracy of the motion estimation
# \ (Value can only be 1, 2 or 4. 1 means a precision to the pixel. 2 means a precision to half a pixel, 4 means a precision to quarter a pixel, produced by spatial interpolation (better but slower).)
aaov	= default ( aaov,(a.width>1100) ? 8 : 4 ) # block overlap value (horizontal). Must be even and less than block size. (Higher = more precise & slower)
aablk	= default ( aablk,(a.width>1100) ? 16 : 8 ) # Size of a block (horizontal). It's either 4, 8 or 16 ( default is 8 ). Larger blocks are less sensitive to noise, are faster, but also less accurate.
aatype = default(aatype,"EEDI2") # Use EEDI2() ; EEDI3() ; Sangnom() ; maa() ; daa() ; ediaa() ; aaa() ; saa() ; splinaa() ; supaa() ; naa() ; shaarp() ; aaf() ; laa() ; nnedi() ; nnedi2() ; nnedi3() ; antialiasing() ; nediaa() ; naa3mod(); for anti-aliasing.

a=a.AssumeTFF()
w=width(a)
h=height(a)
m=mt_logic(a.DEdgeMask(0,255,0,255,"5 10 5 0 0 0 -5 -10 -5", divisor=4,Y=3,U=3,V=3)
 \         ,a.DEdgeMask(0,255,0,255,"5 0 -5 10 0 -10 5 0 -5", divisor=4,Y=3,U=3,V=3)
 \       ,"max").mt_lut("x 128 / 0.86 ^ 255 *")

preaa=(ShPre==0 && StrDrk==0) ? a : (ShPre==0) ? a.fastlinedarkenmod(thinning=0, strength=StrDrk) : (StrDrk==0) ? a.lsfmod(defaults="slow",preblur="ON",strength=ShPre)
\ : a.fastlinedarkenmod(thinning=0, strength=StrDrk).lsfmod(defaults="slow",preblur="ON",strength=ShPre)

aa=(aatype=="EEDI2") ? preaa.TurnLeft().EEDI2().TurnRight().EEDI2().spline36resize(w,h,0.5,-0.5,2*w+.001,2*h+.001)
\ : (aatype=="EEDI3") ? preaa.TurnLeft().EEDI3().TurnRight().EEDI3().spline36resize(w,h)
\ : (aatype=="Sangnom") ? preaa.spline64resize(w*2,h*2).TurnLeft().SangNom(aa=255).TurnRight().SangNom(aa=255).spline36resize(w,h)
\ : (aatype=="maa") ? preaa.maa() : (aatype=="daa") ? preaa.daa() : (aatype=="ediaa") ? preaa.ediaa() : (aatype=="aaa") ? preaa.aaa()
\ : (aatype=="saa") ? preaa.SAA() : (aatype=="splinaa") ? preaa.splinaa() : (aatype=="supaa") ? preaa.supaa() : (aatype=="naa") ? preaa.naa()
\ : (aatype=="shaarp") ? preaa.shaarp() : (aatype=="aaf") ? preaa.aaf(aam=-0.7,rep=true) : (aatype=="laa") ? preaa.laa(96, 10, true, 2.0)
\ : (aatype=="nnedi") ? preaa.NNEDI(dh=true,field=1).TurnRight().NNEDI(dh=true,field=1).TurnLeft().Spline36Resize(w,h)
\ : (aatype=="nnedi2") ? preaa.NNEDI2(dh=true,field=1,nsize=2,qual=2).TurnRight().NNEDI2(dh=true,field=1,nsize=2,qual=2).TurnLeft().Spline36Resize(w,h,0.5,-0.5,2*w+.001,2*h+.001)
\ : (aatype=="nnedi3") ? preaa.NNEDI3(dh=true,field=1,nsize=2,qual=2).TurnRight().NNEDI3(dh=true,field=1,nsize=2,qual=2).TurnLeft().Spline36Resize(w, h)
\ : (aatype=="antialiasing") ? preaa.antialiasing()
\ : blankclip(pixel_type="YV12").subtitle("Please use Sangnom, EEDI2, EEDI3, maa, daa, ediaa, aaa, ssa, splinaa, supaa, naa, shaarp, aaf, laa,
 nnedi, nnedi2, nnedi3, or antialiasing for aatype")

postsh=(ShPost==0 && SmPost==0) ? aa : aa.LimitedSharpenFaster(edgemode=1,strength=ShPost,overshoot=1,soft=SmPost)

merged=mt_merge(a,postsh,m,Y=3,U=3,V=3)

sD=mt_makediff(a,merged)

asuper= a.MSuper(pel=aapel)
sDsuper  = sD.MSuper(pel=aapel, levels=1)

fv1 = tradius>=1 ? asuper.MAnalyse(isb=false,delta=1,overlap=aaov,blksize=aablk) : nop()
bv1 = tradius>=1 ? asuper.MAnalyse(isb=true, delta=1,overlap=aaov,blksize=aablk) : nop()
fv2 = tradius>=2 ? asuper.MAnalyse(isb=false,delta=2,overlap=aaov,blksize=aablk) : nop()
bv2 = tradius>=2 ? asuper.MAnalyse(isb=true, delta=2,overlap=aaov,blksize=aablk) : nop()
fv3 = tradius==3 ? asuper.MAnalyse(isb=false,delta=3,overlap=aaov,blksize=aablk) : nop()
bv3 = tradius==3 ? asuper.MAnalyse(isb=true, delta=3,overlap=aaov,blksize=aablk) : nop()

_thSAD = 600
_idx = 13

mbv1 = a.MVAnalyse(isb=true, delta=1,idx=_idx)
mbv2 = a.MVAnalyse(isb=true, delta=2,idx=_idx)
mfv2 = a.MVAnalyse(isb=false,delta=2,idx=_idx)
mfv1 = a.MVAnalyse(isb=false,delta=1,idx=_idx)
allv = (MT==false) ? a : a.MVAnalyseMulti(refframes=tradius,idx=_idx) 

sDD = (MT) ? sD.MVDegrainMulti(allv,idx=14) : sD.MVDegrain2(mbv1,mfv1,mbv2,mfv2,idx=14)
sDD2 = tradius==1 ? sDD.MDegrain1(sDsuper,bv1,fv1,thSAD=_thSAD) : tradius==2 ? sDD.MDegrain2(sDsuper,bv1,fv1,bv2,fv2,thSAD=_thSAD)
\ : sDD.MDegrain3(sDsuper,bv1,fv1,bv2,fv2,bv3,fv3,thSAD=_thSAD)

reduc = 0.4
sDD2 = mt_lutxy(sD,sDD2,"x 128 - abs y 128 - abs < x y ?").mergeluma(sDD2,1.0-reduc)

return stabilize ? a.mt_makediff(sDD2,U=2,V=2) : merged
}

#Simple Anti-aliasing by Soulhunter
FUNCTION saa(Clip Clp,Int"SS",Bool"CP") {
OX = Clp.Width
OY = Clp.Height
SS = Default(SS,2)
CP = Default(CP,True)
Clp = Clp.IsYV12() ? Clp : Clp.ConvertToYV12()
Clp.PointResize(OX*SS,OY*SS).SangNom().TurnRight()
\ .SangNom().TurnLeft().BilinearResize(OX,OY)
CP ? Last : MergeChroma(Clp)
Return(Last) }

#Normal Anti-aliasing by Didée
FUNCTION antialiasing(clip orig,int "th_luma",int "th_croma",string "type",int "aath") {

# "th_luma" & "th_croma" are the edge detection thres.: lower values=more edges filtered
# "type" is the matrix used for edge detection: with "sobel" (default) only the 
# hi-contrast edges, where artefacts are more noticeable, are filtered. If you want
# to test other matrices, read the MaskTools Guide for more info.
# "aath" = anti-aliasing strenght (default should be fine)

th_luma = Default(th_luma, 20)
th_croma = Default(th_croma, 20)
type = Default(type, "sobel")
aath = Default(aath, 48)
ox = orig.width
oy = orig.height
dx = orig.width * 2
dy = orig.height * 2
clp = orig.IsYV12() ? orig : orig.ConvertToYV12()

a=clp
b=clp.Lanczos4Resize(dx,dy).TurnLeft().SangNom(aa=aath).TurnRight().SangNom(aa=aath) \
.LanczosResize(ox,oy)
c=clp.EdgeMask(th_luma,th_luma,th_croma,th_croma,type)
MaskedMerge(a,b,c) }

# Written by MisterHatt, based off of Soulhunter's SAA() and martino's excellent MAA(), and is slightly
# faster at times for some reason or another. These functions work by generally supersampling, usually with
# nnedi2, and then running a deinterlacer (sangnom and nnedi2 respectively) to get rid of most jaggies.
# I have no idea how destructive these are on whatever random thing people care to throw them at.
# For large supersamples, avs2yuv bitches for no real reason and requires assumeframebased() in your script.
# Requires nnedi2, sangnom, o9k hours of your life.
FUNCTION splinaa(Clip Clp,Int"SS",Bool"CP") {
OX = Clp.Width
OY = Clp.Height
SS = Default(SS,2)
CP = Default(CP,True)
Clp = Clp.IsYV12() ? Clp : Clp.ConvertToYV12()
Clp.PointResize(OX*SS,OY*SS).SangNom().TurnRight()
\  .SangNom().TurnLeft().Spline36Resize(OX,OY)
CP ? Last : MergeChroma(Clp)

Return(Last) }

FUNCTION supaa(Clip Clp,Int"SS",Bool"CP") {
OX = Clp.Width
OY = Clp.Height
SS = Default(SS,2)
CP = Default(CP,True)
Clp = Clp.IsYV12() ? Clp : Clp.ConvertToYV12()
Clp.nnedi2_rpow2(rfactor=SS,cshift="spline36resize",qual=3).SangNom().TurnRight()
\  .SangNom().TurnLeft().Spline36Resize(OX,OY)
CP ? Last : MergeChroma(Clp)

Return(Last) }

FUNCTION naa(Clip Clp,Int"SS",Bool"CP") {
OX = Clp.Width
OY = Clp.Height
SS = Default(SS,2)
CP = Default(CP,True)
Clp = Clp.IsYV12() ? Clp : Clp.ConvertToYV12()
Clp.nnedi3_rpow2(rfactor=SS,cshift="spline36resize",qual=2).nnedi3(nns=2).TurnRight().nnedi3(nns=2).TurnLeft().Spline36Resize(OX,OY)
CP ? Last : MergeChroma(Clp)

Return(Last) }

FUNCTION shaarp(clip input, int "mask", int "type") {
mask = Default(mask,1)
type = Default(type,1)
Assert(mask == 1 || mask == 2, "Please use mask = 1 or 2")
Assert(type == 1 || type == 2, "Please use type = 1 or 2")
aa_clip = (type == 1) ? input.spline36Resize(width(input)*2,height(input)*2) : input.nnedi2_rpow2(rfactor=2,qual=3)
aa_clip = aa_clip.TurnLeft().nnedi2().TurnRight().nnedi2().spline36Resize(width(input),height(input)).MergeChroma(input)
mask = (mask==1) ? input.mt_edge("sobel",7,7,5,5).mt_inflate() : input.mt_edge("roberts",0,4,0,4).mt_inflate()

return mt_merge(input,aa_clip,mask) }

function aaf(clip input, float "aam", int "aay", "aax", bool "rep")
{
input =	input.isYV12() ? input : input.converttoyv12()

aam	= default(aam, -0.6)
aar	= aam<0 ? (aam-1)*0.25 : (aam+1)*0.25
aay	= default(aay, 28)
aax	= default(aax, aay)
rep	= default(rep, true)

sx	= width(input)
sy	= height(input)

aa	= aar<0 ? input.LanczosResize(sx,int(sy*abs(aar))*4) :
	\	aar==0.5 ? input.Pointresize(sx*2, sy*2) :
	\	input.LanczosResize(int(sx*abs(aar)*4),int(sy*abs(aar))*4)
aa	= aay>0 ? aa.SangNom(aa=aax) : input
aa	= aar<0 && aax>0 ? aa.LanczosResize(int(sx*abs(aar))*4,sy) : aa
aa	= aax>0 ? aa.turnright().SangNom(aa=aax).Turnleft() : aa
aa	= aa.LanczosResize(sx,sy)

return rep==true ? aa.repair(input,18) : aa
}

### LaTo Antialiasing Script v2
### Need: asharp.dll & sangnom.dll
function LAA(clip input, int "strength", int "threshold", bool "sharp", float "ss") {

strength = default(strength, 96)
threshold = default(threshold, 10)
sharp = default(sharp, true)
ss = default(ss, 2.0)
aastr = int(strength) /2
asthr = float(strength) /100
ox = input.width
oy = input.height
ox2 = round(ox*ss/8)*8
oy2 = round(oy*ss/8)*8

process = input.spline36resize(ox2,oy2).turnleft().sangnom(aastr).turnright().sangnom(aastr)
process = ( sharp == true ) ? process.asharp(asthr,0,0).spline36resize(ox,oy) : process.spline36resize(ox,oy)
mask = mt_average(input,process,u=1,v=1).mt_edge(thy1=threshold,thy2=threshold,u=1,v=1)
output = mt_merge(input,process,mask,u=2,v=2)

return ( output ) 
}

function NediAA(clip c)
{   c.nnedi3(field=-2)
    merge(selecteven(),selectodd())  }

FUNCTION naa3mod(Clip Clp,Bool "CP")
{
OX = Clp.Width()
OY = Clp.Height()
CP = Default(CP,True)
Clp = Clp.IsYV12() ? Clp : Clp.ConvertToYV12()
Clpnn1 = Clp.nnedi3(1, dh=true,nsize=2,qual=2,U=CP,V=CP).nnedi3(0,nsize=2,qual=2,U=CP,V=CP)
Clpy1 = Clpnn1.Spline36Resize(OX,OY,0,-0.5,OX,OY*2)
Clps1 = CP ? Clpy1.MergeChroma(Clpnn1.Spline36Resize(OX,OY,0,-1,OX,OY*2)) : Clpy1.MergeChroma(Clp)
Clpnn2 = Clps1.turnright().nnedi3(1, dh=true,nsize=2,qual=2,U=CP,V=CP).nnedi3(0,nsize=2,qual=2,U=CP,V=CP)
Clpy2 = Clpnn2.Spline36Resize(OY,OX,0,-0.5,OY,OX*2)
CP ? Clpy2.MergeChroma(Clpnn2.Spline36Resize(OY,OX,0,-1,OY,OX*2)).turnleft() : Clpy2.turnleft().MergeChroma(Clp)
Return(Last)
}