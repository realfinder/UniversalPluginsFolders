function Stabilise(clip o, clip metric)
{
Selectall(o)
SelectFirstOfRun()
scene = Breakon(last)
FindIntegerPan (o, metric)
UnmaskedRefinePan(o, metric, last)
motion = last.ScaleMotion(-1.0)
totalmotion = AccumulateMotion(scene, motion)
# Stabilise
ApplyUnmaskedPowerTranslate(o, totalmotion, o)#.Expand(900, 640))
return Paper()
}

function Stabilisemod(clip o, bool "padding", float "repthr")
{
padding = default (padding, true)
cell_s_repthr = default (repthr, 30)

bo = padding ? o.pointresize(width(o)+16,height(o)+16,-8,-8,width(o)+16.0001,height(o)+16.0001) : o.AddBorders(8, 8, 8, 8)
s=bo.Stabilise(bo.capabsolutemetric(15)).crop(8,8,-8,-8,align=true)
oas=Interleave(o,s)

ScriptClip(oas,"""
                                                sc=last.cFrameDiff(prevf=true, chroma=false, denoise=true, nt=1)
                                                sc > cell_s_repthr ? Interleave(o,o) : last
                                                """, args="o, cell_s_repthr").Selectodd()
}