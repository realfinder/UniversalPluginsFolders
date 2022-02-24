### DON'T DELETE ME!!! ###

function CPostProcessingMask(clip src, clip "bob", int "nt", bool "isBob")
{
    E = SelectEven(bob)
    O = SelectOdd(bob)
    mt_lutxy(E,O,"x y - abs "+string(nt)+" < 0 255 ?",u=3,v=3)
    mt_expand(mode="vertical",u=3,v=3)
    Interleave(last,last)
    mt_merge(isBob ? src : Interleave(src,src),bob,last,u=3,v=3)
}

### COLORSPACE CONVERSIONS ###

function ToRGB24(clip src, bool "SD")
{
    SD = default(SD,false)

    src
    Y = ConvertToY()
    U = UToY().nnedi3_rpow2(2,cshift="spline36resize")
    V = VToY().nnedi3_rpow2(2,cshift="spline36resize")
    YToUV(U,V,Y)
    ConvertToRGB24(matrix=SD ? "Rec601" : "Rec709",interlaced=false,chromaresample="spline36")
    return last
}

### ANTIALIASING ###

function CAA(clip src, int "factor", bool "chroma")
{
    factor = default(factor,2)
    chroma = default(chroma,false)

    src
    factor == 1 ? last : Spline36ResizeMT(src.width()*factor,src.Height()*factor)
    chroma ? mt_average(nnedi3(1),nnedi3(0),u=3,v=3).TurnLeft() \
           : mt_average(nnedi3(1),nnedi3(0),u=1,v=1).TurnLeft()
    chroma ? mt_average(nnedi3(1),nnedi3(0),u=3,v=3).TurnRight() \
           : mt_average(nnedi3(1),nnedi3(0),u=1,v=1).TurnRight()
    factor == 1 ? last : Spline36ResizeMT(src.width(),src.Height())
    chroma ? last : MergeChroma(src)
    return last
}

### DEHALO ###

function CDeHalo(clip src, int "rad", float "lim")
{
    rad = default(rad,12)
    lim = default(lim,1)

    src
    rad > 4 ? Removegrain(rad,-1) : FastBlur(rad)
    mt_clamp(src,mt_expand(u=1,v=1),mt_inpand(u=1,v=1),lim,lim,u=1,v=1)
    mt_logic(src,last,"min")
    return last
}

function CHaloMask(clip src, int "rad", float "lim")
{
    rad = default(rad,2)
    lim = default(lim,1)

    src
    mt_makediff(CDeHalo(rad,lim),last,u=1,v=1)
    mt_lut("x 128 == 255 x ?")
    return last
}

### SHARPENING ###

function CSharpen(clip src, int "rad", float "lim", int "sig")
{   
    rad = default(rad,3)
    lim = default(lim,1)
    sig = default(sig,4)

    src
    A = mt_makediff(last,FastBlur(rad),u=1,v=1)
    B = mt_makediff(last,Removegrain(12,-1),u=1,v=1)
    mt_clamp(A,mt_expand(B,u=1,v=1),mt_inpand(B,u=1,v=1),lim,lim,u=1,v=1)
    sig == 0 ? last : fft3dfilter(sigma=0,sigma2=sig/4.0,sigma3=sig/2.0,sigma4=sig,bt=1)
    mt_average(SangNom2(1),SangNom2(2),u=1,v=1).TurnLeft()
    mt_average(SangNom2(1),SangNom2(2),u=1,v=1).TurnRight()
    mt_adddiff(src,last)
    return last
}

# LF stands for low frequency

function CLFSharpen(clip src, int "thr", int "rad", int "sig")
{
    thr = default(thr,3)
    rad = default(rad,3)
    sig = default(sig,4)

    low = string(128 - thr)
    high = string(128 + thr)

    src
    mt_makediff(last,FastBlur(rad),u=1,v=1)
    sig == 0 ? last : fft3dfilter(sigma=0,sigma2=0,sigma3=sig/2.0,sigma4=sig,bt=1)
    mt_lut("x "+high+" > 128 x "+low+" < 128 x ? ?",u=1,v=1)
    mt_adddiff(src,last)
}

### RESIZE ###

function CSDResize(clip src, int "width", int "height",float "b", float "c", int "p", int "factor", bool "deHalo")
{
    width = default(width,720)
    height = default(height,480)
    b = default(b,1.0)
    c = default(c,1.0)
    p = default(p,10)
    factor = default(factor,2)
    deHalo = default(deHalo,false)

    src
    b = bicubicresizeMT(width,height,b,0)
    c = bicubicresizeMT(width,height,0,c)
    s = deHalo ? mt_merge(b,c,CHaloMask(c,12)) : c
    g = GaussResizeMT(width,height,p=p)
    mt_makediff(g,s,u=1,v=1)
    CAA(factor)
    mt_makediff(g,last,u=1,v=1)
    return mergechroma(b)
}

### HELPER ###

function Cn(clip src, int "frame")
{
    src
    if(frame == 0)
    {
        DoubleWeave().SelectOdd().Trim(0,0)+Trim(1,0)
    }
    else
    {
        Trim(0,frame-1)+DoubleWeave().SelectOdd().Trim(frame,frame)+Trim(frame+1,0)
    }
    return last
}

function Intw(clip src)
{
    Interleave(src.SelectEven(),src.SelectOdd()).AssumeFieldBased().Weave()
    return last
}

function CFieldSofter(clip src, int "rad")
{
    rad = default(rad,1)

    src
    SeparateFields()
    FastBlur(rad)
    Interleave(SelectEven(),SelectOdd()).Weave()
    return last
}
### INTERPOLATE ###

function bClip(clip src)
{
    src
    mt_average(trim(1,0),u=3,v=3)
    return last
}

function iClip(clip src)
{
    src
    super = MSuper()
    backvec = MAnalyse(super,blksize=4,overlap=2,isb=true,delta=1)
    forwvec = MAnalyse(super,blksize=4,overlap=2,isb=false,delta=1)
    MFlowInter(src,super,backvec,forwvec,blend=false,time=50)
    return last
}

function iClip2(clip src)
{
    src
    super = MSuper()
    backvec = MAnalyse(super,blksize=64,overlap=32,isb=true,delta=1)
    forwvec = MAnalyse(super,blksize=64,overlap=32,isb=false,delta=1)
    MFlowInter(src,super,backvec,forwvec,blend=false,time=50)
    return last
}

#30fps or 60fps to 24fps

function iClip3(clip src, int "p")
{
    src
    super = MSuper()
    backvec = MAnalyse(super,blksize=4,overlap=2,isb=true,delta=1)
    forwvec = MAnalyse(super,blksize=4,overlap=2,isb=false,delta=1)
    MFlowFps(src,super,backvec,forwvec,blend=false,num=120000,den=1001)
    SelectEvery(5,p)
    return last
}

function SCClip(clip src, bool "SD",int "thSCD1", int "thSCD2")
{
    SD = default(SD,false)
    thSCD1 = default(thSCD1,400)
    thSCD2 = default(thSCD2,130)

    src
    super = MSuper()
    forwvec = MAnalyse(super,blksize=SD ? 8 : 64,overlap=SD ? 4 : 32,isb=false,delta=1)
    MSCDetection(forwvec,thSCD1=thSCD1,thSCD2=thSCD2)
    return last
}