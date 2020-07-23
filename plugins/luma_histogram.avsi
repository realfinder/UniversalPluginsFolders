function luma_histogram(clip c)
{
VersionNumber() < 2.60 ? c.mt_lut(expr="x 16 &u 17 x 15 &u - 1 x 15 &u + ? 14 *", u=-128, v=-128) : c.mt_lut(expr="x 16 &u 17 x 15 &u - 1 x 15 &u + ? 14 *", u=-128, v=-128, scale_inputs="allf")
} 