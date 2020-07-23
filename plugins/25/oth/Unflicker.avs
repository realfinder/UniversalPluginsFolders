function Unflicker (clip o)
{
screen   = mt_lutf(o,o,mode="average",yexpr="x",U=1,V=1) #.greyscale
screenTS = screen.temporalsoften(1,9,0,9,2).merge(screen,0.249).temporalsoften(2,5,0,5,2)
calmed   = o.mt_makediff(mt_makediff(screen,screenTS),U=2,V=2)
deflk    = o.Deflicker()
masky    = o.mt_lut("x 32 < x 16 - 16 * x 204 > 255 204 x - abs 255 30 / * - 255 ? ?").removegrain(11,-1)

return o.mt_merge(calmed,masky,U=2,V=2)
}
