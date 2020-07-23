#Suggested by Mystery Keeper in "Denoise of tv-anime" thread
#function ediaa(clip a) {return a.EEDI2(field=1).TurnRight().EEDI2(field=1).TurnLeft().spline36resize(a.width,a.height,-0.5,-0.5)}


#ejemplo: SharpAAMCmod(stabilize=true,tradius=3,aapel=4)
#Developped in the "fine anime antialiasing thread"
#tunned by Dogway for eedi3,resizer and HQ lsfmod settings

function SharpAAMCmod(clip orig, int "width", int "height", float "dark", int "thin", int "sharp", int "smooth", bool "stabilize", int "tradius", int "aapel", int "aaov", int "aablk", string "aatype")
{

w	= default (width, width)
h	= default (height, height)
orig2   = orig.spline36resize(w,h)
dark	= default ( dark,     0.2 ) # strokes darkening strength
thin	= default ( thin,      10 ) # Presharpening
sharp	= default ( sharp,    150 ) # Postsharpening
smooth	= default ( smooth,    -1 ) # Postsmoothing
stabilize= default ( stabilize,false ) # Use post stabilization with Motion Compensation
Tradius	= default ( Tradius,    2 ) # 2 = MDegrain2 / 3 = MDegrain3 
aapel	= default ( aapel,      1 ) # accuracy of the motion estimation (Value can only be 1, 2 or 4. 1 means a precision to the pixel. 2 means a precision to half a pixel, 4 means a precision to quarter a pixel, produced by spatial interpolation (better but slower).)
aaov	= default ( aaov,       (orig2.width>1100) ? 8 : 4 ) # block overlap value (horizontal). Must be even and less than block size. (Higher = more precise & slower)
aablk	= default ( aablk,      (orig2.width>1100) ? 16 : 8 ) # Size of a block (horizontal). It's either 4, 8 or 16 ( default is 8 ). Larger blocks are less sensitive to noise, are faster, but also less accurate.
aatype	= default ( aatype, "Sangnom" ) # Use Sangnom() or EEDI3() for anti-aliasing


m=mt_logic( orig.DEdgeMask(0,255,0,255,"5 10 5 0 0 0 -5 -10 -5", divisor=4,Y=3,U=3,V=3)
 \       ,orig.DEdgeMask(0,255,0,255,"5 0 -5 10 0 -10 5 0 -5", divisor=4,Y=3,U=3,V=3)
 \       ,"max").mt_lut("x 128 / 0.86 ^ 255 *").spline36resize(w,h)
preaa=(thin==0 && dark==0) ? orig : (thin==0) ? orig.Toon(dark) : (dark==0) ? orig.awarpsharp2(depth=thin) : orig.Toon(dark).awarpsharp2(depth=thin)
aa= (aatype=="Sangnom") ? preaa.spline36resize(w*2,h*2).TurnLeft().SangNom().TurnRight().SangNom().spline36resize(w,h) : (aatype=="EEDI3") ? preaa.\
eedi3_rpow2(rfactor=2,hp=false).spline36resize(w,h,-0.5,-0.5) : blankclip(pixel_type="YV12").subtitle("Please use Sangnom or EEDI3 for aatype")
postsh=(sharp==0 && smooth==0) ? aa : aa.LSFmod(defaults="slow",strength=sharp,edgemode=0,soothe=true,ss_x=1.0,ss_y=1.0,overshoot=1,soft=smooth)
merged=mt_merge(orig2,postsh,m,Y=3,U=3,V=3)

sD=mt_makediff(orig2,merged)

origsuper= orig2.MSuper(pel=aapel)
sDsuper  = sD.  MSuper(pel=aapel, levels=1)


fv3 = tradius==3 ? origsuper.MAnalyse(isb=false,delta=3,overlap=aaov,blksize=aablk) : nop()
fv2 = tradius>=2 ? origsuper.MAnalyse(isb=false,delta=2,overlap=aaov,blksize=aablk) : nop()
fv1 = tradius>=1 ? origsuper.MAnalyse(isb=false,delta=1,overlap=aaov,blksize=aablk) : nop()
bv1 = tradius>=1 ? origsuper.MAnalyse(isb=true, delta=1,overlap=aaov,blksize=aablk) : nop()
bv2 = tradius>=2 ? origsuper.MAnalyse(isb=true, delta=2,overlap=aaov,blksize=aablk) : nop()
bv3 = tradius==3 ? origsuper.MAnalyse(isb=true, delta=3,overlap=aaov,blksize=aablk) : nop()
sDD = tradius==1 ? sD.MDegrain1(sDsuper,bv1,fv1) : tradius==2 ? sD.MDegrain2(sDsuper,bv1,fv1,bv2,fv2) : sD.MDegrain3(sDsuper,bv1,fv1,bv2,fv2,bv3,fv3)

reduc = 0.4
sDD = mt_lutxy(sD,sDD,"x 128 - abs y 128 - abs < x y ?").mergeluma(sDD,1.0-reduc)

return stabilize ? orig2.mt_makediff(sDD,U=2,V=2) : merged
}