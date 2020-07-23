# 2019.02.19
# VHSHaloremover with high bit support, need masktools 2.2.17 or up in avs26 and avs+
Function VHSHaloremover(clip input, int "xradius", int "yradius", int "darkthr", int "brightthr", float "blurmix")
{
sisphbd = AvsPlusVersionNumber > 2294
sislumaonly = sisphbd ? input.isy() : VersionNumber() < 2.6 ? true : input.isy8()
sislumaonly ? input : sisphbd ? input.converttoy() : input.converttoy8()
h   = Height ()
w   = Width ()
xradius = Default(xradius, 8)
yradius = Default(yradius, 1)
darkthr = Default(darkthr, 122)
brightthr = Default(brightthr, 134)
blurmix = Default(blurmix, 0.8)
cy  = BicubicResize (w / xradius, h / yradius, 1, 0).BicubicResize (w, h, 1, 0)
cmd = mt_makediff (cy)
cm  = VersionNumber() < 2.6 ? cmd.mt_lut ("x "+String(brightthr)+" > 255 x "+String(darkthr)+" < 255 0 ? ?")
      \			    : cmd.mt_lut ("x "+String(brightthr)+" scalef > range_max x "+String(darkthr)+" scalef < range_max 0 ? ?", use_expr=2)
cr  = last.Merge (cy, blurmix)
mt_merge (last, cr, cm, y=3, u=2, v=2)
sislumaonly ? last : sisphbd ? CombinePlanes(last,input,planes="YUV",sample_clip=input) : ytouv(input.utoy8(),input.vtoy8(),last)
}