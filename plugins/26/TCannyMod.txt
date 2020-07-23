TCannyMod - Canny edge detection filter for Avisynth2.6


TCannyMod is an Avisynth filter plugin rewritten from scratch to Avisynth2.6
based on tcanny written by Kevin Stone(a.k.a. tritical).


Syntax:

    TCannyMod(clip, int "mode", float "sigma", float "t_h", float "t_l",
              bool "sobel", int "chroma", float gmmax)

    info:
        Builds an edge map using canny edge detection.

    parameters:

        clip - planar formats only.

        mode - sets output format (default = 0)

            0 - thresholded edge map (255 for edge, 0 for non-edge)

            1 - gradient magnitude map.

            2 - edge pixel only gradient direction map (non-edge pixels set to 0)

            3 - gradient direction map

                Gradient direction are normarized to 1, 3, 7 and 15.
                    1 = horizontal
                    3 = 45' up
                    7 = vertical
                    15 = 45' down

            4 - Gaussian blured frame.

        sigma - standard deviation of gaussian blur. 
                0 means not bluring before edge detection.
                (0 <= sigma <= 2.83, default = 1.5)

        t_h - high gradient magnitude threshold for hysteresis (default = 8.0)

        t_l - low gradient magnitude threshold for hysteresis (default = 1.0)

        sobel - use Sobel operator instead of [1, 0, -1] for edge detection. (default = false)

        chroma - processing of chroma (default = 0)

            0 - not processing.

            1 - full processing

            2 - copy from source.

            3 - fill with 0x80(128). output is grayscale.

        gmmax - used for scaling gradient magnitude into [0,255] for mode=1 (default = 255)
                 gmmax is internally set to 1.0 if you set it to < 1.0.

    ------------------------------------------------------------------------

    GBlur(clip, float "sigma", int "chroma")

    info:
        Gaussian blur filter. Just an alias of TCannyMod(mode=4).

    parameters:

        clip - same as TCannyMod.

        sigma - same as TCannyMod. (default = 0.5)

        chroma - same as TCannyMod. (default = 1)


Requirement:

    Avisynth2.6 alpha4 or later
    Microsoft Visual C++ 2010 Redistributable Package
    WindowsXPsp3/Vista/7/8
    SSE2 capable CPU

Source code:

    https://github.com/chikuzen/TCannyMod/


Author  Oka Motofumi (chikuzen.mo at gmail dot com)