function DetectVCRLines(clip c,int threshold)
{
  spacial_data = GeneralConvolution(ConvertToRGB(c),0,"0 -1 0 0 2 0 0 -1 0")
  bar_data = ConvertToRGB(BilinearResize(spacial_data,16,c.height))
  st_data = Overlay(bar_data,Trim(bar_data,1,0),mode = "subtract")
  st_data2 = Greyscale(Levels(st_data,threshold,10.0,threshold+1,0,255,coring = false))
  st_data3 = Greyscale(Levels(st_data2,127,10.0,128,0,255,coring = false))
  st_data4 = Overlay(st_data3,st_data3,y = -1, mode = "add")
  return PointResize(st_data4,c.width,c.height)
}

function deVCR(clip c,int threshold)
{
  mybars = DetectVCRLines(c,threshold)
  return Overlay(c,Trim(c,1,0), mask = mybars,greymask = true)  
}