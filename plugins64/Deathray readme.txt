Deathray
========

An Avisynth plug-in filter for spatial/temporal non-local means de-noising.

Created by Jawed Ashraf - Deathray@cupidity.f9.co.uk


Installation
============

Copy the Deathray.dll to the "plugins" sub-folder of your installation of 
Avisynth.


De-installation
===============

Delete the Deathray.dll from the "plugins" sub-folder of your installation of 
Avisynth.


Compatibility
=============

The following software configurations are known to work:

 - Avisynth 2.5.8         and 2.6 MT (SEt's)
 - AMD Stream SDK 2.3     and AMD APP SDK 2.8.1
 - AMD Catalyst 10.12     and 13.8 beta 2
 - Windows Vista 64-bit   and Windows 8 64-bit
 
 - NVidia software is known to work but drivers unknown

The following hardware configurations are known to work:

 - ATI HD 5870
 - AMD HD 7770
 - AMD HD 7970
 - Various NVidia, models unknown

Known non-working hardware:

 - ATI cards in the 4000 series or earlier
 - ATI cards in the 5400 series

Video:

 - Deathray is compatible solely with 8-bit planar formatted video. It has
   been tested with YV12 format.


Usage
=====

Deathray separates the video into its 3 component planes and processes each
of them independently. This means some parameters come in two flavours: luma
and chroma.

Filtering can be adjusted with the following parameters, with the default 
value for each in brackets:

 hY  (1.0) - strength of de-noising in the luma plane.

             Cannot be negative.

             If set to 0 Deathray will not process the luma plane.

 hUV (1.0) - strength of de-noising in the chroma planes.

             Cannot be negative.

             If set to 0 Deathray will not process the chroma planes.

 tY  (0)   - temporal radius for the luma plane.

             Limited to the range 0 to 64.

             When set to 0 spatial filtering is performed on the 
             luma plane. When set to 1 filtering uses the prior,
             current and next frames for the non-local sampling
             and weighting process. Higher values will increase
             the range of prior and next frames that are included.

 tUV (0)   - temporal radius for the chroma planes.

             Limited to the range 0 to 64.

             When set to 0 spatial filtering is performed on the 
             chroma planes. When set to 1 filtering uses the prior,
             current and next frames for the non-local sampling
             and weighting process. Higher values will increase
             the range of prior and next frames that are included.

 s   (1.0) - sigma used to generate the gaussian weights.

             Limited to values of at least 0.1.

             The kernel implemented by Deathray uses 7x7-pixel 
             windows centred upon the pixel being filtered. 

             For a 2-dimensional gaussian kernel sigma should be 
             approximately 1/3 of the radius of the kernel, or less,
             to retain its gaussian nature. 

             Since a 7x7 window has a radius of 3, values of sigma 
             greater than 1.0 will tend to bias the kernel towards
             a box-weighting. i.e. all pixels in the window will 
             tend towards being equally weighted. This will tend to 
             reduce the selectivity of the weighting process and 
             result in relatively stronger spatial blurring.

 x   (1)   - factor to expand sampling.

             Limited to values in the range 1 to 14.

             By default Deathray spatially samples 49 windows 
             centred upon the pixel being filtered, in a 7x7
             arrangement. x increases the sampling range in
             multiples of the kernel radius.
             
             Since the kernel radius is 3, setting x to 2 produces
             a sampling area of 13x13, i.e. 169 windows centred
             upon the target pixel. Yet higher values of x such as
             3 or 4 will result in 19x19 or 25x25 sample windows.

             Deathray uses 32x32 tiles to accelerate its processing.
             Each tile is equipped with a border of 8 pixels around
             all four edges, with pixels copied from neighbouring 
             tiles, or mirrored from within the tile if the tile 
             edge corresponds with a frame edge. This apron of 8
             extra pixels ensures that the default sampling of 
             49 windows is correct, allowing pixels near the edge of
             the tile to employ 49 sample windows that all have
             valid pixels.

             When x is set to 2 or more, sampling will "bump" into
             the edges defined by the 48x48 region. With strong 
             values of the de-noising parameters this will create
             artefacts in the filtered image. These artefacts are
             visible as a grid of vertical and horizontal lines
             corresponding with the 32x32 arrangement of the tiles.

 l (false) - linear processing of luma plane.
 
             true or false.

             This option allows processing in linear space instead
             of the default gamma space.

 c (true)  - correction after filtering.
 
             true or false.

             This option applies a correction after filtering
             to limit the amount of filtering per pixel.
			 
             When set to false the naked NLM algorithm is used.
			 
 z (false) - target pixel tends towards zero-weighted.
 
             true or false.

             Reduces the weight of the pixel being filtered to
             a minimum. This results in more even filtering across
             the tonal range from shadows to highlights.
			 
             The standard NLM algorithm gives the pixel being filtered
             the maximum weight of all. A refinment of the algorithm
             is to give the pixel being filtered the maximum weight
             derived from all the other pixels that were inspected.
			 
             This maximum of other pixels' weights is used when z is
             set to false.
			 
             When set to true, the minimum of other pixels' weights is
             used instead.

 b (false) - balanced weighting.
 
             true or false.

             Attempts to balance weighting of pixels based upon their
             luma value.
			 
             This parameter is not applied to chroma planes.
			 
			 
Avisynth MT
===========

Deathray is not thread safe. This means that only a single instance of
Deathray can be used per Avisynth script. By extension this means that
it is not compatible with any of the multi-threading modes of the 
Multi Threaded variant of Avisynth. 

Use:

SetMTMode(5) 

before a call to Deathray in the Avisynth script, if multi-threading
is active in other parts of the script.


Multiple Scripts Using Deathray
===============================

The graphics driver is thread safe. This means it is possible to have
an arbitrary number of Avisynth scripts calling Deathray running on a 
system. 

e.g. 2 scripts could be encoding, another could be running in a media player
and another could be previewing individual frames in AvsP or VirtualDub.

Eventually video memory will probably run out, even though it's virtualised.


System Responsiveness
=====================

Currently graphics drivers are unable to confer user-responsiveness
guarantees on OpenCL applications that utilise GPUs. This means if you
are using Deathray on a frame size of 16 million pixels, there will be some
juddering in Windows every ~0.7 seconds (1.5 frames per second on HD 5870) 
accompanied by difficulty in typing, etc.
