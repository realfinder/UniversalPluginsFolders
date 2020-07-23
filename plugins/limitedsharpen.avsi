# LimitedSharpen()
#
# A multi-purpose sharpener by Didée
#

function LimitedSharpen( clip clp, 
 \                       float "ss_x",   float "ss_y", 
 \                       int   "dest_x", int   "dest_y",
 \                       int   "Smode" , int   "strength", int  "radius", 
 \                       int   "Lmode",  bool  "wide",     int  "overshoot", 
 \                       bool  "soft",   int   "edgemode", bool "special",
 \                       int   "exborder" )
{
ox = clp.width
oy = clp.height
ss_x =     default( ss_x, 1.5 )
ss_y =     default( ss_y, 1.5 )
dest_x =   default( dest_x, ox )
dest_y =   default( dest_y, oy )
Smode =    default( Smode, 3 )
strength = Smode==1 
 \       ? default( strength, 160 )
 \       : default( strength, 100 )
strength = Smode==2&&strength>100 ? 100 : strength
radius =   default( radius, 2 )
Lmode =    default( Lmode, 1 )
wide =     default( wide, false )
overshoot= default( overshoot, 1)
overshoot= overshoot<0 ? 0 : overshoot
soft =     default( soft, false )
edgemode = default( edgemode, 0 )
special =  default( special, false )
exborder = default( exborder, 0)
#radius =   round( radius*(ss_x+ss_y)/2)  #  If it's you, Mug Funky - feel free to activate it again  
xxs=round(ox*ss_x/8)*8
yys=round(oy*ss_y/8)*8
smx=exborder==0?dest_x:round(dest_x/Exborder/4)*4
smy=exborder==0?dest_y:round(dest_y/Exborder/4)*4

clp.isYV12() ? clp : clp.converttoyv12()

ss_x != 1.0 || ss_y != 1.0 ? last.lanczosresize(xxs,yys) : last
tmp = last

edge = logic( tmp.DEdgeMask(0,255,0,255,"5 10 5 0 0 0 -5 -10 -5", divisor=2)
 \           ,tmp.DEdgeMask(0,255,0,255,"5 0 -5 10 0 -10 5 0 -5", divisor=2)
 \           ,"max").levels(0,0.86,128,0,255,false) 

bright_limit = (soft == true) ? tmp.blur(1.0) : tmp
dark_limit   = bright_limit.inpand()
bright_limit = bright_limit.expand()
dark_limit   = (wide==false) ? dark_limit   : dark_limit  .inflate.deflate.inpand()
bright_limit = (wide==false) ? bright_limit : bright_limit.deflate.inflate.expand() 
minmaxavg    = special==false
 \           ? yv12lutxy(bright_limit,dark_limit,yexpr="x y + 2 /")
\            : maskedmerge(dark_limit,bright_limit,tmp,Y=3,U=-128,V=-128,useMMX=true)

Str=string(float(strength)/100.0)
normsharp = Smode==1 ? unsharpmask(strength,radius,0) 
 \                   : Smode==2 ? sharpen(float(strength)/100.0) 
 \                              : yv12lutxy(tmp,minmaxavg,yexpr="x x y - "+Str+" * +")

OS = string(overshoot)
Lmode == 1 ? yv12lutxy( bright_limit, normsharp, yexpr="y x "+OS+" + < y x "+OS+" + ?")
 \         : yv12lutxy( bright_limit, normsharp, yexpr="y x "+OS+" + < y x y x - "+OS+" - 1 2 / ^ + "+OS+" + ?")
Lmode == 1 ? yv12lutxy( dark_limit,   last,      yexpr="y x "+OS+" - > y x "+OS+" - ?")
 \         : yv12lutxy( dark_limit,   last,      yexpr="y x "+OS+" - > y x x y - "+OS+" - 1 2 / ^ - "+OS+" - ?")

edgemode==0 ? NOP 
 \          : edgemode==1 
 \            ? MaskedMerge(tmp,last,edge.inflate.inflate.blur(1.0),Y=3,U=1,V=1,useMMX=true)
 \            : MaskedMerge(last,tmp,edge.inflate.inflate.blur(1.0),Y=3,U=1,V=1,useMMX=true)

     (ss_x != 1.0 || ss_y != 1.0) 
\ || (dest_x != ox || dest_y != oy) ? lanczosresize(dest_x,dest_y) : last

ex=blankclip(last,width=smx,height=smy,color=$FFFFFF).addborders(2,2,2,2).coloryuv(levels="TV->PC")
 \.blur(1.3).inpand().blur(1.3).bicubicresize(dest_x,dest_y,1.0,.0)
tmp=clp.lanczosresize(dest_x,dest_y)

clp.isYV12() ? ( exborder==0 ? tmp.mergeluma(last)
 \                           : maskedmerge(tmp,last,ex,Y=3,U=1,V=1,useMMX=true) )
 \           : ( exborder==0 ? tmp.mergeluma(last.converttoyuy2())
 \                           : tmp.mergeluma( maskedmerge(tmp.converttoyv12(),last,ex,Y=3,U=1,V=1,useMMX=true)
 \                                           .converttoyuy2()) )
 
return last
}
#