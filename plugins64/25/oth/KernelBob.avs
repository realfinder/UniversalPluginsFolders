 # SmoothBob uses Smoothdeinterlace to bob the video.
 # Parameter Topfirst = 1 (default) will use the top field as the first field, = 0 will use the bottom field as first field

function KernelBob(clip a, int ord)
{
  f = a.KernelDeint(order=ord)
  e = a.SeparateFields.Trim(1,0).Weave.KernelDeint(order=1-ord)
  Interleave(f,e)
}

 # SmoothDeinterlace requires YUY2:ConvertToYUY2(interlaced=true) # if necessary 