# Vinverse: a small, but effective Function against (residual) combing, by Didée
# sstr: strength of contra sharpening
# amnt: change no pixel by more than this (default=255: unrestricted)
# uv  : chroma mode, as in MaskTools: 1=trash chroma, 2=pass chroma through, 3=process chroma

function Vinverse_avsi(clip clp, float "sstr", int "amnt", int "uv")
{
uv   = default(uv,3)
sstr = default(sstr,2.7)
amnt = default(amnt,255)
uv2  = (uv==2) ? 1 : uv
STR  = string(sstr)
AMN  = string(amnt)
vblur  = clp.mt_Convolution("1","50 99 50",U=uv,V=uv)
vblurD = mt_MakeDiff(clp,vblur,U=uv2,V=uv2)
Vshrp  = mt_LutXY(vblur,vblur.mt_Convolution("1","1 4 6 4 1",U=uv2,V=uv2),expr="x x y - "+STR+" * +",U=uv2,V=uv2)
VshrpD = mt_MakeDiff(Vshrp,vblur,U=uv2,V=uv2)
VlimD  = mt_LutXY(VshrpD,VblurD,expr="x 128 - y 128 - * 0 < x 128 - abs y 128 - abs < x y ? 128 - 0.25 * 128 + x 128 - abs y 128 - abs < x y ? ?",U=uv2,V=uv2)
mt_AddDiff(Vblur,VlimD,U=uv,V=uv)
(amnt>254) ? last : (amnt==0) ? clp : mt_LutXY(clp,last,expr="x "+AMN+" + y < x "+AMN+" + x "+AMN+" - y > x "+AMN+" - y ? ?",U=uv,V=uv) 
return(last)
}