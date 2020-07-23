#hqdmod 0.1
#Based on HQDering by Mf

function hqdmod(clip C,int "str",int "exp",int "rad")
{
str=default(str,10)
exp=default(exp,7)
rad=default(rad,2)
mm=mt_lutxy(C,xsharpen(C,127,255),"x y - abs 1 - 63 *",u=1,v=1)
mt_merge(C,C.RemoveGrain(17),mt_lutxy(mm,xpd(mm,exp),"y x - 63 - 1.5 *",u=1,v=1))
#mt_merge(C,Repair(C.deen("a2d",rad,str,str).RemoveGrain(21),C,15),mt_lutxy(mm,xpd(mm,exp),"y x - 63 - 1.5 *",u=1,v=1))
}

