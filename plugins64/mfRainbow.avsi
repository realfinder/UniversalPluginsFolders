# mfRainbow v0.31 by mf
# Derainbows in areas of high Y, U and V frequencies, which fluctuate heavily.
#
# I don't claim copyright but I ask you to treat my script
# fairly.
#
# Changelog: Tweakable scenechange detection for tough sources
#
# Requires MaskTools.dll , Warpsharp.dll


function mfRainbow(clip input, string "mode", int "strength", int "scd", bool "post") {

strength = Default(strength, 255) # processing strength, 0-255
scd = Default(scd, 10) # scenechange detection

input.UnsharpMask(200).UnsharpMask(200).EdgeMask(3, 255, 255, 255, "roberts", Y=3, V=1,\
U=1).Deflate().Levels(0, 1.0, 45, 0, 255).Blur(1.0).Deflate().Levels(0, 1.0, 75, 0, \
255).Deflate().Deflate().Deflate().Greyscale()
ymask = last

input.UToY()
u = last

u.Unsharpmask(500).Unsharpmask(500).EdgeMask(3, 255, 255, 255, "roberts", \
Y=3, V=1, U=1).Levels(0, 1.0, 100, 0, 255).Greyscale()
LanczosResize(input.width, input.height)
umask = last

input.VToY()
v = last
v.Unsharpmask(500).Unsharpmask(500).EdgeMask(3, 255, 255, 255, "roberts", \
Y=3, V=1, U=1).Levels(0, 1.0, 75, 50, 255).Greyscale()
LanczosResize(input.width, input.height)
vmask = last

Overlay(ymask, umask, mode="lighten")
yumask = last

Overlay(yumask, vmask, mode="hardlight")
yuvmask = last

u.TemporalSoften(4,4,0, 12, 2).TemporalSoften(4,10,0, 12, 2)
YV12Subtract(last, u)
PointResize(input.width, input.height)
Levels(100, 1, 155, 0, 255, false)
MotionMask(thY1=0, thY2=255, y=3,u=1,v=1)
Levels(0, 1, 25, 0, 255, false)
GreyScale()
uflucts = last

v.TemporalSoften(4,4,0, 12, 2).TemporalSoften(4,10,0, 12, 2)
YV12Subtract(last, v)
PointResize(input.width, input.height)
Levels(100, 1, 155, 0, 255, false)
MotionMask(thY1=0, thY2=255, y=3,u=1,v=1)
Levels(0, 1, 25, 0, 255, false)
GreyScale()
vflucts = last

Overlay(uflucts, vflucts, mode="lighten")
uvflucts = last

Overlay(yuvmask, uvflucts, mode="hardlight")
Inflate().Inflate().Levels(0, 1, 100, 0, 255, false)
Greyscale()
bigedgemask = last
LanczosResize(u.width, u.height)
edgemask = last

input.UToY().temporalsoften(50,255,1,scd,2)
derainbowu = last
input.VToY().temporalsoften(50,255,1,scd,2)
derainbowv = last

edgerainbowu = MaskedMerge(u, derainbowu, edgemask, Y=3, U=1, V=1)
edgerainbowv = MaskedMerge(v, derainbowv, edgemask, Y=3, U=1, V=1)

edgerainbow = YToUV(edgerainbowu, edgerainbowv, input.Greyscale())

input.MergeChroma(edgerainbow)

}