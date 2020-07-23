                                                                                                    |
                                    NNEDI for Avisynth v2.5.x                                       |
                                    v1.3  (20 September 2007)                                       |
                                          by tritical                                               |
                                                                                                    |
                                           HELP FILE                                                |
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------


INFO:


      NNEDI is an intra-field only deinterlacer.  It takes in a frame, throws away one field, and
   then interpolates the missing pixels using only information from the kept field.  It has same
   rate and double rate modes, and works with YUY2 and YV12 input.  NNEDI can also be used to
   enlarge images by powers of 2.


   Syntax =>

      nnedi(int field, bool dh, bool Y, bool U, bool V, int threads, int opt, string name)


PARAMETERS:


   field -

      Controls the mode of operation (double vs same rate) and which field is kept.
      Possible settings:

         -2 = double rate (alternates each frame), uses avisynth's internal parity value to start
         -1 = same rate, uses avisynth's internal parity value
          0 = same rate, keep bottom field
          1 = same rate, keep top field
          2 = double rate (alternates each frame), starts with bottom
          3 = double rate (alternates each frame), starts with top

      Default:  -1  (int)


   dh -

      Doubles the height of the input.  Each line of the input is copied to every other line
      of the output and the missing lines are interpolated.  If field=0, the input is
      copied to the odd lines of the output.  If field=1, the input is copied to the even
      lines of the output.  field must be set to either 0 or 1 when using dh=true.

      Default:  false  (int)


   Y, U, V -

      These control whether or not the specified plane is processed.  Set to true to
      process or false to ignore.

      Default:  Y = true  (bool)
                U = true  (bool)
                V = true  (bool)


   threads -

      Controls how many threads will be used for processing.  If set to 0, threads will
      be set equal to the number of detected processors.

      Default:  0  (int)


   opt -

      Sets which cpu optimizations to use.  Possible settings:

         0 = auto detect
         1 = use c routines
         2 = use sse routines

      Default:  0 (int)


   name -

      nnedi needs to know its name.  So if you change the name of the dll to something
      other than "nnedi.dll" you will need to let nnedi know that via this parameter.

      Default:  "nnedi.dll"  (string)


CHANGE LIST:


   09/20/2007  v1.3

       - added dh option to eliminate the need for externally copying the
            input to every other line of a height doubled frame prior
            to calling nnedi
       - fixed incorrect mirroring of chroma pixels at the borders of the image
            with YUY2 input


   09/16/2007  v1.2

       - fixed using psrlq (sse2) instruction in sse routines


   09/15/2007  v1.1

       - fixed a bug causing yv12 chroma to be handled incorrectly


   09/14/2007  v1.0

       - Initial Release


CONTRIBUTIONS:


   I'd like to thank the following people for contributing CPU time to the development of
   this filter:

      checkers
      Flaarn
      Mitsubishi
      foxyshadis
      Kentar
      Aqualung99
      kaptah
      ReufToc
      ChiDragon
      jinkslynx
      HarukaLover
      Demi9OD
      Chainmax
      Alain2
      Wiiwee


contact:    doom9.org forum (nick = tritical)