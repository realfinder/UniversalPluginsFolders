                                                                                                    |
                                  yadifmod for Avisynth v2.5.x                                      |
                                    v1.0  (15 September 2007)                                       |
                                          by tritical                                               |
                                                                                                    |
                                           HELP FILE                                                |
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------


INFO:


      Modified version of Fizick's avisynth filter port of yadif from mplayer.  This version
   doesn't internally generate spatial predictions, but takes them from an external clip.
   It also is not an Avisynth_C plugin (just a normal one).  This version works with YV12 and
   YUY2 colorspaces.


   Syntax =>

      yadifmod(int order, int field, int mode, clip edeint, int opt)


PARAMETERS:


   order -

      Sets the field order.

         -1 = use avisynth's internal parity value
          0 = bff
          1 = tff

      Default:  -1  (int)


   field -

      Controls which field to keep when using same rate output.  This parameter doesn't
      do anything when using double rate output.

         -1 = set equal to order
          0 = keep bottom field
          1 = keep top field

      Default:  -1  (int)


   mode -

      Controls double rate vs same rate output, and whether or not the spatial interlacing
      check is performed.

          0 = same rate, do spatial check
          1 = double rate, do spatial check
          2 = same rate, no spatial check
          3 = double rate, no spatial check

      Default:  0  (int)


   edeint -

      Clip from which to take spatial predictions.  This clip must be the same width, 
      height, and colorspace as the input clip.  If using same rate output, this clip
      should have the same number of frames as the input.  If using double rate output,
      this clip should have twice as many frames as the input.

      Default:  NULL  (clip)


   opt -

      Controls which cpu optimizations are used.

         0 = autodetect
         1 = force c routine
         2 = force mmx routine

      Default:  0  (int)


CHANGE LIST:


   09/15/2007  v1.0

       - Initial Release


contact:    doom9.org forum (nick = tritical)