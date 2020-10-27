# make aWarpSharp2 work on other planar, for avs 2.6
# mod to make it faster with last aWarpSharp2 and add aWarp4, v1.46

function aWarpSharp4xx (clip osrc, int "thresh", int "blur", int "type", int "depth", int "chroma", int "cdepth", string "cplace", bool "bic", int "cblur", bool "useaWarp4", clip "y_mask", bool "lsb", int "depthV", int "blurV", int "cdepthV", int "cblurV", int "threads")
{

sisphbd = AvsPlusVersionNumber > 2294

lsb    = default(lsb, false)
sisphbd ? Assert(!(osrc.BitsPerComponent() > 8 && lsb), "lsb hack is not Compatible with native high bit depth" ) : nop()
threads       = default(threads,sh_GetUserGlobalIMTint())

src = lsb ? osrc.DitherPost(mode=-1) : osrc

fullchr = sisphbd ? src.is444() : src.isyv24()
chr420  = sisphbd ? src.is420() : src.isyv12()
nochr   = sisphbd ?   src.isy() : src.isy8()

depth  = default(depth, 16)
type   = default(type ,  0)
mablur  = defined(blur)
blur   = default(blur , type==0 ? 2 : 3)
chroma = default(chroma, 4)
cplace = default(cplace, "MPEG2")
cdepth = default(cdepth, fullchr ? depth : depth/2)
threads_para = defined(threads) ? ",threads=" + string(threads) : ""
blurC_para = defined(cblur) ? ",blurC=" + string(cblur) : ""
cblur  = default(cblur, fullchr ? blur : (blur+1)/2)
bic    = default(bic, true)
useaW4 = default(useaWarp4, false)

Assert(IsPlanar(src) && isyuv(src), "aWarpSharp4xx: input clip must be planar YUV")
assert(0 <= chroma <= 6, "aWarpSharp4xx: argument chroma must be an integer between 0 and 6.")  
assert(cplace == "MPEG2" || cplace == "MPEG1", "aWarpSharp4xx: chroma siting must be MPEG2 or MPEG1") 
Assert(Defined(y_mask) ? sisphbd ? isy(y_mask) : isy8(y_mask) : true, "aWarpSharp4xx: y_mask clip mustn't has chroma")

blur = defined(blurV) && !mablur ? depth==0 ? 0 : blur : blur

defined(depthV) ? depthV != 0 && depth==0 ? eval("blurV=defined(blurV) ? blurV : blur Chr(3) blur=mablur ? blur : 0") : depthV==0 && depth != 0 ? eval("blurV=defined(blurV) ? blurV : 0") : nop() : nop()

defined(depthV) && !defined(cdepthV) ? depthV != 0 ? fullchr ? eval("cdepthV=depthV") : eval("cdepthV=depthV/2") : eval("cdepthV=0") : nop()

defined(cdepthV) ? cdepthV != 0 && cdepth==0 ? eval("""cblurV=defined(cblurV) ? cblurV : cblur Chr(3) cblur=blurC_para!="" ? cblur : 0""") : cdepthV==0 && cdepth != 0 ? eval("cblurV=defined(cblurV) ? cblurV : 0") : nop() : nop()

depthV_para = defined(depthV) ? ",depthV=" + string(depthV) : ""
blurV_para = defined(blurV) ? ",blurV=" + string(blurV) : defined(depthV) ? depthV==0 ? ",blurV=0" : "" : ""
cdepthV_para = defined(cdepthV) ? ",depthVC=" + string(cdepthV) : ""
cblurV_para = defined(cblurV) ? ",blurVC=" + string(cblurV) : defined(cdepthV) ? cdepthV==0 ? ",blurVC=0" : "" : ""
cuvdepthV_para = defined(cdepthV) ? ",depthV=" + string(cdepthV) : ""
cuvblurV_para = defined(cblurV) ? ",blurV=" + string(cblurV) : ""

chroma = nochr ? 1 : defined(cdepthV) ? cdepthV==0 && cdepth==0 && chroma > 2 ? 2 : chroma : chroma

(blurC_para=="" && !Defined(y_mask) && !useaW4 && !IsYV411(src) && !((!fullchr || !nochr) && (chroma == 4 || chroma == 6))) ? \
Eval("""
output = eval("src.aWarpSharp2(thresh=thresh, blur=blur, type=type, depth=depth, chroma=chroma, depthC=cdepth, cplace=cplace" + depthV_para + blurV_para + cdepthV_para + threads_para + cblurV_para + ")")
""") : \
Eval("""
chrgu = chroma == 4 || chroma == 6
y = chroma > 2 && !(chroma > 4 && Defined(y_mask)) ? sisphbd ? ConvertToY(src) : ConvertToY8(src) : src
u = chroma > 2 ? sisphbd ? ExtractU(src) : UtoY8(src) : nop()
v = chroma > 2 ? sisphbd ? ExtractV(src) : VtoY8(src) : nop()

eymask = Defined(y_mask)

y_mask = eymask ? y_mask : useaW4 || chrgu ? aSobel(y, thresh=thresh""" + threads_para + """) : nop()
yblurb  = !mablur && eymask ? defined(blurV) ? blurV!=0 : false : defined(blurV) ? !(blurV==0 && blur==0) : blur!=0
y_mask  = yblurb && (useaW4 || chrgu) ? eval("y_mask.aBlur(blur=blur,  type=type" + blurV_para + threads_para + ")") : y_mask
cshift  = chrgu ? IsYV411(src) ? -1.5 : (cplace == "MPEG1" && chr420) ? 0 : -0.5 : nop()
uv_mask = chrgu ? fullchr ? y_mask : bic ? y_mask.BicubicResize(u.width(), v.height(), src_left=cshift) : y_mask.BilinearResize(u.width(), v.height(), src_left=cshift) : nop()
u_mask  = chrgu ? uv_mask : chroma > 2 ? aSobel(u, thresh=thresh""" + threads_para + """) : nop()
uvblurb     = defined(cblurV) ? !(cblurV==0 && cblur==0) : cblur!=0
u_mask  = chrgu ? u_mask : chroma > 2 ? uvblurb ? eval("u_mask.aBlur(blur=cblur, type=type" + cuvblurV_para + threads_para + ")") : u_mask : nop()
v_mask  = chrgu ? uv_mask : chroma > 2 ? aSobel(v, thresh=thresh""" + threads_para + """) : nop()
v_mask  = chrgu ? v_mask : chroma > 2 ? uvblurb ? eval("v_mask.aBlur(blur=cblur, type=type" + cuvblurV_para + threads_para + ")") : v_mask : nop()

y = chroma < 5 ? useaW4 ? y.nnedi3_rpow2(rfactor=2,threads=threads).nnedi3_rpow2(rfactor=2,threads=threads) : y : y
u = chroma > 2 ? useaW4 ? U.nnedi3_rpow2(rfactor=2,threads=threads).nnedi3_rpow2(rfactor=2,threads=threads) : u : nop()
v = chroma > 2 ? useaW4 ? V.nnedi3_rpow2(rfactor=2,threads=threads).nnedi3_rpow2(rfactor=2,threads=threads) : v : nop()

# warp each channel independently
y_warp = chroma < 5 ? useaW4 ? eval("aWarp4(y, y_mask,  depth=depth, chroma=chroma, cplace=cplace" + depthV_para + cdepthV_para + threads_para + ")") : eval("aWarpSharp2(y, thresh=thresh, blur=blur,  type=type,  depth=depth, chroma=chroma, cplace=cplace" + depthV_para + blurV_para + cdepthV_para + blurC_para + cblurV_para + threads_para + ")") : y
u_warp = chroma > 2 ? useaW4 ? eval("aWarp4(u, u_mask, depth=cdepth                             " + cuvdepthV_para + threads_para + ")") : eval("aWarp(u, u_mask, depth=cdepth                                                                  " + cuvdepthV_para + threads_para + ")") : nop()
v_warp = chroma > 2 ? useaW4 ? eval("aWarp4(v, v_mask, depth=cdepth                              " + cuvdepthV_para + threads_para + ")") : eval("aWarp(v, v_mask, depth=cdepth                                                                  " + cuvdepthV_para + threads_para + ")") : nop()

# luma/chroma processing
output = chroma > 2 ? sisphbd ? CombinePlanes(y_warp,u_warp,v_warp,planes="YUV", source_planes="YYY",sample_clip=src) : YtoUV( u_warp  , v_warp  , y_warp ) : \
         y_warp
""")
output8_16 = lsb==true ? output.Dither_convert_8_to_16() : output
y_ld  = chroma < 5 ? 3 : 2
uv_ld = Min(chroma, 3)
Return(lsb==true ? Dither_limit_dif16(osrc, output8_16, thr=1.0, elast=1.5, y=y_ld, u=uv_ld, v=uv_ld) : output8_16)
}