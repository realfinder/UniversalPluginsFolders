function dekafka2(clip clip, clip maskclip, int Xstart, int Ystart, int X, int Y, int Amount)
{
ytop = Ystart
ybot = Ystart + Y
xleft = Xstart
xright = Xstart + X
clip = clip.ConvertToRGB32
maskclip = maskclip.ConvertToRGB32
topline = clip.Crop(Xstart-2, ytop-2, X, 2)
bottomline = clip.Crop(Xstart-2, ybot-2, X, 2)
leftline = clip.Crop(xleft-2, ytop-2, 2, Y)
rightline = clip.Crop(xright-2, ytop-2, 2, Y)
logosrc_hor = StackVertical(topline, bottomline).Blur(1.58, 0).BilinearResize(X, Y)
logosrc_ver = StackHorizontal(leftline, rightline).Blur(1.58, 0).BilinearResize(X, Y)
Amount2 = (Y>=2*X) ? 255 : 128*Y/X
# Amount2 is small if X >> Y => logoscr_hor is dominant
logosrc = Layer(logosrc_hor, logosrc_ver, "add", Amount2)
masklogo = maskclip.BilinearResize(X, Y)
logo = logosrc.Mask(masklogo)
clip = clip.Layer(logo, "add", Amount, Xstart, Ystart)
return clip
}

function remlogo(clip tclip, string filename, int x, int y)
{
maskclip = ImageReader(filename, 0, 0)
maskclip = Loop(maskclip, Framecount(tclip))
dekafka2(tclip, maskclip, x, y, maskclip.width, maskclip.height, 256)
converttoyuy2() # In case your output is YUY2
}
