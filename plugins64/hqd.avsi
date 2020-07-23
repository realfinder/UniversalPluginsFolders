#hqd 0.2
#Based on HQDering by Mf

function hqd(clip C,int "str",int "exp",int "rad")
{
str=default(str,10)
exp=default(exp,7)
rad=default(rad,2)
mm=mt_lutxy(C,xsharpen(C,127,255),"x y - abs 1 - 63 *",u=1,v=1)
mt_merge(C,C.deen("a2d",rad,str,str),mt_lutxy(mm,xpd(mm,exp),"y x - 63 - 1.5 *",u=1,v=1))
}

function xpd(clip C,int "nt")
{
nt=default(nt,0)
(nt>0)?mt_expand(C,u=1,v=1):C
return((nt>1)?xpd(last,nt-1):last)
} 