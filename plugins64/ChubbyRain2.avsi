function ChubbyRain2(clip c, int "th", int "radius", bool "show", int "sft")
{
#based on Mug Funky's ChubbyRain

th = default(th,10)
radius = default(radius,10)
show = default(show,false)
sft = default (sft, 10)

u = c.utoy()
v = c.vtoy()

uc = u.mt_convolution(horizontal="1",vertical="1 -2 1",Y=3,U=0,V=0)
vc = v.mt_convolution(horizontal="1",vertical="1 -2 1",Y=3,U=0,V=0)

cc = c.mt_convolution(horizontal="1",vertical="1 2 1",Y=2,U=3,V=3).bifrost(interlaced=false).cnr2().temporalsoften(radius,0,sft,2,2)

rainbow=mt_lutxy(uc,vc,Yexpr=string("x y + "+string(th)+" > 256 0 ?")).pointresize(c.width,c.height).mt_expand(y=3,u=-128,v=-128)#.blur(1.5)

overlay(c,cc,mask=rainbow)

show==true? rainbow : last

} 