
                                  tcanny v1.0 ReadMe

-------------------------------------------------------------------------------------------

   tcanny(float sigma, float t_h, float t_l, int nms, int mode, int plane, float gmmax)

      Info:

         Builds an edge map using canny edge detection.

      Parameters:

         sigma - standard deviation of gaussian blur (default = 1.5)

         t_h - high gradient magnitude threshold for hysteresis (default = 8.0)

         t_l - low gradient magnitude threshold for hysteresis (default = 1.0)

         nms - byte mask choosing non-maxima suppression method(s) (default = 3)

            if (nms&1) - if pixel is maxima along nearest integer direction then keep
            if (nms&3) - if pixel is maxima along linearly interpolated direction then keep

         mode - sets output format  (default = 0)

            0 - thresholded edge map (255 for edge, 0 for non-edge)

            1 - gradient magnitude map. Scaled to 0-255 range based on gmmax.

                  pixel_val = min(grad_mag*255/gmmax,255)

            2 - edge pixel only gradient direction map (non-edge pixels set to 0)

            3 - gradient direction map

               Gradient direction maps discretize [0-180) degree range into 256 bins.

                  0 = [000.000-000.351)
                  1 = [000.351-001.054)
                  .
                  .
                  .
                255 = [179.648-180.000)

                            135   90  45
                               \  |  /
                           180 --   -- 0
                                / |  \
                              45  90  135

                  * This is the gradient direction, so the line direction is
                    orthogonal to it (90 degree rotation). It only goes through
                    180 because for this case:

                           180+n = n, 0 <= n < 180

         plane - byte mask indicating which planes to process. If a plane isn't
                 processed then it is copied through as is.  (default = 1)

            if (plane&1) - process y
            if (plane&2) - process u
            if (plane&4) - process v

         gmmax - used for scaling gradient magnitude into [0,255] for mode=1 (default = 50)
                 gmmax is internally set to 1.0 if you set it to < 1.0.


-------------------------------------------------------------------------------------------

   tdtrans(int mode, int plane)

      Info:

         Performs a distance transformation on an edge map. This filter assumes the input
         image is 0 for non-edge pixels, and > 0 for edge pixels.

         The distance transform sets each pixel equal to the distance from it to the
         nearest edge pixel.

      Parameters:

         mode - sets distance type (default = 1)

            0 - city block
            1 - euclidean

            * For the euclidean case the distance is rounded to the nearest integer.
            * For both cases distances greater than 255 are set to 255.

         plane - byte mask indicating which planes to process. (default = 1)
                 Same as in tcanny.


-------------------------------------------------------------------------------------------

CHANGE LIST:   
         
   6/03/2009  v1.0

      - initial release



      contact:  forum.doom9.org - nick: tritical   or   email:  kes25c@mizzou.edu
