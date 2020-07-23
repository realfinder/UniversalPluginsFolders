function StackedNto16(clip c, int n)
{
    Assert(8 <= n <= 15, "StackedNto16: bitdepth should be in range 8-15")
    
    h =  c.Height / 2
    msb = c.Crop(0,0,0,-h)
    lsb = c.Crop(0,h,0,0)
    shamt = string(16-n)

    msb16 = (n != 8) ? msb.mt_lutxy(lsb, "x " + shamt + " << y 8 " + shamt + " - >> +", v=3, u=3) : lsb
    lsb16 = (n != 8) ? lsb.mt_lut("x " + shamt + " << 255 &u", v=3, u=3) : msb
    
    return StackVertical(msb16, lsb16)
}