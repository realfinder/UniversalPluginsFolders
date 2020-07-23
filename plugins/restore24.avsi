#   Restore24 v1.0 RC1
#
#


Function Restore24(clip  input,   float "r24fps",      int "numr",     int  "deno", 
 \                 int  "r24deint", int "r24deintth", bool "r24match",float "r24size",float "r24ysize",
 \                 int  "edgetype", int "edgemode",    int "edgeeval", bool "chromeval",
 \                 bool "useLL",    int "nr",int "nrc",int "fra",       int "frr",     
 \                 float "ldmp",  float "hipass",  int "debug",      clip "renderbob", 
 \                 bool "fulltriples", bool "stringuent")
{

global _fulltriples = default(fulltriples, false)
global _stringuent = default(stringuent, false)

###### PARAMETER DEFAULTS ######--------------------------------------------------------------------------------

#----- Framerate: (and decimation method) ;)
       decmode  = (defined(deno)) ? 0 : 1    #  If a numr/deno ratio is specified, SmartDecimate will be used as
                                             #  Decimator. If not, TDecimate is used (default).
       numr     = default( numr,     2997 )  #  SmartDecimate:  destination framerate is specified  
       deno     = default( deno,     6250 )  #                  by Numerator/Denomerator
       r24fps   = default( r24fps,
        \     framerate(input)*2*float(numr)/float(deno) )  #  TDecimate: Destination framerate specified directly

#----- Deinterlacing Mode:                   #  0 - user defined bob (must be handed over via "renderbob" clip parameter)
       r24deint = default( r24deint,    2 )  #  1 - Stupid bob  -> fastest
                                             #  2 - Kernelbob   -> fast but doesn't squeeze out every detail
                                             #  3 - TDeint      -> slow, best quality, Kernel interpolation
                                             #  4 - TDeint      -> slow, best quality, Edge Directed interpolation 
                                             #                     (more flicker than kernel, but lesser stairstepping)
       r24deintth= default( r24deintth,  6)  #  Deinterlacing threshold (only used for r24deint=2|3|4)

       r24match  = default( r24match, false) #  Weave similar fields together? 
       r24match1 = r24match ? false : true   #     (only alvailable with TDeint)

#----- Evaluation method:                   
       edgetype = default( edgetype,    0 )  #  0=temporal pixel clipping | 1=FineEdge | 2=MinMaxEdge
       edgemode = default( edgemode,    1 )  #  1=single | 2=double  (NOT used for edgetype=0 [same for 'edgeeval' below] )
       edgeeval = default( edgeeval,    2 )  #  edgemask evaluation:  1=brightness | 2=motion sensitive | 3=area based
       chromeval= default( chromeval,false)  #  chroma blend evaluation (ONLY for edgetype=0)
       r24size  = default( r24size, 
        \        (edgetype==0) ? 0.8 : 1.0)  #  Size reduction of analyze clip
       r24ysize = default(r24ysize,r24size)  #  Separate vertical size reduction, if uneven reduction is wished or needed
       useLL    = default( useLL,   
        \     (decmode==0) ? true : false )  #  Decimation helper trick, only for SmartDecimate
       hipass   = default( hipass,    0.0 )  #  Percentage of highpass filter to use for analyze clip

#----- Noise reduction  &  Flicker reduction
       nr       = default( nr, 
        \            (edgetype==0) ? 5 : 0)  #  Noise reduction of analyze clip
       nrc      = default( nrc,    nr*2/3 )  #  Noise reduction of analyze clip (chroma)
       fra      = default( fra,         1 )  #  Flicker reduction of analyze clip
       frr      = default( frr,         0 )  #  Flicker reduction of render clip
       #  Trying to get a reasonable default for damping of low clipping values, derived from r24size & denoising strength:
       ldmp     = default( ldmp, 32.0 * (r24size) * (1.0 - abs(nr)/(abs(nr)+2.0+r24size)) * (nr<0 ? pow(0.4,pow(r24size,2)) : 1.0) )  

#----- Wrapping some variables for internal usage
       ox       = input.width
       oy       = input.height
       wx       = m4(ox*abs(r24size)/2.0)*2
       wy       = m4(oy*abs(r24ysize)/2.0)*2
       ex       = wx-16
       ey       = wy-16
global cox      = ox
global coy      = oy
global r24useLL = useLL
global dbg      = default( debug,      0 )
global LLborder = r24useLL ? m4(oy/56.0)*4 : 0
global mxndl    = (float(framerate(input)) < r24fps) ? 2 : 1
global usual    = int(round(framerate(input)*20.0/r24fps)) == 21 ? true : false
global init     = 0
global ratio    = 0.0
       Eeval    = edgeeval
       rfsplit  = (r24deint==1 && frr!=fra) || (r24deint!=1 && frr!=0) ? true : false
       chromeval= (edgetype==0) ? chromeval : false
       Cmode    = (chromeval) ? 1 : (dbg!=0) ? 0 : -1
       uv1      = (chromeval) ? 3 : (dbg!=0) ? 2 : 1
       uv2      = (chromeval) ? 3 : 2
       _grey    = (chromeval) ? false : true
       HIP      = string(hipass)
       NR1      = string(abs(nr))
       NR2      = string(nr*1.67)
       NR1c     = string(nrc)
       NR2c     = string(nrc*1.67)
       DMP      = string(ldmp)
       BOOST    = "x y - abs 128 * x y - abs x y - abs "+DMP+" + / *"
       NRstr    = "x "+NR2 +" + y < x "+NR1 +" + x "+NR2 +" - y > x "+NR1 +" - x 51 * y 49 * + 100 / ? ?"
       NRCstr   = "x "+NR2c+" + y < x "+NR1c+" + x "+NR2c+" - y > x "+NR1c+" - x 51 * y 49 * + 100 / ? ?"
       HIPAS    = "x y - 128 + "+HIP+" * x 1.0 "+HIP+" - * +"

#----- More variables for per-frame conditional evaluation, debug display, etc.  -------------------------------
       startup = int(round(framerate(input)))*2
global btest_p2 = 0
global btest_p1 = 0
global btest_c  = 0
global btest_n1 = 0
global btest_n2 = 0
global btest_n3 = 0
global IsBlend_n2 = false
global IsBlend_n1 = false
global IsBlend_c  = false
global IsBlend_p1 = false
global IsBlend_p2 = false
global frametype_p3 = 0
global frametype_p2 = 0
global frametype_p1 = 0
global frametype_c  = 0
global frametype_n  = 0
global in_pattern = false
global pattern_guidance = 0
global count_p = 0
global count_n = 0
global LL = 0
global colorLL = $000000
global pattcount = 0
global lastpatt4 = 0
global lastpatt3 = 0
global lastpatt2 = 0
global lastpatt1 = 0
global lastpatt0 = 0
global pattavg   = 0.0
global pattavg1  = 0.0
global bcount = 24
global fcount = 50
global pool = 0
global poolcount=0
global act_ratio = 0.0
global poffset = 0
global nextpattern = 0


global gnaharr = false
global dbgoffs = mod(376.0/432.0*oy,4)

global hist2 = "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
global hist2 = LeftStr(hist2+hist2+hist2,mod(100.0/704.0*ox,4))       
global h2lngth = StrLen(hist2)

global patt0 = " 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00"
global patt0 = LeftStr(patt0+patt0+patt0,mod(141.0/704.0*ox,3))       
global p0lngth = StrLen(patt0)

global patt1 = patt0
global patt2 = patt0
global patt3 = patt0
global patt4 = patt0


###### CREATE WORKING & OUTPUT STREAM ######--------------------------------------------------------------------

global work = (fra==0 || rfsplit) ? input .bob(-0.2,0.6) 
        \                         : input .bob(-0.2,0.6) .reduceflicker(strength=fra)

#----- Output Stream -----#
global out  = (r24deint==0) ? renderbob : \
              (r24deint==1) ? work : \
              (r24deint==2) ? input.leakkernelbob(order=(getparity(input) ? 1 : 0), threshold=r24deintth) : \
              (r24deint==3) ? input.tdeint(mode=1, type=2, link=0, mthreshl=r24deintth, mthreshc=r24deintth, tryweave=r24match, full=r24match1,sharp=true) : \
              (r24deint==4) ? input.tdeint(mode=1, type=1, link=0, mthreshl=r24deintth, mthreshc=r24deintth, tryweave=r24match, full=r24match1) : \
              work.subtitle("wrong r24deint! only 0, 1, 2, 3 and 4 allowed")
global out  = (rfsplit && frr>0) ? out.reduceflicker(strength=frr) : out 
 # global out = Soothe(repair(out.sharpen(0,1),out,1,2,2),out,0)
global work = (rfsplit && fra>0) ? work.reduceflicker(strength=fra) : work 
  #global work=input
  #global out=work

global out  = out.duplicateframe(0).trim(1,1).loop(startup) + out
global out0 = out.duplicateframe(0)
global out1 = out.deleteframe(0)
  #return stackvertical(work,work.LTbS(abs(nr),2))

#----- Working Stream -----#
global work = work.trim(1,startup).reverse() + work 
  #return stackvertical(work,work.LTbS(abs(nr),uv1) )
global work = isyv12(work)   ? work : work.ConvertToYV12() #
global work = (r24size<0.0 && abs(r24size)<1.0) ? work.bicubicresize(wx,wy,0.5,0.25)  :
        \     (r24size<0.0 && abs(r24size)>1.0) ? work.bicubicresize(wx,wy,-0.2,0.6)  : work
global work = (nr>0)        ? yv12lutxy(work, work .removegrain(4,4*Cmode) .removegrain(19,19*Cmode), NRstr,NRCstr,NRCstr, U=uv1,V=uv1)  :
        \     (nr<0)        ? work.LTbS(abs(nr),uv1)
        \                   : work
global work = (r24size<1.0) ? work.bicubicresize(wx,wy,0.5,0.25)  :
        \     (r24size>1.0) ? work.bicubicresize(wx,wy,-0.2,0.6)  : work
global work = (edgetype!=0 || hipass==0.0)
        \                   ? work : yv12lutxy(work, work.bicubicresize(m4(wx/9.0),m4(wy/9.0)).bicubicresize(wx,wy,1,0),HIPAS,U=2,V=2)
global work = work.crop(8,8,-8,-8,true) 


###### BUILD ANALYZE CLIP (edgemask or pixelclipping) ######----------------------------------------------------

       small     = work.bicubicresize(m4(work.width/3.0),m4(work.height/3.0))

       edge = (edgetype==1) ? logic( work.DEdgemask(0,255,0,255,"8 0 -8 16 0 -16 8 0 -8",setdivisor=true,divisor=10),
        \                            work.DEdgemask(0,255,0,255,"8 16 8 0 0 0 -8 -16 -8",setdivisor=true,divisor=10),"max") 
        \                   : yv12lutxy(work.expand,work.inpand,"x y - 1 1.4142 / ^ 5.00 * 1.05 * x y - x y - 2 + / *",U=1,V=1)

       edgesmall = (edgetype==1) ?  logic(small.DEdgemask(0,255,0,255,"8 0 -8 16 0 -16 8 0 -8",setdivisor=true,divisor=12),
        \                                 small.DEdgemask(0,255,0,255,"8 16 8 0 0 0 -8 -16 -8",setdivisor=true,divisor=12),"max")
        \                        :  yv12lutxy(small.expand,small.inpand,"x y - 1 1.4142 / ^ 5.00 * 1 * x y - x y - 1 + / *",U=1,V=1)

       edgesmall = edgesmall.bicubicresize(ex,ey)

       mixmask   = edge.expand.bicubicresize(m4(ex/3.0),m4(ey/3.0),-1.0,.0).expand.bicubicresize(ex,ey,1,0)

       edge      = (edgemode == 1) ? edge
        \                          : maskedmerge(edgesmall,edge,mixmask, U=1,V=1)

       edgearea  = yv12lutxy(edge,edge.bicubicresize(m4(ex/6.0),m4(ey/6.0)).bicubicresize(m4(ex/27.0),m4(ey/27.0))
        \                             .bicubicresize(ex,ey,1,0), "x y - 5 > 255 0 ?", U=1,V=1)

       edge = (edgetype==0) ? yv12lutxy( work, work.clense(reduceflicker=false,grey=_grey), BOOST,BOOST,BOOST, U=uv1,V=uv1) : edge

global work = (chromeval==false) ? work : stackvertical(stackhorizontal(work.UtoY(),work.VtoY()),work)
       pixclipp = yv12lutxy( work, work.clense(reduceflicker=false,grey=_grey), BOOST,BOOST,BOOST, U=uv1,V=uv1)
     #  pixclipp = interleave(pixclipp.selecteven().temporalsoften(2,255,255,255,2),pixclipp.selectodd().temporalsoften(2,255,255,255,2))

####### FINALIZE ANALYZE CLIP, and put into global variable ######
global edge_c  = (edgetype==0) ? pixclipp  :
        \        (edgeeval==1) ? edge.yv12lut("x 4 / 255 x - * x x * + 255 /")  :
        \        (edgeeval==2) ? yv12lutxy( edge, logic(edge.deleteframe(0),edge.duplicateframe(0),"max" ),"x y -", U=1,V=1)
        \                      : logic( edge, edgearea, "min")
 
#----- preceeding and proceeding frames
global edge_p2 = BlankClip(edge_c).trim(1,2)+edge_c
global edge_p1 = edge_p2 .trim(1,0)
global edge_n1 = edge_p2 .trim(3,0)
global edge_n2 = edge_p2 .trim(4,0)
global edge_n3 = edge_p2 .trim(5,0)
global edgearea_n3 = edgearea .trim(3,0)


##### DEBUGGING DISPLAY FUNCTIONS #####-------------------------------------------------------------------------

function ShowMetrics( clip clp )
{ 
       clp
       subtitle(hist2,   y=8, size=13)
       subtitle("blend detection:  "+string(IsBlend_c),   y=24, size=13)
       subtitle("blend prediction: "+string(in_pattern),  y=37, size=13)
       subtitle("metric: prev= "+string(btest_c-btest_p1) + "   next ="+string(btest_c-btest_n1) , y=50, size=13) 
       subtitle("ratio prv= "+string(btest_c/(btest_p1+.0000001)) + "   nxt ="+string(btest_c/(btest_n1+.0000001)) , y=63, size=13) 
#      subtitle("pattern guideance = "+string(pattern_guidance),  y=80)
       subtitle("p3 = "+string(frametype_p3) + "   ("+string(IsBlend_p3)+")",y=89, size=13)
       subtitle("p2 = "+string(frametype_p2) + "   ("+string(IsBlend_p2)+")",y=102, size=13)
       subtitle("p1 = "+string(frametype_p1) + "   ("+string(IsBlend_p1)+")",y=115, size=13)
       subtitle("c   = "+string(frametype_c)  + "   ("+string(IsBlend_c)+")", y=128, size=13)
       subtitle("n1 =      ("+string(IsBlend_n1)+")", y=141, size=13)
       subtitle("n2 =      ("+string(IsBlend_n2)+")", y=154, size=13)
       return( last ) 
}

function ShowCycles( clip clp )
{
       helpstr = lastpatt1<10 ? "0" : ""
global patt4 = pattcount==1 ? rightstr(patt4,p0lngth-3)+leftstr(patt3,3) : patt4
global patt3 = pattcount==1 ? rightstr(patt3,p0lngth-3)+leftstr(patt2,3) : patt3
global patt2 = pattcount==1 ? rightstr(patt2,p0lngth-3)+leftstr(patt1,3) : patt2
global patt1 = pattcount==1 ? rightstr(patt1,p0lngth-3)+leftstr(patt0,3) : patt1
global patt0 = pattcount==1 ? rightstr(patt0,p0lngth-3)+" "+helpstr+string(lastpatt1) : patt0
       clp
       subtitle(patt4,y=dbgoffs+ 0,size=12)
       subtitle(patt3,y=dbgoffs+12,size=12)
       subtitle(patt2,y=dbgoffs+24,size=12)
       subtitle(patt1,y=dbgoffs+36,size=12)
       subtitle(patt0,y=dbgoffs+48,size=12)
       
         disp=frametype_c==0?0.5:-0.5
        # subtitle(string(pattavg1)+"  "+string(pattavg),x=222,y=222)
         subtitle(string(ratio),x=222,y=222)
        # subtitle(string(50.0/(fcount+.000001)*(bcount+disp+.000001)),x=222,y=242)
         subtitle(string(act_ratio)+"   offset: "+string(poffset),x=222,y=242)
        # subtitle(string(pool/(poolcount+0.000001)),x=352,y=242)

       return( last )
 }

##### REPLACE FUNCTIONS #####-----------------------------------------------------------------------------------
function PutCurr( ) 
{ 
global fcount=init==0?fcount:fcount+1
global frametype_c = 0

#global hist1=rightstr(hist1,14)+"c"
global hist2 = (dbg==0) ? hist2 : gnaharr  ? rightstr(hist2,h2lngth-1)+">" : rightstr(hist2,h2lngth-1)+"+"
global colorLL = (LL==0) ? $00000 : $FFFFFF
       r24useLL ? out.addborders(0,0,0,LLborder,color=colorLL) : 
 \     gnaharr  ? out1   : out
#                     .subtitle("Gnaharr !!",x=222,y=111)
global gnaharr = false
       return( last ) 
}
         
function PutPrev( ) 
{ 
global bcount=init==0?bcount:bcount+1
global fcount=init==0?fcount:fcount+1
global frametype_c = -1

#global hist1=rightstr(hist1,14)+"B"
    type = in_pattern ? "?" : "_"
global hist2 = (dbg==0) ? hist2 : rightstr(hist2,h2lngth-1)+ type # "_"
global LL = abs(LL - 1)
       r24useLL ? out0.addborders(0,0,0,LLborder,color=colorLL) : out0
       return( last ) 
}

#----- Helper functions -----#
function correct( ) 
{
global isblend_c  = true
global isblend_n1 = false
global isblend_n2 = true
  global btest_n3=255.0
}
function BreakPattern( ) 
{
global isblend_c  = false
global isblend_n1 = true
global isblend_n2 = false
global in_pattern = false
  global btest_n3=0.0
  global frametype_p1=0
}

function CountCurrPattern( )
{
global pattcount = pattcount+1
global lastpatt0 = pattcount
}

function CountNewPattern( )
{
 global act_ratio = 50.0/(fcount+.000001)*(bcount+.000001)
 err21 = abs( act_ratio * ((fcount+21)/float(bcount+10)) - 50.0)
 err25 = abs( act_ratio * ((fcount+25)/float(bcount+12)) - 50.0)
 err29 = abs( act_ratio * ((fcount+29)/float(bcount+14)) - 50.0)
 global poffset = init>1?poffset+pattcount-nextpattern:0
 global nextpattern = (err21<err25) ? 21 : err25<err29 ? 25 : 29
global pattavg1 = pattavg
global lastpatt4 = lastpatt3
global lastpatt3 = lastpatt2
global lastpatt2 = lastpatt1
global lastpatt1 = lastpatt0
global lastpatt0 = pattcount
global pattcount = 1
global poolcount = lastpatt1>2 ? poolcount+1 : poolcount
global poolcount = lastpatt0>29 ? poolcount+1 : poolcount
global pool = pool+lastpatt0
}

function ShiftBackVars( )
{
global btest_p2     = btest_p1
global btest_p1     = btest_c
global btest_c      = btest_n1
global btest_n1     = btest_n2
global btest_n2     = btest_n3
global frametype_p3 = frametype_p2
global frametype_p2 = frametype_p1
global frametype_p1 = frametype_c
global IsBlend_p3   = IsBlend_p2
global IsBlend_p2   = IsBlend_p1
global IsBlend_p1   = IsBlend_c
global IsBlend_c    = IsBlend_n1
global IsBlend_n1   = IsBlend_n2
}


###### BLEND REPLACEMENT (main per-frame conditional function) ######-------------------------------------------

function Evaluate( ) 
{ 

#----- For 50i->24p only, blend certainty checks for low motion:
       diff_n3 = btest_n2 - btest_n3
       diff_n1 = btest_n2 - btest_n1
 # global isblend_n2 = isblend_n2 && abs(diff_n3)>0.66 && abs(diff_n1)>0.66
       diff_p = btest_c - btest_p1
       diff_n = btest_c - btest_n1
       middle1 = frametype_p1==-1 && isblend_c==false && isblend_n1==false && isblend_n2==true
       middle2 = frametype_p1==0 && isblend_n1
#global isblend_c = isblend_c && ( (abs(diff_p)<1.0 && abs(diff_n)<1.0) || abs(diff_p)<0.5 || abs(diff_n)<0.5) ? false : isblend_c
global init = lastpatt3>3 ? 3 : lastpatt2>3 ? 2 : lastpatt1>3 ? 1 : 0

#----- Check neighbor frames if current frame *should* be a blend (if metrics say it isn't):
global in_pattern = 
 \     ( usual ) ? (IsBlend_c == false) && (Isblend_n1 == false) && (frametype_p1 == 0) && (frametype_p2 != 0) && (frametype_p3 == 0)
 \   :             (IsBlend_c == false) && (Isblend_n1 == false) && (frametype_p1 == 0) && (    (frametype_p2 == 0) && (frametype_p3 != 0)
 \                                                                                           || (frametype_p2 != 0) && (frametype_p3 == 0) )
  #global in_pattern=false
  #global usual=false
#----- For 50i->24p only, prevent erroneous too-short-patterns:
       ( usual && _stringuent) ? (middle2 && pattcount<20 && pattcount>1 && lastpatt1>1) ? correct() : NOP() : NOP()
       ( usual && _stringuent) ? (pattcount==29 || pattcount==21&&pattavg>27.0) ? BreakPattern() : NOP() : NOP()
#global gnaharr = (usual ) ? middle1 && (pattcount==21-1 || pattcount==25-1 || pattcount==29-1) ? true : false : false
global gnaharr = (usual && _fulltriples) ? middle1 && (pattcount>19 || pattcount==29-1) ? true : false : false

#----- If current frame is detected or predicted as a blend, replace it:
       ( IsBlend_c || in_pattern ) ? PutPrev() : PutCurr()                             

       (frametype_c==0 && frametype_p1==0) ? CountNewPattern() : CountCurrPattern()
global  pattavg=(lastpatt3+lastpatt2+lastpatt1+lastpatt0)/4.0*(lastpatt2<2?0:1)
global ratio = ((lastpatt4-1.0)/lastpatt4 + (lastpatt3-1.0)/lastpatt3 + (lastpatt2-1.0)/lastpatt2 + (lastpatt1-1.0)/lastpatt1)/4.0
    
#----- Print debug info, if requested
       dbg ==  0 ? last : 
     \ dbg == -1 ?               last                                                  .ShowMetrics() :
     \ dbg == -2 ?               last                                                  .ShowCycles()  :
     \ dbg == -3 ?               last                                                  .ShowMetrics().ShowCycles() :
     \ dbg ==  1 ?               work.addborders(8,8,8,8).bicubicresize(cox,coy,-.2,.6).ShowMetrics() :
     \ dbg ==  2 ?               work.addborders(8,8,8,8).bicubicresize(cox,coy,-.2,.6).ShowCycles()  :
     \ dbg ==  3 ?               work.addborders(8,8,8,8).bicubicresize(cox,coy,-.2,.6).ShowMetrics().ShowCycles() :
     \ dbg == 10 ? stackvertical(work.addborders(8,8,8,8).bicubicresize(cox,coy,-.2,.6),               last) :
     \ dbg == 11 ? stackvertical(work.addborders(8,8,8,8).bicubicresize(cox,coy,-.2,.6).ShowMetrics(), last) :
     \ dbg == 12 ? stackvertical(work.addborders(8,8,8,8).bicubicresize(cox,coy,-.2,.6).ShowCycles(),  last) :
     \ dbg == 13 ? stackvertical(work.addborders(8,8,8,8).bicubicresize(cox,coy,-.2,.6).ShowMetrics().ShowCycles(), last) :
     \ dbg == 20 ? stackvertical(work.addborders(8,8,8,8).bicubicresize(cox,coy,-.2,.6),               edge_c.greyscale.addborders(8,8,8,8).bicubicresize(cox,coy,-.2,.6)) :
     \ dbg == 21 ? stackvertical(work.addborders(8,8,8,8).bicubicresize(cox,coy,-.2,.6).ShowMetrics(), edge_c.greyscale.addborders(8,8,8,8).bicubicresize(cox,coy,-.2,.6)) :
     \ dbg == 22 ? stackvertical(work.addborders(8,8,8,8).bicubicresize(cox,coy,-.2,.6).ShowCycles(),  edge_c.greyscale.addborders(8,8,8,8).bicubicresize(cox,coy,-.2,.6))
     \           : stackvertical(work.addborders(8,8,8,8).bicubicresize(cox,coy,-.2,.6).ShowMetrics().ShowCycles(), edge_c.greyscale.addborders(8,8,8,8).bicubicresize(cox,coy,-.2,.6))

    # subtitle(string(pattcount),x=222,y=222)
return( last ) 
}


###### MAIN FUNCTION ######-------------------------------------------------------------------------------------

       dummy = (dbg<4) ? out : stackvertical(out,out)      # ScriptClip's clip argument must be of same size as its output, and the
       dummy = (r24useLL && (dbg==0 || dbg>10&&dbg<14) ) 
        \    ? dummy.addborders(0,0,0,LLborder) : dummy    # output size may vary (debugging and/or LL helper).  Hence the dummy. 

#----- Conditional function chain - replaces all blends in the bobbed stream :
       c5 =             scriptclip(dummy, "Evaluate()")
       c4 =             FrameEvaluate(c5, "global IsBlend_n2 = (btest_n2<btest_n1)&&(btest_n2<btest_n3)")
 
       c3 =             FrameEvaluate(c4, "global btest_n3 = btest_n3 * 255.0 / area_n3") 
       c2 =             FrameEvaluate(c3, "global area_n3 = AverageLuma(edgearea_n3)") 

       c1 = (Eeval<3) ? FrameEvaluate(c4, "global btest_n3 = AverageLuma(edge_n3)") 
        \             : FrameEvaluate(c2, "global btest_n3 = AverageLuma(edge_n3)")

                        FrameEvaluate(c1, "ShiftBackVars()") # 

       assumetff()
       assumeframebased()
       framecache(8)
       AlreadyBobbed = last 
  
#----- Decimate the blendfree stream to destination framerate :
     # framecache(8)

       (decmode==0) ? converttoyuy2().separatefields().selectevery(4,0,3).weave() : last
       (decmode==0) ? framecache(8) : last

       (dbg   != 0) ? AlreadyBobbed :
     \ (decmode==0) ? SmartDecimate(numr, deno, bob=AlreadyBobbed, weave=AlreadyBobbed, tel=0.3, t_max=0.00000050, console=false)
     \              : TDecimate(rate=r24fps,mode=7,chroma=false  ,maxndl=mxndl,display=false) # )#

       dbg==0 ? last.trim(int(round(r24fps)),0) : last.trim(startup,0)

   #    converttoyv12()
       (decmode==0) ? framecache(8) : last

       r24useLL && dbg!=3 ? crop(0,0,0,-(LLborder)) : last
   # subtitle(string(p0lngth),x=222,y=222)
return(last)
}

#------------------------------------------------------
##### Small helpers to get modulo values
function m4(float x) {x<16?16:int(round(x/4.0)*4)}
function mod(float x, int m) {int(round(x/float(m))*m)}

##### Funky noise reduction - limit temporal softener's effect by that of a spatial softener
function LTbS(clip clp, int "nr", int "_uv")
{
#uv=2
cmod=_uv==3?1:_uv==2?0:-1
NRstr=string(nr)
spat=clp.removegrain(4,4*cmod,4*cmod).removegrain(19,19*cmod,19*cmod)
spat1=yv12lutxy(clp,spat,"x 8 + y < x 5 + x 8 - y > x 8 - x 49 * y 51 * + 100 / ? ?","x 8 + y < x 5 + x 8 - y > x 8 - x 49 * y 51 * + 100 / ? ?","x 8 + y < x 5 + x 8 - y > x 8 - x 49 * y 51 * + 100 / ? ?",U=_uv,V=_uv)
spatd=yv12lutxy(clp,spat,"x y - 128 +","x y - 128 +","x y - 128 +",U=_uv,V=_uv)
temp=clp.temporalsoften(1,111,222,24,2)
temp1=yv12lutxy(clp,temp,"x 8 + y < x 5 + x 8 - y > x 8 - x 49 * y 51 * + 100 / ? ?","x 8 + y < x 5 + x 8 - y > x 8 - x 49 * y 51 * + 100 / ? ?","x 8 + y < x 5 + x 8 - y > x 8 - x 49 * y 51 * + 100 / ? ?",U=_uv,V=_uv)
tempd=yv12lutxy(clp,temp,"x y - 128 +","x y - 128 +","x y - 128 +",U=_uv,V=_uv)
diff2=yv12lutxy(tempd,spatd,"x 128 - y 128 - * 0 < y 1 x 128 - x 128 - abs / * + x 128 - abs y 128 - abs > y 1 x 128 - x 128 - abs / * + x ? ?","x 128 - y 128 - * 0 < 128 1 x 128 - x 128 - abs / * + x 128 - abs y 128 - abs > y x ? ?","x 128 - y 128 - * 0 < 128 1 x 128 - x 128 - abs / * + x 128 - abs y 128 - abs > y x ? ?",U=_uv,V=_uv)
#diff2=yv12lutxy(tempd,spatd,"x 128 - y 128 - * 0 < x y + 2 / x 128 - abs 1 - y 128 - abs > y x ? ?","x 128 - y 128 - * 0 < 128 1 x 128 - x 128 - abs / * + x 128 - abs y 128 - abs > y x ? ?","x 128 - y 128 - * 0 < 128 1 x 128 - x 128 - abs / * + x 128 - abs y 128 - abs > y x ? ?",U=_uv,V=_uv)
 chk=yv12lutxy(tempd,spatd,"x 128 - y 128 - * 0 < 255 0 ?")
 chk2=yv12lutxy(clp,chk,"y 0 = x y ?",U=2,V=2)
 diff3=repair(tempd,spatd,1,1*cmod,1*cmod)
 out2=yv12lutxy(clp,diff3,"y 128 - abs "+NRstr+" > x "+NRstr+" y 128 - y 128 - abs / * - x y 128 - - ?","x y 128 - -","x y 128 - -",U=_uv,V=_uv)
out=yv12lutxy(clp,diff2,"y 128 - abs "+NRstr+" > x "+NRstr+" y 128 - y 128 - abs / * - x y 128 - - ?","x y 128 - -","x y 128 - -",U=_uv,V=_uv)
 #out=repair(out.sharpen(.6),clp,1,-1).mergechroma(out)
return out2 #chk2 #out
}

#==================================================================================================
#
#
#    o o o o o   o       o    o o o o        o o o o    o       o    o o o 
#        o       o       o    o		     o          o o     o    o     o
#        o       o       o    o		     o          o  o    o    o      o
#        o       o o o o o    o o o          o o o      o   o   o    o      o
#        o       o       o    o 	     o          o    o  o    o      o
#        o       o       o    o		     o          o     o o    o     o
#        o       o       o    o o o o	     o o o o    o       o    o o o
#
#
#==================================================================================================

#==================================================================================================