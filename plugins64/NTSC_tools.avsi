# NTSC tools auto NTSC to PAL with 24p, 30p, 60i detection
####
##
## NTSC tools 0.96, by Sal, aka Mug
##
## takes an NTSC clip, finds Film, 30p and 60i parts and gives them special treatment
## use it to convert to PAL with 4% speed-up (ie 23.976 to 25 fps)
##
####

function AutoPAL (clip c, clip "ext_match", bool "speedup", float "th_film", int "th_film2", int "th_prog", float "th_noise", int "th_noise2", int "th_bob", bool "show", int "mode", string "filter", bool "blend", int "deblocker", int "IVTCtype", int "precision", bool "find30p", int "reset", int "denoise",int "threads")
{
speedup=default(speedup,false)
ext_match=default(ext_match,c)
blend=default(blend,true)
th_film=default(th_film,.4)#.15)
th_film2=default(th_film2,5)
th_prog=default(th_prog,18) # 16 seems good

th_noise=default(th_noise,.5)
th_noise2=default(th_noise2,40)

th_bob=default(th_bob,8)
show=default(show,false)
mode=default(mode,1)
filter=default(filter,"last")
deblocker=default(deblocker,0)
IVTCtype = default(IVTCtype,3)	# 1 = telecide, 2 = tfm, 3 = tfm(pp=0), 4 = tdeint(mode=2), 5 = smartdecimate  ...formerly 2
precision = default(precision,1)
reset = default(reset,50)
denoise = default(denoise,0)

threads=default(threads,1)

find30p = default(find30p,false)

data= NTSCanalyse(ext_match,th_film=th_film,th_prog=th_prog, th_noise=th_noise,th_film2=th_film2,precision=precision,find30p=find30p,denoise=denoise)


threads<=1? NTSCconvert(c,data,th_bob=th_bob,speedup=speedup,show=show,mode=mode,filter=filter,blend=blend,deblocker=deblocker, IVTCtype=IVTCtype, reset=reset) :
\ mt(blackpal(c.changefps(25).framecount()),"""NTSCconvert(c,data,th_bob=th_bob,speedup=speedup,show=show,mode=mode,filter=filter,blend=blend,deblocker=deblocker, IVTCtype=IVTCtype, reset=reset)""",threads,8,true)



c.height==576? deblocker==0? c : c.converttoyv12(interlaced=true).deblocker(quant=deblocker,ipp=true) : last
}

function NTSCanalyse (clip c, float "th_film", int "th_film2", int "th_prog", int "precision", bool "show", bool "find30p", int "denoise", float "th_noise", int "th_noise2")
{
# output clip is teeny coloured clip in same space as input
# red   = FILM
# green = progressive
# blue  = interlaced

show=default(show,false)
order = c.getparity()==true? 1 : 0

global filmnum=-4
global ftype="60i"
global noise=1
global noise2=1

global th_film=default(th_film,.4)#.15)
global th_film2=default(th_film2,5)
global th_prog=default(th_prog,18) # 16 seems good

global th_noise=default(th_noise,.5)
global th_noise2=default(th_noise2,40)

precision=default(precision,1)
denoise = default(denoise,0)

find30p = default(find30p,false)

e = c.converttoyv12(interlaced=true)
d= denoise==0? 
\	c.bicubicresize(32*precision,c.height,1/3.,1/3.,16,0,c.width-32,c.height).separatefields().bicubicresize(32*precision,32*precision,1/3.,1/3.,0,8,32*precision,(c.height/2.)-16).converttoyv12()
\ :	c.bicubicresize(32*precision,c.height,1/3.,1/3.,16,0,c.width-32,c.height).separatefields().bicubicresize(32*precision,32*precision,1/3.,1/3.,0,8,32*precision,(c.height/2.)-16).converttoyv12().weave().temporalsoften(5,denoise,0).separatefields()

global film_c = d
global film_d = d.selectevery(2,0)

weavemask=e.mt_edge("0 -1 0 0 2 0 0 -1 -0 2",0,255,y=3,u=3,v=3)
separatemask=e.separatefields().mt_edge("0 -1 0 0 2 0 0 -1 -0 2",0,255,y=3,u=3,v=3).weave()

global f01	= mt_lutxy(weavemask,separatemask,expr="x y -").mt_inpand(mode=mt_rectangle(0,2))

global f02	= mt_lutxy(film_c.selectevery(2,0),	film_c.selectevery(2,2),expr="x y - abs")
global f13	= mt_lutxy(film_c.selectevery(2,1),	film_c.selectevery(2,3),expr="x y - abs")
global b1f1	= mt_lutxy(film_c.selectevery(2,-1),	film_c.selectevery(2,1),expr="x y - abs")
global b02	= mt_lutxy(film_c.selectevery(2,0),	film_c.selectevery(2,-2),expr="x y - abs")
global f24	= mt_lutxy(film_c.selectevery(2,2),	film_c.selectevery(2,4),expr="x y - abs")
global b13	= mt_lutxy(film_c.selectevery(2,-1),	film_c.selectevery(2,-3),expr="x y - abs")
global b24	= mt_lutxy(film_c.selectevery(2,-2),	film_c.selectevery(2,-4),expr="x y - abs")
global f35	= mt_lutxy(film_c.selectevery(2,3),	film_c.selectevery(2,5),expr="x y - abs")
global b35	= mt_lutxy(film_c.selectevery(2,-3),	film_c.selectevery(2,-5),expr="x y - abs")

global NTSCanalyse_red   = blankclip(film_d,width=8,height=4,color=$ff0000)
global NTSCanalyse_green = blankclip(film_d,width=8,height=4,color=$00ff00)
global NTSCanalyse_blue  = blankclip(film_d,width=8,height=4,color=$0000ff)

film_d1 =    scriptclip(NTSCanalyse_blue,""" ftype=="24p" ? NTSCanalyse_red : ftype=="30p" ? NTSCanalyse_green : NTSCanalyse_blue """)

film_d2 = find30p==true? frameevaluate(film_d1,""" ftype = f01.yplanemax() <= th_prog ? "30p" : ftype """) : frameevaluate(film_d1,"NOP")
film_d3 = frameevaluate(film_d2,""" 
\	ftype = (noise2==1)? ftype : ftype != "24p"? "60i" : (b1f1.yplanemax() < th_film2) ? "24p" : 
\	max(f02.yplanemax(),b35.yplanemax()) < th_film2 ? "24p" : 
\	max(b02.yplanemax(),f35.yplanemax()) < th_film2 ? "24p" : 
\	max(b13.yplanemax(),f24.yplanemax()) < th_film2 ? "24p" : 
\	max(f13.yplanemax(),b24.yplanemax()) < th_film2 ? "24p" : 
\	max(f24.yplanemax(),b13.yplanemax()) < th_film2 ? "24p" : 
\	max(b24.yplanemax(),f13.yplanemax()) < th_film2 ? "24p" : "60i" """)

film_d4 = frameevaluate(film_d3,""" 
\	ftype = (noise==1)? ftype : (b1f1.averageluma() < th_film) ? "24p" : 
\	max(f02.averageluma(),b35.averageluma()) < th_film ? "24p" : 
\	max(b02.averageluma(),f35.averageluma()) < th_film ? "24p" : 
\	max(b13.averageluma(),f24.averageluma()) < th_film ? "24p" : 
\	max(f13.averageluma(),b24.averageluma()) < th_film ? "24p" : 
\	max(f24.averageluma(),b13.averageluma()) < th_film ? "24p" : 
\	max(b24.averageluma(),f13.averageluma()) < th_film ? "24p" : "60i" """)

film_d5 = frameevaluate(film_d4,""" 
\	noise= (b1f1.averageluma() > th_noise) ? 0 : 
\	max(f02.averageluma(),b35.averageluma()) > th_noise ? 0 : 
\	max(b02.averageluma(),f35.averageluma()) > th_noise ? 0 : 
\	max(b13.averageluma(),f24.averageluma()) > th_noise ? 0 : 
\	max(f13.averageluma(),b24.averageluma()) > th_noise ? 0 : 
\	max(f24.averageluma(),b13.averageluma()) > th_noise ? 0 : 
\	max(b24.averageluma(),f13.averageluma()) > th_noise ? 0 : 1 """)

film_d6 = frameevaluate(film_d5,""" 
\	noise2= (b1f1.yplanemax() > th_noise2) ? 0 : 
\	max(f02.yplanemax(),b35.yplanemax()) > th_noise2 ? 0 : 
\	max(b02.yplanemax(),f35.yplanemax()) > th_noise2 ? 0 : 
\	max(b13.yplanemax(),f24.yplanemax()) > th_noise2 ? 0 : 
\	max(f13.yplanemax(),b24.yplanemax()) > th_noise2 ? 0 : 
\	max(f24.yplanemax(),b13.yplanemax()) > th_noise2 ? 0 : 
\	max(b24.yplanemax(),f13.yplanemax()) > th_noise2 ? 0 : 1 """)



show==true? overlay(c,film_d6) : film_d6

show==true? scriptclip(""" subtitle("max pixel difference = "+
\	string(max(b1f1.yplanemax(),
\	f02.yplanemax(),b35.yplanemax(),
\	b02.yplanemax(),f35.yplanemax(),
\	b13.yplanemax(),f24.yplanemax(),
\	f13.yplanemax(),b24.yplanemax(),
\	f24.yplanemax(),b13.yplanemax(),
\	b24.yplanemax(),f13.yplanemax()))+", max avg luma diff = "+
\	string(max(b1f1.averageluma(),
\	f02.averageluma(),b35.averageluma(),
\	b02.averageluma(),f35.averageluma(),
\	b13.averageluma(),f24.averageluma(),
\	f13.averageluma(),b24.averageluma(),
\	f24.averageluma(),b13.averageluma(),
\	b24.averageluma(),f13.averageluma()))
\	+", noise1 = "+string(noise)+", noise2 = "+string(noise2)) """) : last

}

function NTSCconvert (clip c, clip data, bool "speedup", int "th_bob", int "mode", bool "show", string "filter", bool "blend", int "deblocker",int "IVTCtype", int "reset")
{
# mode 1 = blend non-film frames to 50i
# mode 2 = try to motion-compensate non-film frames to 25p or 50i

speedup=default(speedup,true)
th_bob=default(th_bob,2)
blend=default(blend,true)
mode=default(mode,1)
show=default(show,false)
filter = default(filter,"last")
deblocker = default(deblocker,0)
IVTCtype = default(IVTCtype,3)	# 1 = telecide, 2 = tfm(chroma=true), 3 = tfm(), 4 = tdeint(mode=2) 5 = smartdecimate
reset = default(reset,50)

outnum = speedup==true? 48000 : 50000
outden = speedup==true? 1001 : 1000

order = c.getparity()==true? 1 : 0

d = deblocker==0? c : c.converttoyv12(interlaced=true).deblocker(quant=deblocker,ipp=true)
d = mode==1? d : d.converttoyv12(interlaced=true)

global bobbed = d.tdeint(1,order,expand=4,mthreshl=th_bob)
sdbob = d.tdeint(1,order,expand=4,mi=24,cthresh=8,mthreshl=th_bob,tryweave=true)

NTSCconvert_60i = mode==1? bobbed.vinverse().blendfps(outnum/float(outden),1.25).changefps(outnum,outden).resizetopal(false,false) : bobbed.vinverse().converttoyv12(interlaced=false).salfps(outnum/float(outden),protection2=60,reset=reset).changefps(outnum,outden).resizetopal(false,false)
NTSCconvert_30p = d.converttoyv12().vinverse().salfps(outnum/float(2*outden),protection2=50,reset=reset).resizetopal(false,false).changefps(outnum/2,outden)

IVTCtype==1? d.telecide(order=order,guide=1).decimate() :\
IVTCtype==2? d.tfm(order=order,pp=0,chroma=true).decimate() :\
IVTCtype==3? d.tfm(order=order,pp=0,chroma=false).decimate() :\
IVTCtype==4? d.tdeint(2,-1,expand=4,tryweave=true,cthresh=3,mi=24,mthreshl=8,chroma=true).decimate() :\
d.smartdecimate(24,60,bob=sdbob,tel=1.)

vinverse()
resizetopal(false,false)

eval(filter)
NTSCconvert_24pfilter = last

global NTSCconvert_24p = speedup==true?
\ NTSCconvert_24pfilter.changefps(outnum/2,outden) : 
\ (blend==true)? NTSCconvert_24pfilter.blendfps(50,1.25).changefps(outnum,outden).interlace(order=1):
\ NTSCconvert_24pfilter.changefps(outnum,outden).interlace(order=1)

NTSCconvert_60i
eval(filter)

interlace(order=1)
global NTSCconvert_60i = last

NTSCconvert_30p
eval(filter)
#mode==1? last : last.interlace(order=1)
global NTSCconvert_30p = last


global NTSCconvert_data 		= data.assumetff().blendfps(outnum/float(outden*2),2.).changefps(outnum/2,outden)
#global NTSCconvert_data 		= data.changefps(outnum/2,outden)
#global NTSCconvert_data 		= data.assumetff().medianblurt(0,0,2).changefps(outnum/2,outden)

global NTSCconvert_red		= blankclip(NTSCconvert_data,color=$ff0000)
global NTSCconvert_green	= blankclip(NTSCconvert_data,color=$00ff00)
global NTSCconvert_blue		= blankclip(NTSCconvert_data,color=$0000ff)

global NTSCconvert_isred	= mt_lutxy(NTSCconvert_red,NTSCconvert_data,yexpr="x y - abs",y=3,u=1,v=1)
global NTSCconvert_isgreen	= mt_lutxy(NTSCconvert_green,NTSCconvert_data,yexpr="x y - abs",y=3,u=1,v=1)

mode==1? scriptclip(NTSCconvert_24p,"yplanemax(NTSCconvert_isred)==0 ? NTSCconvert_24p : NTSCconvert_60i") : scriptclip(NTSCconvert_24p,"yplanemax(NTSCconvert_isred)==0 ? NTSCconvert_24p : yplanemax(NTSCconvert_isgreen)==0 ? NTSCconvert_30p : NTSCconvert_60i")
speedup==true? last.assumefps(25,true).SSRC(48000) : last

show==true? overlay(last,data.changefps(outnum/2,outden)) : last
assumetff()

c.height==576? c : last
trim(0,c.changefps(outnum/2,outden).framecount())
}


function NTSCfilter (clip c, clip data, string filter, bool "show")
{

show=default(show,false)
order = c.getparity()==true? 1 : 0
bobbed = c.assumeframebased().leakkernelbob(order=order,threshold=2)

bobbed.selecteven()
eval(filter)
evn=last
bobbed.selectodd()
eval(filter)
odd=last
interleave(evn,odd)
interlace(order=order)
global NTSCfilter_60i = last

c
eval(filter)
global NTSCfilter_30p = last

c.tdeint(2,1,tryweave=true,cthresh=2,mi=24,mtnmode=1,mthreshl=2).decimate()
eval(filter)
changefps(c.framerate*2).interlace(order=order)
global NTSCfilter_24p = last

global NTSCfilter_data  = data

global NTSCfilter_red   = blankclip(NTSCfilter_data,color=$ff0000)
global NTSCfilter_green = blankclip(NTSCfilter_data,color=$00ff00)

global NTSCfilter_isred   = mt_lutxy(NTSCfilter_red,NTSCfilter_data,yexpr="x y - abs",y=3,u=1,v=1)
global NTSCfilter_isgreen = mt_lutxy(NTSCfilter_green,NTSCfilter_data,yexpr="x y - abs",y=3,u=1,v=1)

scriptclip(NTSCfilter_30p,"yplanemax(NTSCfilter_isred)==0 ? NTSCfilter_24p : yplanemax(NTSCfilter_isgreen)==0 ? NTSCfilter_30p : NTSCfilter_60i")

show==true? overlay(last,NTSCfilter_data) : last
}


function NTSC120 (clip c, clip data, bool "show")
{

show=default(show,false)
order = c.getparity()==true? 1 : 0
bobbed = c.tdeint(1,order,expand=4,mi=24,cthresh=8,mthreshl=8,tryweave=true).vinverse()#leakkernelbob(order=order,threshold=2)


global NTSCfilter_60i = bobbed.changefps(120000,1001)
global NTSCfilter_30p = c.changefps(120000,1001)
global NTSCfilter_24p = bobbed.decimate().changefps(120000,1001)

global NTSCfilter_data  = data.changefps(120000,1001)

global NTSCfilter_red   = blankclip(NTSCfilter_data,color=$ff0000)
global NTSCfilter_green = blankclip(NTSCfilter_data,color=$00ff00)

global NTSCfilter_isred   = mt_lutxy(NTSCfilter_red,NTSCfilter_data,yexpr="x y - abs",y=3,u=1,v=1)
global NTSCfilter_isgreen = mt_lutxy(NTSCfilter_green,NTSCfilter_data,yexpr="x y - abs",y=3,u=1,v=1)

scriptclip(NTSCfilter_30p,"yplanemax(NTSCfilter_isred)==0 ? NTSCfilter_24p : yplanemax(NTSCfilter_isgreen)==0 ? NTSCfilter_30p : NTSCfilter_60i")

show==true? overlay(last,NTSCfilter_data) : last
}


function NTSCtoFPS (clip c, clip data, int "num", int "den", int "th_bob", bool "show", string "filter", int "deblocker",int "IVTCtype", int "reset")
{

num=default(num,24000)
den=default(den,1001)

th_bob=default(th_bob,2)
show=default(show,false)
filter = default(filter,"last")
deblocker = default(deblocker,0)
IVTCtype = default(IVTCtype,3)	# 1 = telecide, 2 = tfm(chroma=true), 3 = tfm(), 4 = tdeint(mode=2) 5 = smartdecimate
reset = default(reset,50)

order = c.getparity()==true? 1 : 0

d = deblocker==0? c : c.converttoyv12(interlaced=true).deblocker(quant=deblocker,ipp=true)
d = d.converttoyv12(interlaced=true)

global bobbed = d.tdeint(1,order,expand=4,mthreshl=th_bob)
sdbob = d.tdeint(1,order,expand=4,mi=24,cthresh=8,mthreshl=th_bob,tryweave=true)

NTSCtoFPS_60i = bobbed.vinverse().converttoyv12(interlaced=false).salfps(num/float(den),protection2=60,reset=reset).changefps(num,den)
NTSCtoFPS_30p = d.converttoyv12().vinverse().salfps(num/float(den),protection2=50,reset=reset).changefps(num,den)

IVTCtype==1? d.telecide(order=order,guide=1).decimate() :\
IVTCtype==2? d.tfm(order=order,pp=0,chroma=true).decimate() :\
IVTCtype==3? d.tfm(order=order,pp=0,chroma=false).decimate() :\
IVTCtype==4? d.tdeint(2,-1,expand=4,tryweave=true,cthresh=3,mi=24,mthreshl=8,chroma=true).decimate() :\
d.smartdecimate(24,60,bob=sdbob,tel=1.)

vinverse()

eval(filter)

salfps(num/float(den),protection2=50).changefps(num,den)

global NTSCtoFPS_24p = last


NTSCtoFPS_60i
eval(filter)

global NTSCtoFPS_60i = last

NTSCtoFPS_30p
eval(filter)

global NTSCtoFPS_30p = last


global NTSCtoFPS_data 		= data.assumetff().blendfps(num/float(den),2.).changefps(num,den)

global NTSCtoFPS_red		= blankclip(NTSCtoFPS_data,color=$ff0000)
global NTSCtoFPS_green	= blankclip(NTSCtoFPS_data,color=$00ff00)
global NTSCtoFPS_blue		= blankclip(NTSCtoFPS_data,color=$0000ff)

global NTSCtoFPS_isred	= mt_lutxy(NTSCtoFPS_red,NTSCtoFPS_data,yexpr="x y - abs",y=3,u=1,v=1)
global NTSCtoFPS_isgreen	= mt_lutxy(NTSCtoFPS_green,NTSCtoFPS_data,yexpr="x y - abs",y=3,u=1,v=1)

scriptclip(NTSCtoFPS_24p,"yplanemax(NTSCtoFPS_isred)==0 ? NTSCtoFPS_24p : yplanemax(NTSCtoFPS_isgreen)==0 ? NTSCtoFPS_30p : NTSCtoFPS_60i")

show==true? overlay(last,NTSCtoFPS_data) : last
assumetff()

c.height==576? c : last
}


function resizetopal (clip c, bool "soft", bool "speedup")
{
soft=default(soft,false)
speedup=default(speedup,true)

soft==false? c.addborders(0,2,0,2).lanczosresize(c.width,576,0,2+(c.height-483.84)/2,c.width,483.84) : c.addborders(0,2,0,2).bicubicresize(c.width,576,1,0,0,2+(c.height-483.84)/2,c.width,483.84)
speedup==true? last.assumefps(25,true).SSRC(48000) : last
c.height==576? c : last
}

function interlace (clip interlace_c, int "order")
{
order=default(order,1)
interlace_d= interlace_c.framecount()%2==0? interlace_c : interlace_c.assumefps(interlace_c.framerate)++interlace_c.selectevery(interlace_c.framecount,interlace_c.framecount-1).assumefps(interlace_c.framerate)
order==1? interlace_d.assumeframebased().assumetff().separatefields().selectevery(4,0,3).weave() :
\	interlace_d.assumeframebased().assumebff().separatefields().selectevery(4,0,3).weave()
}


function deblocker (clip c,int "quant",int "th",int "radius", bool "deblock",bool "depump",bool "conv",bool "ipp",int "modh", int "modv")
{

quant=default(quant,8)
th=default(th,3)
radius=default(radius,8)
deblock=default(deblock,true)
depump=default(depump,false)
conv=default(conv,false)
ipp=default(ipp,false)
modh=default(modh,20)
modv=default(modv,40)

c = (c.width*c.height%256==0)? c : mod16(c)#.limiter()

blurd = (conv==true)?c.wideblur(4,conv): (depump==true)? c.bilinearresize(4*(c.width/8),4*(c.height/8)) : c.bilinearresize(4*(c.width/8),4*(c.height/8)).bicubicresize(c.width,c.height,1,0)

highpass=(conv==true)?mt_makediff(blurd,c,y=3,u=3,v=3): (depump==true)? mt_makediff(blurd.bicubicresize(c.width,c.height,1,0),c,y=3,u=3,v=3) : mt_makediff(blurd,c,y=3,u=3,v=3)
deblocked=(deblock==true) ? highpass.blindpp(quant=quant,cpu=4,ipp=ipp,moderate_h=modh,moderate_v=modv) : highpass

nopump=mt_makediff(blurd,deblocked,y=3,u=3,v=3)

depumped=blurd.temporalsoften(2,th,th,32,2)#.removedirt()

pump=(conv==true)?mt_makediff(depumped,deblocked,y=3,u=3,v=3):mt_makediff(depumped.bicubicresize(c.width,c.height,1,0),deblocked,y=3,u=3,v=3)

(depump==true) ? pump : nopump

(c.width*c.height%256==0)? last : unmod16(last)
}

function combblur(clip c, int threshold)
{
mt_merge(c.mt_convolution("1","1 2 1",y=3,u=3,v=3).mt_convolution("1","-1 6 -1",y=3,u=3,v=3),c,c.combmask(threshold,threshold,y=3,u=3,v=3).mt_expand(mode=mt_rectangle(0,1),y=3,u=3,v=3).mt_inflate(y=3,u=3,v=3),y=3,u=3,v=3)
}


function salblendfps(clip c, float fps, float "aperture")
{
aperture = default(aperture,1.)

c.changefps(8*fps).temporalsoften(round(8*aperture),255,255,24).selectevery(8,0)
}

function salFPS(
 \ clip input, float FPS, 
 \ int "mode", int "protection", int "protection2",
 \ int "iterate", int "reset", int "initialise", bool "interlaced")
{
mode       = default(mode, warp)#warpfast)
protection = default(protection, 80)
protection2 = default(protection2, 32)
iterate    = default(iterate, 2)
reset      = default(reset, 50)
initialise = default(initialise, 6)
interlaced = default(interlaced,false)

originalFPS = input.framerate()
input

mp    = FindMotion(iterate = iterate, reset = reset,
 \       initialise = initialise)
p     = MotionFPS(FPS,mode,Motion = mp)
maskp = mp.SumStretchFPSMask(FPS, protection)

mn    = FindMotion(iterate = iterate, reset = reset,
 \       initialise = initialise, from = next)
n     = MotionFPS(FPS,mode,Motion = mn, source = next)
maskn = mn.SumStretchFPSMask(FPS, protection, source = next)

maskp
assumeFPS(originalFPS)

tehmask=last.CombineFPS(FPS, maskp, maskn)
last.CombineFPS(FPS, maskp, maskn.Invert())
bilinearresize(width*8, height*8)
crop(0, 0, input.width(), input.height())
fity2uv()
mpro=last

tehmask
mt_deflate()
mt_binarize(protection2,false)
temporalsoften(1,255,255,255)
mt_binarize(80,false)
mt_expand(mode=mt_circle(3))
mt_inflate()
bicubicresize(width*8, height*8,1,0)
crop(0, 0, input.width(), input.height())
fity2uv()
tehmask=last
mt_merge(p, n, mpro, u=3, v=3)

interlaced==false? mt_merge(last,input.blendfps(FPS,aperture=FPS/float(input.framerate())),tehmask, u=3,v=3) :
\	mt_merge(last.changefps(FPS,false).selectevery(1,0,0),input.blendfps(2*FPS,aperture=FPS/float(input.framerate())),tehmask, u=3,v=3).interlace()
#merge(last,tehmask.greyscale(),.5)
}


function blackPAL (int "length", int "colour")
{
length = default(length,250)
colour = default(colour,$000000)

blankclip(width=720,height=576,fps=25000,fps_denominator=1000,pixel_type="yv12",length=length,audio_rate=48000,stereo=true,color=colour)
}

