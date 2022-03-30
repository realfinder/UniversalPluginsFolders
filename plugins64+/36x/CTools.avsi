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

### RESIZE ###

function CResize(clip src, int "width", int "height", float "b", float "c", int "aastr")
{
    width = default(width, 720)
    height = default(height, 480)
    b = default(b, 1.0)
    c = default(c, 1.0)
    aastr = default(aastr, 1)

    src
    A = BicubicResizeMT(720,480,0,c)
    B = BicubicResizeMT(720,480,b,0)
    mt_makediff(A,B,u=3,v=3)
    aastr > 0 ? CAntiAliasing(0,0,true,true,true) : last
    aastr > 1 ? CAntiAliasing(0,0,true,true,true) : last
    aastr > 2 ? CAntiAliasing(0,0,true,true,true) : last
    mt_adddiff(B,last,u=3,v=3)
    return last
}

### HELPER ###

function CFieldSofter(clip src, int "mode")
{
    mode = default(mode, 20)

    src
    SeparateFields()
    Removegrain(mode)
    Weave()
    return last
}

### INTERPOLATE ###

#30fps or 60fps to 24fps

function xTo24fps(clip src, int "p", int "blksize")
{
    p = default(p, 0)
    blksize = default(blksize, 8)

    src
    super = MSuper()
    backvec = MAnalyse(super,blksize=blksize,overlap=blksize/2,isb=true,delta=1)
    forwvec = MAnalyse(super,blksize=blksize,overlap=blksize/2,isb=false,delta=1)
    MFlowFps(src,super,backvec,forwvec,blend=false,num=120000,den=1001)
    SelectEvery(5,p)
    return last
}