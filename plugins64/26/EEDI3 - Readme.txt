                                                                                                    |
                                   nnedi3 for Avisynth v2.6.x                                       |
                                    v0.9.2.1 (July 29, 2015)                                        |
                                          by tritical                                               |
                                     modified by Firesledge                                         |
                                       modified by Elegant                                          |
                                                                                                    |
                                           HELP FILE                                                |
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------



INFO:

      eedi3 is an intra-field only deinterlacer. It takes in a frame, throws away one field, and
   then interpolates the missing pixels using only information from the kept field. It has same
   rate and double rate modes, and works with YV12, YUY2, and RGB24 input. nnedi3 is also very good
   for enlarging images by powers of 2, and includes a function 'nnedi3_rpow2' for that purpose.

     eedi3 works by finding the best non-decreasing (non-crossing) warping between two lines by minimizing a cost functional.
   The cost is based on neighborhood similarity (favor connecting regions that look similar), the vertical difference created
   by the interpolated values (favor small differences), the interpolation directions (favor short connections vs long), and
   the change in interpolation direction from pixel to pixel (favor small changes).

   *** Note: eedi3 is threaded using openmp, and is compiled with visual studio 2012.
   *** Therefore, it needs the visual studio 2012 redistributable package to be
   *** installed (for vcomp.dll).
   *** http://www.microsoft.com/download/details.aspx?id=30679



FUNCTIONS:


  "eedi3", "c[field]i[dh]b[Y]b[U]b[V]b[alpha]f[beta]f[gamma]f[nrad]i[mdis]i[hp]b[ucubic]b[cost3]b[vcheck]i[vthresh0]f[vthresh1]f[vthresh2]f[sclip]c[threads]i[mclip]c[opt]i"

  "eedi3_rpow2", "c[rfactor]i[alpha]f[beta]f[gamma]f[nrad]i[mdis]i[hp]b[ucubic]b[cost3]b[vcheck]i[vthresh0]f[vthresh1]f[vthresh2]f[cshift]s[fwidth]i[fheight]i[ep0]f[ep1]f[threads]i[opt]i"



PARAMETERS (eedi3):

   field -

      Controls the mode of operation (double vs same rate) and which field is kept.
      Possible settings:

         -2 = double rate (alternates each frame), uses avisynth's internal parity value to start
         -1 = same rate, uses avisynth's internal parity value
          0 = same rate, keep bottom field
          1 = same rate, keep top field
          2 = double rate (alternates each frame), starts with bottom
          3 = double rate (alternates each frame), starts with top

      If field is set to -1, then eedi3 calls child->GetParity(0) during initialization.
      If it returns true, then field is set to 1. If it returns false, then field is set to 0.
      If field is set to -2, then the same thing happens, but instead of setting field to 1
      or 0 it is set to 3 or 2.

      Default:  -1  (int)


   dh -

      Doubles the height of the input. Each line of the input is copied to every other line
      of the output and the missing lines are interpolated. If field=0, the input is copied
      to the odd lines of the output. If field=1, the input is copied to the even lines of
      the output. field must be set to either -1, 0, or 1 when using dh=true.

      Default:  false  (int)


   Y, U, V -

      These control whether or not the specified plane is processed. Set to true to
      process or false to ignore. Ignored planes are not copied, zero'd, or even
      considered. So what the ignored planes happen to contain on output is unpredictable.
      For RGB24 input Y=B, U=G, V=R.

      Default:  Y = true  (bool)
                U = true  (bool)
                V = true  (bool)


   alpha/beta/gamma (defaults: 0.2,0.25,20.0):

     These trade off line/edge connection vs artifacts created. alpha and beta must be in the range [0,1], and the sum
     alpha+beta must be in the range [0,1]. alpha is the weight given to connecting similar neighborhoods.. the larger
     it is the more lines/edges should be connected. beta is the weight given to vertical difference created by the
     interpolation... the larger beta is the less edges/lines will be connected (at 1.0 you get no edge directedness at all). 
     The remaining weight (1.0-alpha-beta) is given to interpolation direction (large directions (away from vertical) 
     cost more)... so the more weight you have here the more shorter connections will be favored. Finally, gamma penalizes
     changes in interpolation direction, the larger gamma is the smoother the interpolation field between two lines 
     (range is [0,inf].

     If lines aren't getting connected then increase alpha and maybe decrease beta/gamma. Go the other way if you are 
     getting unwanted artifacts.


   nrad/mdis (defaults: 2,20):

     nrad sets the radius used for computing neighborhood similarity. Valid range is [0,3]. mdis sets the maximum
     connection radius. Valid range is [1,40]. If mdis=20, then when interpolating pixel (50,10) (x,y), the farthest
     connections allowed would be between (30,9)/(70,11) and (70,9)/(30,11). Larger mdis will allow connecting lines
     of smaller slope, but also increases the chance of artifacts. Larger mdis will be slower. Larger nrad will be
     slower.


   hp/ucubic/cost3 (defaults: false, true, true):

      These are speed vs quality options. hp=true, use half pel steps, hp=false, use full pel steps. ucubic=true, use 
      cubic 4 point interpolation, ucubic=false, use 2 point linear interpolation. cost3=true, use 3 neighborhood cost
      function to define similarity, cost3=false, use 1 neighborhood cost function.


   vcheck/vthresh0/vthresh1/vthresh2/sclip (defaults: 2, 32.0, 64.0, 4.0, NULL):

      vcheck settings:

          0 - no reliability check
          1 - weak reliability check
          2 - med reliability check
          3 - strong reliability check

      If vcheck is greater than 0, then the resulting interpolation is checked for reliability/consistency. Assume
      we interpolated pixel 'fh' below using dir=4 (i.e. averaging pixels bl and cd).

           aa ab ac ad ae af ag ah ai aj ak al am an ao ap
                                eh          el
           ba bb bc bd be bf bg bh bi bj bk bl bm bn bo bp
                    fd          fh          fl
           ca cb cc cd ce cf cg ch ci cj ck cl cm cn co cp
                    gd          gh
           da db dc dd de df dg dh di dj dk dl dm dn do dp

      When checking pixel 'fh' the following is computed:

            d0 = abs((el+fd)/2 - bh)
            d1 = abs((fl+gd)/2 - ch)

            q2 = abs(bh-fh)+abs(ch-fh)
            q3 = abs(el-bl)+abs(fl-bl)
            q4 = abs(fd-cd)+abs(gd-cd)

            d2 = abs(q2-q3)
            d3 = abs(q2-q4)

            mdiff0 = vcheck == 1 ? min(d0,d1) : vcheck == 2 ? ((d0+d1+1)>>1) : max(d0,d1)
            mdiff1 = vcheck == 1 ? min(d2,d3) : vcheck == 2 ? ((d2+d3+1)>>1) : max(d2,d3)

            a0 = mdiff0/vthresh0;
            a1 = mdiff1/vthresh1;
            a2 = max((vthresh2-abs(dir))/vthresh2,0.0f)
						
            a = min(max(max(a0,a1),a2),1.0f)
						
            final_value = (1.0-a)*fh + a*cint


        ** If sclip is supplied, cint is the corresponding value from sclip. If sclip isn't supplied,
           then vertical cubic interpolation is used to create it.


   mclip (default: not set)

      A mask to use edge-directed interpolation only on specified pixels. The clip should have the
      same format as the input clip. Pixels where the mask is 0 are generated using cubic linear or
      bicubic interpolation. The main goal of the mask is to save calculations.
      This parameter does not exist in eedi3_rpow2.


   opt (default: 0)

      Sets which cpu optimizations to use. Possible settings:

         0 = auto detect
         1 = use c
         2 = use sse2


   threads (default: 0):

      Sets the number of threads used by openmp.

         0 = default (environment variable OMP_NUM_THREADS)
         > 0 = calls omp_set_num_threads(threads)



PARAMETERS (eedi3_rpow2):

   rfactor -

      Image enlargement factor. Must be a power of 2 in the range [2,1024].

      Default:  not set  (int)


   cshift -

      Sets the resizer used for correcting the image center shift that eedi3_rpow2
      introduces. This can be any of Avisynth's internal resizers, such as "spline36resize",
      "lanczosresize", etc... If not specified the shift is not corrected. The correction
      is accomplished by using the subpixel cropping capability of Avisynth's internal
      resizers.

      Default:  not set  (string)


   fwidth/fheight -
   
      If correcting the image center shift by using the 'cshift' parameter, fwidth/fheight
      allow you to set a new output resolution. First, the image is enlarged by 'rfactor'
      using eedi3. Once that is completed the image center shift is corrected, and the
      image is resampled to fwidth x fheight resolution. The shifting and resampling
      happen in one call using the internal Avisynth resizer you specify via the 'cshift'
      string. If fwidth/fheight are not specified, then they are set equal to rfactor*width
      and rfactor*height respectively (in other words they do nothing).

      Default:  not set  (int)
                not set  (int)


   ep0/ep1 -

      Some Avisynth resizers take optional arguments, such as 'taps' for lanczosresize or
      'p' for gaussresize. ep0/ep1 allow you to pass values for these optional arguments
      when using the 'cshift' parameter. If the resizer only takes one optional argument
      then ep0 is used. If the argument that the resizer takes is not a float value,
      then ep0 gets rounded to an integer. If the resizer takes two optional arguments,
      then ep0 corresponds to the first one, and ep1 corresponds to the second. The only
      resizer that takes more than one optional argument is bicubicresize(), which takes
      'b' and 'c'. So ep0 = b, and ep1 = c. If ep0/ep1 are not set then the default value
      for the optional argument(s) of the resizer is used.

      Default:  not set  (float)
                not set  (float)


   alpha/beta/gamma/nrad/mdis/hp/ucubic/cost3/vcheck/vthresh0/vthresh1/vthresh2/threads/opt -

      Same as corresponding parameters in eedi3.



eedi3_rpow2 EXAMPLES:


   a.) enlarge image by 4x, don't correct for center shift.

          eedi3_rpow2(rfactor=4)


   b.) enlarge image by 2x, correct for center shift using spline36resize.

          eedi3_rpow2(rfactor=2,cshift="spline36resize")


   c.) enlarge image by 8x, correct for center shift and downsample from
       8x to 7x using lanczosresize with 5 taps.

          eedi3_rpow2(rfactor=8,cshift="lanczosresize",fwidth=width*7,fheight=height*7,ep0=5)



CHANGE LIST:

	v0.9.2.1 - July 29th, 2015
       - Switched to AVS 2.6 API
	   - Added x64 support
	   - Updated some variable types for clarity
       - Compiled with Visual Studio 2013

    v0.9.2 - November 11, 2013
       - Added SSE2 optimizations for full-pel interpolation
       - Added mclip masking
       - Compiled with Visual Studio 2012

    v0.9.1 - July 23, 2010

       - fix field=0/1 flipped with rgb24 input
       - fix possible reading off the edge of a frame with cost3=true

