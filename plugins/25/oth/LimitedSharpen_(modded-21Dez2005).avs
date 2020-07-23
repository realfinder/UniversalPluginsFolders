# LimitedSharpen()   ( a modded version, 21 Dez 2005 )
#
# A multi-purpose sharpener by Didée
#
# 
# Changes in this mod:
#
# - RemoveGrain >= v0.9  IS REQUIRED!!
#   ==================================
#
# - Smode=4   / sometimes does the magic ;-)
# - a separate "undershoot" parameter, to allow for some line darkening in comic or Anime 
# - Lmode=3   / on edges, limited sharpening with zero OS & US. On not-edges, limited sharpening with specified OS + LS
# - "soft" acts different now: no more boolean true/false, but instead integer 0 - 100  (or -1 -> automatic)
#    instead of blurring before finding minima/maxima, it now softens the "effect-of-sharpening"
# - edgemode=-1 now shows the edgemask. (scaling still not implemented :p )
#
# - separate x/y sharpening for Smode=2 :  strength & strengthV  (strengthV is used for Smode=2 only)
# - Smode=0 : custom unsharp masking: radius & radiusV           (radiusV is used for Smode=0 only)

function LimitedSharpen( clip clp, 
 \                       float "ss_x",   float "ss_y", 
 \                       int   "dest_x", int   "dest_y",
 \                       int   "Smode" , int   "strength", int "strengthV", float "radius", float "radiusV",
 \                       int   "Lmode",  bool  "wide",     int  "overshoot", int "undershoot",
 \                       int   "soft",   int   "edgemode", bool "special",
 \                       int   "exborder" )
{
ox = clp.width
oy = clp.height

Smode     = default( Smode,       3 )
ss_x      = (Smode==4)
 \        ? default( ss_x,      1.25)
 \        : default( ss_x,      1.5 )
ss_y      = (Smode==4)
 \        ? default( ss_y,      1.25)
 \        : default( ss_y,      1.5 )
dest_x    = default( dest_x,     ox )
dest_y    = default( dest_y,     oy )
strength  = (Smode==1)
 \        ? default( strength,  160 )
 \        : default( strength,  100 )
strength  = (Smode==2&&strength>100) ? 100 : strength
   strengthV = default( strengthV, strength)
   strengthV = (strengthV>100) ? 100 : strengthV
radius    = default( radius,    2.0 )
   radiusV   = default( radiusV, radius)
   radius  = (radius <1.0) ? 1.0 : radius
   radiusV = (radiusV<1.0) ? 1.0 : radiusV
Lmode     = default( Lmode,       1 )
wide      = default( wide,    false )
overshoot = default( overshoot, 1)
undershoot= default( undershoot, overshoot)
softdec   = default( soft,        0 )
soft    =  softdec!=-1 ? softdec : sqrt( (((ss_x+ss_y)/2.0-1.0)*100.0) ) * 10
soft    = soft>100 ? 100 : soft
edgemode  = default( edgemode,    0 )
special   = default( special, false )
exborder  = default( exborder, 0)
#radius =   round( radius*(ss_x+ss_y)/2)  #  If it's you, Mug Funky - feel free to activate it again  
xxs=int(round(ox*ss_x/8.0))*8
yys=int(round(oy*ss_y/8.0))*8
usmx=int(round(xxs/radius/4.0))*4
usmy=int(round(yys/radiusV/4.0))*4
smx=exborder==0?dest_x:round(dest_x/Exborder/4)*4
smy=exborder==0?dest_y:round(dest_y/Exborder/4)*4

clp.isYV12() ? clp : clp.converttoyv12()

ss_x != 1.0 || ss_y != 1.0 ? last.lanczosresize(xxs,yys) : last
tmp = last

edge = logic( tmp.DEdgeMask(0,255,0,255,"8 16 8 0 0 0 -8 -16 -8", divisor=4)
 \           ,tmp.DEdgeMask(0,255,0,255,"8 0 -8 16 0 -16 8 0 -8", divisor=4)
 \           ,"max") .yv12lut("x 128 / 0.86 ^ 255 *") #.levels(0,0.86,128,0,255,false) 

tmpsoft       = (Smode==4) ? tmp.removegrain(11,-1)
 \            : (Smode==0) ? tmp.bicubicresize(usmx,usmy).bicubicresize(xxs,yys,1,0)
 \            :              tmp
dark_limit1   = tmp.inpand()
bright_limit1 = tmp.expand()
dark_limit    = (wide==false) ? dark_limit1   : dark_limit1  .removegrain(20,-1).inpand()
bright_limit  = (wide==false) ? bright_limit1 : bright_limit1.removegrain(20,-1).expand() 
minmaxavg     = special==false
 \            ? yv12lutxy(dark_limit1,bright_limit1,yexpr="x y + 2 /")
 \            : maskedmerge(dark_limit,bright_limit,tmp.removegrain(11,-1),Y=3,U=-128,V=-128)

Str=string(float(strength)/100.0)
normsharp = Smode==0 ? yv12lutxy(tmp,tmpsoft,yexpr="x x y - "+Str+" * +") 
 \        : Smode==1 ? unsharpmask(strength,int(radius),0) 
 \        : Smode==2 ? sharpen(float(strength)/100.0,float(strengthV)/100.0) 
 \        : Smode==3 ? yv12lutxy(tmp,minmaxavg,yexpr="x x y - "+Str+" * +")
 \        :            yv12lutxy(tmp,tmpsoft,"x y = x x x y - abs 16 / 1 2 / ^ 16 * "+Str+" * x y - 2 ^ x y - 2 ^ "+Str+" 100 * 25 / + / * x y - x y - abs / * + ?")

OS = string(overshoot)
US = string(undershoot)
Lmode == 1 ? yv12lutxy( bright_limit, normsharp, yexpr="y x "+OS+" + < y x "+OS+" + ?")
 \         : yv12lutxy( bright_limit, normsharp, yexpr="y x "+OS+" + < y x y x - "+OS+" - 1 2 / ^ + "+OS+" + ?")
Lmode == 1 ? yv12lutxy( dark_limit,   last,      yexpr="y x "+US+" - > y x "+US+" - ?")
 \         : yv12lutxy( dark_limit,   last,      yexpr="y x "+US+" - > y x x y - "+US+" - 1 2 / ^ - "+US+" - ?")


normal=last
OS2 = "0"
US2 = "0"
yv12lutxy( bright_limit, normsharp, yexpr="y x "+OS2+" + < y x "+OS2+" + ?")
yv12lutxy( dark_limit,   last,      yexpr="y x "+US2+" - > y x "+US2+" - ?")
zero=last

Lmode==3 ? maskedmerge(normal,zero,edge.inflate()) : normal

      edgemode==0  ?  last 
 \  : edgemode==1  ?  MaskedMerge(tmp,last,edge.inflate().inflate().removegrain(11,-1),Y=3,U=1,V=1)
 \  :                 MaskedMerge(last,tmp,edge.inflate().inflate().removegrain(11,-1),Y=3,U=1,V=1)

AMNT  = string(soft)
AMNT2 = string(100-soft)
sharpdiff=yv12lutxy(tmp,last,"x y - 128 +")
sharpdiff2=yv12lutxy(sharpdiff,sharpdiff.removegrain(19,-1),"x 128 - abs y 128 - abs > y "+AMNT+" * x "+AMNT2+" * + 100 / x ?")

soft==0 ? last : yv12lutxy(tmp,sharpdiff2,"x y 128 - -")
  
#  normal
 
     (ss_x != 1.0 || ss_y != 1.0) 
\ || (dest_x != ox || dest_y != oy) ? lanczosresize(dest_x,dest_y) : last

ex=blankclip(last,width=smx,height=smy,color=$FFFFFF).addborders(2,2,2,2).coloryuv(levels="TV->PC")
 \.blur(1.3).inpand().blur(1.3).bicubicresize(dest_x,dest_y,1.0,.0)
tmp =  clp.lanczosresize(dest_x,dest_y)

clp.isYV12() ? ( exborder==0 ? tmp.mergeluma(last)
 \                           : maskedmerge(tmp,last,ex,Y=3,U=1,V=1) )
 \           : ( exborder==0 ? tmp.mergeluma(last.converttoyuy2())
 \                           : tmp.mergeluma( maskedmerge(tmp.converttoyv12(),last,ex,Y=3,U=1,V=1)
 \                                           .converttoyuy2()) )

(edgemode!= -1) ? last : edge.lanczosresize(dest_x,dest_y).greyscale

return last
}
