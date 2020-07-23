###### srestore v2.7e ######

function srestore(clip source, float "frate", "omode", float "speed", float "blocks", int "mode", float "thresh", int "cache", clip "dclip")
{
###### parameters & other necessary vars ######
    srad  = isfloat(speed) && abs(speed)>=1 ? sqrt(abs(speed))*4 : 12
    cache = default(cache,-1)
    irate = framerate(source)
    bsize = isfloat(speed) && speed>0 ? 16 : 32

try
{
    err__ = defined(func_call) ? "twice" : "something_else"
}
catch(err_msg)
{
    err__ = err_msg
}
assert(err__!="twice", "ERROR: SRESTORE CAN ONLY CALLED ONCE!!!")
global func_call    = 1

global  dm      = default(mode,2)
global  om      = default(omode,6)
global  bom     = isstring(om)
global  thr     = abs(default(thresh,16))+0.01
global  frfac   = bom || abs(om-3)<2.5 ? 1 : isfloat(frate) ? frate*5<irate || frate>irate ? 1 :
                \ abs(frate)/irate : round(irate*10010)%30000==0 ? 1001./2400. : 480./1001.

global  numr    = abs(frfac*1001-round(frfac*1001))<0.01 ? round(frfac*1001) :
                \ abs(1001/frfac-round(1001/frfac))<0.01 ? 1001 : round(frfac*9000)
global  numr    = isfloat(frate) && abs(irate*numr/float(round(numr/frfac))-frate) >
                \ abs(irate*round(frate*100)/float(round(irate*100))-frate) ? round(frate*100) : numr
global  denm    = round(numr/frfac)


###### source preparation & lut ######
global  out = source
global  mec = abs(dm)<2 || bom ? nop() : mergeluma(mergechroma(out,out.trim(1,0),0.5),out.trim(1,0),0.5)
global  det	= default(dclip,source).killaudio.converttoyv12
global  det	= det.pointresize(srad==4 ? det.width : int(det.width/2/srad+4)*4, srad==4 ? det.height : int(det.height/2/srad+4)*4).trim(2,0)
global  det	= dm<0 ? stackvertical(stackhorizontal(det.utoy,det.vtoy),det) : det
global  det = bom ? det.mt_lut("x 0.5 * 64 +",y=3,u=1,v=1) : det

    code0   = "x 128 - y 128 - * 0 > x 128 - abs y 128 - abs < x 128 - 128 x - * y 128 - 128 y - * ? x y + 256 - x y + 256 - * ? 0.25 * 128 +"
    code1   = "x y - 2 ^ 3 * x y + 256 - 2 ^ - 128 +"
	diff 	= mt_makediff(det,det.trim(1,0),y=3,u=1,v=1)
global  bclp    = bom==false ? mt_lutxy(diff,diff.trim(1,0),expr=code0,y=3,u=1,v=1).bilinearresize(bsize,bsize) :
                \ mt_lutxy(diff.trim(1,0),mt_adddiff(diff,diff.trim(2,0),y=3,u=1,v=1),expr=code1,y=3,u=1,v=1).bilinearresize(bsize,bsize)
global  dclp    = diff.trim(1,0).mt_lut("x 128 - abs 1.1 ^ 1 -",y=3,u=1,v=1).bilinearresize(bsize,bsize)


###### POSTPROCESSING ######
    unblend1    = bom ? average(out.loop(2,0,0), -1.0, out, 2.0) : nop()
    unblend2    = bom ? average(out.trim(1,0), 2.0, out.trim(2,0), -1.0) : nop()

    qmask1  = bom ? mt_makediff(unblend1.removegrain(mode=19,modeU=-1,modeV=-1),unblend1,y=3,u=1,v=1) : nop()
    qmask2  = bom ? mt_makediff(unblend2.removegrain(mode=19,modeU=-1,modeV=-1),unblend2,y=3,u=1,v=1) : nop()
    diffm   = bom ? mt_makediff(out.loop(2,0,0),out,y=3,u=1,v=1).mt_lut("x y - abs",y=3,u=1,v=1).mt_expand() : nop()
    bmask	= bom ? mt_lutxy(qmask1,qmask2,expr="x y - == 128 x 128 - 2 ^ x 128 - 2 ^ y 128 - 2 ^ + / 255 *",y=3,u=1,v=1) : nop()
    dmask	= bom ? mt_lutxy(diffm,diffm.trim(2,0),expr="x 2 * y < x 4 < & 0 y 2 * x < y 4 < & 255 x x y + / 200 * 28 + ? ?",y=3,u=1,v=1) : nop()
    pmask	= bom ? mt_lutxy(dmask, bmask, expr="y 0 > y 255 < & x 0 == x 255 == | & x y ?",y=3,u=1,v=1) : nop()

    pp0 = bom ? average(out.loop(2,0,0), -0.5, out, 1.0, out.trim(1,0), 1.0, out.trim(2,0), -0.5) : nop()
    pp1 = bom ? mt_merge(unblend1,unblend2,dmask.removegrain(mode=12,modeU=-1,modeV=-1).greyscale(),y=3,u=3,v=3) : nop()
    pp2 = bom ? mt_merge(unblend1,unblend2,bmask.removegrain(mode=12,modeU=-1,modeV=-1),luma=true) : nop()
    pp3 = bom ? mt_merge(unblend1,unblend2,pmask.removegrain(mode=12,modeU=-1,modeV=-1),luma=true).removegrain(mode=0,modeU=12,modeV=12) : nop()

global  fin  = bom ? eval(om) : nop()


###### initialise variables ######
global  lfr     = -100
global  offs    = 0
global  ldet    = -100
global  lpos    = 0


###### evaluation call & output calculation ######
scriptclip( source, "srestore_inside(current_frame)")


###### final decimation & caching ######
cache<0 ? last : last.RequestLinear(8, cache, 5, false, false)

    temp    = frameratenumerator(det)*float(numr)>2147483600. ? det.assumescaledfps(numr,denm) : nop()
isclip(temp) ? last.changefps(temp,linear=true) : last.changefps(frameratenumerator(source)*numr,frameratedenominator(source)*denm,linear=true)


return last
}

function srestore_inside(clip c, int current_frame) {

 ### preparation ###
        cfr = current_frame
        jmp = lfr+1==cfr
        cfo = (((cfr%denm)*numr*2+denm+(versionnumber()>2.575 ? numr : 0))%(2*denm))-denm
        bfo = cfo>-numr && cfo<=numr

    global  lfr     = cfr
    global  offs    = bfo && offs<=-4*numr ? offs+2*denm : bfo && offs>=4*numr ? offs-2*denm : offs

        pos = frfac==1 ? 0 : bfo ? -round((cfo+offs)/(2.*numr)) : lpos
        cof = cfo+offs+2*numr*pos

    global  ldet    = cfr+pos==ldet ? -1 : cfr+pos

  ## diff value shifting ##
        d_v = yplanemax(dclp)+.015625
        d43 = jmp ? d32 : d_v
global 	d32 = jmp ? d21 : d_v
global	d21 = jmp ? d10 : d_v
global	d10 = jmp ? d01 : d_v
global	d01 = jmp ? d12 : d_v
global	d12 = jmp ? d23 : d_v
global	d23 = jmp ? d34 : d_v
global  d34 = d_v

  ## diff value shifting ##
        m_v = isfloat(om) && abs(om)>5 ? lumadifference(det,det.trim(2,0))+.015625 : 1
        m53 = jmp ? m42 : m_v
global 	m42 = jmp ? m31 : m_v
global  m31 = jmp ? m20 : m_v
global	m20 = jmp ? m11 : m_v
global	m11 = jmp ? m02 : m_v
global	m02 = jmp ? m13 : m_v
global	m13 = jmp ? m24 : m_v
global  m24 = m_v

  ## get blend and clear values ##
        b_v = 128-yplanemin(bclp)
        b_v = b_v<1 ? .125 : b_v
        c_v = yplanemax(bclp)-128
        c_v = c_v<1 ? .125 : c_v

  ## blend value shifting ##
        bp3 = jmp ? bp2 : bom ? b_v-c_v : b_v
global 	bp2	= jmp ? bp1 : bp3
global	bp1	= jmp ? bn0 : bp3
global	bn0	= jmp ? bn1 : bp3
global	bn1	= jmp ? bn2 : bp3
global	bn2	= jmp ? bn3 : bp3
global	bn3 = bom ? b_v-c_v : b_v

  ## clear value shifting ##
	    cp3	= jmp ? cp2 : c_v
global	cp2	= jmp ? cp1 : c_v
global	cp1	= jmp ? cn0 : c_v
global	cn0 = jmp ? cn1 : c_v
global	cn1 = jmp ? cn2 : c_v
global	cn2 = jmp ? cn3 : c_v
global	cn3 = c_v

  ## used detection values ##
        bb  = select(pos+2,bp3,bp2,bp1,bn0,bn1)
        bc  = select(pos+2,bp2,bp1,bn0,bn1,bn2)
        bn  = select(pos+2,bp1,bn0,bn1,bn2,bn3)

        cb  = select(pos+2,cp3,cp2,cp1,cn0,cn1)
        cc  = select(pos+2,cp2,cp1,cn0,cn1,cn2)
        cn  = select(pos+2,cp1,cn0,cn1,cn2,cn3)

        dbb = select(pos+2,d43,d32,d21,d10,d01)
        dbc = select(pos+2,d32,d21,d10,d01,d12)
        dcn = select(pos+2,d21,d10,d01,d12,d23)
        dnn = select(pos+2,d10,d01,d12,d23,d34)
        dn2 = select(pos+2,d01,d12,d23,d34,d34)

        mb1 = select(pos+2,m53,m42,m31,m20,m11)
        mb  = select(pos+2,m42,m31,m20,m11,m02)
        mc  = select(pos+2,m31,m20,m11,m02,m13)
        mn  = select(pos+2,m20,m11,m02,m13,m24)
        mn1 = select(pos+2,m11,m02,m13,m24,.01)


 ### basic calculation ###
        bbool   = .8*bc*cb>bb*cc && .8*bc*cn>bn*cc && bc*bc>cc
        blend   = bbool && bc*5>cc && dbc+dcn>1.5*thr && (dbb<7*dbc || dbb<8*dcn) && (dnn<8*dcn || dnn<7*dbc) &&
                \ (mb<mb1 && mb<mc || mn<mn1 && mn<mc || (dbb+dnn)*4<dbc+dcn || (bb*cc*5<bc*cb || mb>thr) && (bn*cc*5<bc*cn || mn>thr) && bc>thr)

        clear   = dbb+dbc>thr && dcn+dnn>thr && (bc<2*bb || bc<2*bn) && (dbb+dnn)*2>dbc+dcn && (mc<.96*mb && mc<.96*mn && (bb*2>cb || bn*2>cn) &&
                \ cc>cb && cc>cn || frfac>.45 && frfac<.55 && .8*mc>mb1 && .8*mc>mn1 && mb>.8*mn && mn>.8*mb)

        highd   = dcn>5*dbc && dcn>5*dnn && dcn>thr && dbc<thr && dnn<thr

        lowd    = dcn*5<dbc && dcn*5<dnn && dbc>thr && dnn>thr && dcn<thr && frfac>.35 && (frfac<.51 || dcn*5<dbb)

        res     = d43<thr && d32<thr && d21<thr && d10<thr && d01<thr && d12<thr && d23<thr && d34<thr ||
                \ dbc*4<dbb && dcn*4<dbb && dnn*4<dbb && dn2*4<dbb || dcn*4<dbc && dnn*4<dbc && dn2*4<dbc


 ### offset calculation ###
        odm     = blend ? denm : clear ? 0 : highd ? denm-numr : lowd ? 2*denm-numr : cof
        odm     = odm+round((cof-odm)/(2.*denm))*2*denm
        odr     = (blend ? denm-numr : clear ? numr : highd ? numr : frfac<0.5 ? 2*numr : 2*(denm-numr)) * .9

        cof     = ldet<0 ? cof : cof>odm+odr ? cof-offs-odm-odr>denm && res ? odm+2*denm-odr : odm+odr : cof<odm-odr ?
                \ offs>denm && res ? odm-2*denm+odr : odm-odr : offs<-1.15*denm && res ? cof+2*denm : offs>1.25*denm && res ? cof-2*denm : cof

    global  offs    = frfac==1 ? 0 : cof-cfo-2*numr*pos
    global  lpos    = pos
        opos    = frfac==1 ? 0 : -round((cfo+offs+(bfo && offs<=-4*numr ? denm : 0))/(2.*numr))
        pos     = opos<-2 ? -2 : opos>2 ? 2 : opos


 ### frame output calculation - resync - dup ###
        dbb = select(pos+2,d43,d32,d21,d10,d01)
        dbc = select(pos+2,d32,d21,d10,d01,d12)
        dcn = select(pos+2,d21,d10,d01,d12,d23)
        dnn = select(pos+2,d10,d01,d12,d23,d34)

  ## dup_hq - merge ##
        dup     = opos!=pos || abs(dm)<2 || abs(dm)==3 ? 0 : dcn*5<dbc && dnn*5<dbc && (dcn<1.25*thr || bn<bc && pos==lpos) ||
                \ (dcn*dcn<dbc || dcn*5<dbc) && bn<bc && pos==lpos && dnn<.9*dbc || dnn*9<dbc && dcn*3<dbc ? 1 :
                \ (dbc*dbc<dcn || dbc*5<dcn) && bb<bc && pos==lpos && dbb<.9*dcn || dbb*9<dcn && dbc*3<dcn ||
                \ dbb*5<dcn && dbc*5<dcn && (dbc<1.25*thr || bb<bc && pos==lpos) ? -1 : 0
        mer     = bom==false && opos==pos && dup==0 && abs(dm)>2 && (dbc*8<dcn || dbc*8<dbb || dcn*8<dbc || dcn*8<dnn || dbc*2<thr ||
                \ dcn*2<thr || dnn*9<dbc && dcn*3<dbc || dbb*9<dcn && dbc*3<dcn)

  ## deblend - doubleblend removal - postprocessing ##
        add     = bp1*cn2>bn2*cp1*(1+thr*.01) && bn0*cn2>bn2*cn0*(1+thr*.01) && cn2*bn1>cn1*bn2*(1+thr*.01)
        dup     = bom ? (bn0>bp2 && bn0>=bp1 && bn0>bn1 && bn0>bn2 && cn0<125 ? (d12*d12<d10 || d12*9<d10) ? 1 :
                \ (d10*d10<d12 || d10*9<d12) ? 0 : 4 : bp1>bp3 && bp1>=bp2 && bp1>bn0 && bp1>bn1 ? 1 : 0) :
                \ dup!=0 ? dup : om>0 && om<5 ? (bbool==false ? 0 : om==4 && bp1*cn1<bn1*cp1 || om==3 && d10<d01 || om==1 ? -1 : 1) :
                \ om==5 ? (bp1*cp2>bp2*cp1*(1+thr*.01) && bn0*cp2>bp2*cn0*(1+thr*.01) && cp2*bn1>cn1*bp2*(1+thr*.01) && (add==false || cp2*bn2>cn2*bp2) ?
                \ -2 : add ? 2 : bn0*cp1>bp1*cn0 && (bn0*cn1<bn1*cn0 || cp1*bn1>cn1*bp1) ? -1 : bn0*cn1>bn1*cn0 ? 1 : 0) : 0


 ### output clip ###
    oclp    = mer && dup==0 ? mec : out
        opos    = opos + dup - (dup==0 && mer && dbc<dcn ? 1 : 0)
    dup==4 ? fin : opos<0 ? oclp.loop(1-opos,0,0) : oclp.trim(opos,0)
}