                                                                                                    |
                                   nnedi2 for Avisynth v2.5.x                                       |
                                      v1.6  (23 July 2010)                                          |
                                          by tritical                                               |
                                                                                                    |
                                           HELP FILE                                                |
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------


INFO:


      nnedi2 is an intra-field only deinterlacer. It takes in a frame, throws away one field, and
   then interpolates the missing pixels using only information from the kept field. It has same
   rate and double rate modes, and works with YV12, YUY2, and RGB24 input. nnedi2 is also very good
   for enlarging images by powers of 2, and includes a function 'nnedi2_rpow2' for that purpose.


  Syntax =>

    nnedi2(int field, bool dh, bool Y, bool U, bool V, int nsize, int qual, bool pscrn,
           int threads, int opt)

    nnedi2_rpow2(int rfactor, int nsize, int qual, bool pscrn, string cshift, int fwidth,
                 int fheight, float ep0, float ep1, int threads, int opt)



PARAMETERS (nnedi2):


   field -

      Controls the mode of operation (double vs same rate) and which field is kept.
      Possible settings:

         -2 = double rate (alternates each frame), uses avisynth's internal parity value to start
         -1 = same rate, uses avisynth's internal parity value
          0 = same rate, keep bottom field
          1 = same rate, keep top field
          2 = double rate (alternates each frame), starts with bottom
          3 = double rate (alternates each frame), starts with top

      If field is set to -1, then nnedi2 calls child->GetParity(0) during initialization.
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


   nsize -

      Sets the size of the predictor neural network. Possible settings are 0, 1, and 2. 0 is
      fastest. 2 is slowest, but should give the best quality. This is a quality vs speed
      option; however, differences are usually small. The difference in speed between will
      become larger as 'qual' is increased.

      Default:  2  (int)


   qual -

      Controls the number of different neural network predictions that are blended together
      to compute the final output value. Each neural network was trained on a different set
      of training data. Blending the results of these different networks improves generalization
      to unseen data. Possible values are 1, 2, or 3. Essentially this is a quality vs speed
      option. Larger values will result in more processing time, but should give better results.
      However, the difference is usually pretty small. I would recommend using qual>1 for
      things like single image enlargement.

      Default:  1  (int)


   pscrn -

      Controls whether or not the prescreener neural network is used to decide which pixels
      should be processed by the predictor neural network and which can be handled by simple
      cubic interpolation. The prescreener is trained to know whether cubic interpolation
      will be sufficient for a pixel, or whether it should be predicted by the predictor nn.
      The computational complexity of the prescreener nn is much less than that of the predictor
      nn. Since most pixels can be handled by cubic interpolation, using the prescreener
      generally results in much faster processing. The prescreener is pretty accurate, so the
      difference between using it and not using it is almost always unnoticeable.

      Default:  true  (bool)


   threads -

      Controls how many threads will be used for processing. If set to 0, threads will
      be set equal to the number of detected processors.

      Default:  0  (int)


   opt -

      Sets which cpu optimizations to use. Possible settings:

         0 = auto detect
         1 = use c
         2 = use sse
         3 = use sse2
         4 = use sse3
         5 = use ssse3

      Default:  0 (int)



PARAMETERS (nnedi2_rpow2):


   rfactor -

      Image enlargement factor. Must be a power of 2 in the range [2,1024].

      Default:  not set  (int)


   cshift -

      Sets the resizer used for correcting the image center shift that nnedi2_rpow2
      introduces. This can be any of Avisynth's internal resizers, such as "spline36resize",
      "lanczosresize", etc... If not specified the shift is not corrected. The correction
      is accomplished by using the subpixel cropping capability of Avisynth's internal
      resizers.

      Default:  not set  (string)


   fwidth/fheight -
   
      If correcting the image center shift by using the 'cshift' parameter, fwidth/fheight
      allow you to set a new output resolution. First, the image is enlarged by 'rfactor'
      using nnedi2. Once that is completed the image center shift is corrected, and the
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


   nsize/qual/pscrn/threads/opt -

      Same as corresponding parameters in nnedi2.



nnedi2_rpow2 EXAMPLES:


   a.) enlarge image by 4x, don't correct for center shift.

          nnedi2_rpow2(rfactor=4)


   b.) enlarge image by 2x, correct for center shift using spline36resize.

          nnedi2_rpow2(rfactor=2,cshift="spline36resize")


   c.) enlarge image by 8x, correct for center shift and downsample from
       8x to 7x using lanczosresize with 5 taps.

          nnedi2_rpow2(rfactor=8,cshift="lanczosresize",fwidth=width*7,fheight=height*7,ep0=5)



CHANGE LIST:


   07/23/2010  v1.6

       - fix field=0/1 flipped with rgb24 input


   05/16/2010  v1.5

       - fix using paddq instruction (sse2) in sse routine
       - change setcachehints call


   07/08/2009  v1.4

       + added another value for nsize (0,1 in previous release are now 1,2)
       - another fix for automatic opt detection


   07/03/2009  v1.3

       + added nsize parameter
       + updated nn weights
       - fixed problem with SSSE3 automatic detection


   06/18/2009  v1.2

       + remove mod2 height restriction when dh=true
       + more assembly optimizations/tweaks
       - fixed automatic cpu detection
       - fixed issues with nnedi2_rpow2
           - always correct yv12 vertical chroma shift
           - use arg names when invoking resizers
           - allow users to pass optional resizer arguments (ep0/ep1 parameters)


   06/13/2009  v1.1

       + added RGB24 support
       + added nnedi2_rpow2 function
       + faster SSE2 routines


   06/10/2009  v1.0

       - Initial Release



                         contact:    doom9.org forum (nick = tritical)
