function FlexibleMerge (clip clip1,clip clip2,float "weight",float "weight2",int "mode",int "x",int "y",int "thr",int "show",int "exc",int "nmax") {
thr=default(thr,10)
weight=default(weight,0.5)
weight2=default(weight2,0.9)
mode=default(mode,0)
cx=default(x,0)
cy=default(y,0)
show=default(show,0)
exc=default(exc,0)
clip2=(mode==0) ? clip2 : Overlay(clip1,clip2,x=cx,y=cy)

Mask1=CombMask(clip1, thY1 = thr, thY2 = thr)
Mask2=CombMask(clip2, thY1 = thr, thY2 = thr)
mask3=mt_invert(mask2)#2‚ª‚«‚ê‚¢
mask4=mt_logic(mask2,mask1,mode="andn")#1‚ÉƒmƒCƒYA2‚Í‚«‚ê‚¢

clip3=Merge(clip1,clip2,weight)
clip4=Merge(clip1,clip2,weight2)
clip=mt_merge(clip1,clip3,mask3,luma=true)
clip=mt_merge(clip,clip4,mask4,luma=true)

clip=(exc>0) ? NoiseExclude(clip,clip1,clip2,mode=exc,thr=nmax,showi=show) : clip

clip=(show==1) ? Combcheck(clip) :
\(show==2) ? StackHorizontal(Combcheck(clip1),Combcheck(clip2)).ReduceBy2.StackVertical(ReduceBy2(Combcheck(clip)).AddBorders(clip.width/4,0,clip.width/4,0)) : clip
return clip
}

function NoiseExclude (clip clip,clip clip1,clip clip2,int "mode",int "thr",int "showi") {
mode=default(mode,1)
thr=default(thr,30)
showi=default(showi,0)
global thr=thr
show=(showi==3) ? true : false
c1=CombMask(clip1, thY1 = 10, thY2 = 10)
c2=CombMask(clip2, thY1 = 10, thY2 = 10)
clip1=(show) ? clip1.Subtitle("1") : clip1
clip2=(show) ? clip2.Subtitle("2") : clip2
clipSelect=conditionalfilter(interleave(c1,c2),clip1,clip2,"AverageLuma(SelectEven)","<","AverageLuma(SelectOdd)")
clip=(mode==1) ? ConditionalFilter(interleave(c1,c2),clip,clip1,"abs(AverageLuma(SelectEven)-AverageLuma(SelectOdd))","<","thr",show)
\ : ConditionalFilter(interleave(c1,c2),clip,clipSelect,"abs(AverageLuma(SelectEven)-AverageLuma(SelectOdd))","<","thr",show)
return clip
}

function Combcheck (clip clip) {
clip=mt_merge(Grayscale(clip),ColorYUV(Grayscale(clip),gain_u=100,gain_v=100),CombMask(clip,thY1=16,thY2=16),luma=true)
return clip
}