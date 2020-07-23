BlendBob 1.2 by Kurt Bernhard Pruenner
======================================

This filter takes a bobbed video stream and halves it's framerate by blending
every other frame with the adjacent frame that matches it best. 

Additionally, it tries to fix badly telecined frames, and offers derainbowing
options for 24 and 30FPS material.


Parameters
==========

c ............... Clip to blend

show ............ If true show the following framematching metrics:

                  * The first line shows the current frame number and the
                    action that is used for this frame

                  * The next line shows the following metrics:

                    - Difference between previous & current frame
                    - Difference between current & next frame
                    - Difference between previous & next frame
                    - The difference used for determining the action
                    - The average used metric for the last 7 frames
                    - The frame's brightness (used to normalize differences)

                  * The last line shows two metrics that measure the similarity 
                    of the current resulting frame and the previous and next one.

                    If a badly telecined frame is found that has a small enough
                    difference to one of these neighbours it is replaced with 
                    it, otherwise a blend of the previous and next source frame 
                    is passed through, which has somewhat less vertical 
                    resolution  depending on the bobber that was used.

                  (default false)

pnThresh ........ Threshold for bad telecine detection; the smaller one of the 
                  prev/curr and curr/next differences minus the averaged used 
                  values must be pnThresh times larger than the prev/next 
                  difference for the frame to be detected as badly telecined.
                  Set to 0.0 or very high to turn this off. 
                  (default 2.5)

diffBias ........ Weight bias for difference weights:

                    0.0 gives a sine curve from -pi to pi
                    0.0 to -1.0 moves the end value towards 0 
                    0.0 to 1.0 moves the start value towards 0

                  Set this to below zero if your source is noisy. 
                  (default 0.0)

diffScale ....... The weights calculated using diffBias are values between 0.0 and 
                  1.0, which are then multiplied by this value - adjust this if your
                  setting for diffBias produces too small results
                  (default 16.0)

forceMatch ...... Force a match in case you want to derainbow progressive material

                    0 - automatic matching
                    1 - force curr/next matches
                    2 - force prev/curr matches

                  (default 0)

derainbow ....... 0 - Turn rainbow elimination off
                  1 - Turn rainbow elimination on
                  2 - Mark rainbows red
                  3 - Replace luma with gray and only show rainbows in chroma
                  4 - Show rainbow mask

                  NOTE: derainbowing will only work on 24 or 30FPS material where
                  the rainbows change with every new field.
                  (default 0)

rainbowThresh ... Color difference threshold for detecting rainbows, higher 
                  values detect less rainbows 
                  (default 32)

rainbowRadius ... Blur radius in pixels (1-8) that is used for nuking rainbows 
                  (a (2*r-1)^2 pixel area with the current pixel in the center is
                  being averaged, so 1 really doesn't do anything)
                  (default 4)

badFrames ....... 0 - Replace bad frames
                  1 - Pass bad frames through
                  2 - Pass bad frames through with their frame number in the top
                      right corner, skip up to 100 good frames per requested frame

                  (default 0)

dupeThresh ...... Threshold for duplicate detection; if a bad frame is detected and
                  the dupe difference of either the next or previous frame is lower
                  than this vale then the bad frame is replaced with it.
                  (default 500)

dupeBias ........ Weight bias for duplicate detection difference weights

                    0.0 gives a sine curve from -pi to pi
                    0.0 to -1.0 moves the end value towards 0 
                    0.0 to 1.0 moves the start value towards 0

                  Set this to below zero if your source is noisy. 
                  (default 0.0)

dupeScale ....... The weights calculated using dupeBias are values between 0.0 and 
                  1.0, which are then multiplied by this value - adjust this if your
                  setting for dupeBias produces too small results
                  (default 16.0)

coring .......... Set to true if input luma range is TV range (16-235); used for 
                  frame brightness calculation
                  (default true)

forceCPU ........ Force the filter to only use specific optimizations

                    0 ... autodetect
                    1 ... C++ code only
                    2 ... Use MMX code where available
                    3 ... Use MMX & Integer SSE code where available
                    4 ... Use MMX & SSE code where available
                    5 ... Use MMX & SSE & SSE2 code where available

                  (default 0)


Version history
===============

25.07.2004   Version 1.0

             * First Release - still missing de-rainbowing

28.07.2004   Version 1.1

             * First implementation of de-rainbowing using spatial nuking 
               (pure C only, though)

28.07.2004   Version 1.1a

             * D'oh - SSE frameblending code was disabled

31.07.2004   Version 1.2

             * Main part of de-rainbowing now also implemented with MMX

             * Fixed memory allocation bug where I used rainbowThresh instead of 
               rainbowRadius; this could crash if rainbowThresh wasn't at least
               2 times as big as rainbowRadius - and it wasted memory as well


Info
====

Contact: BlendBob-Briareos@sneakemail.com
         User "Leak" at http://forum.doom9.org/

Website: http://desdemona.ssw.uni-linz.ac.at/AviSynth/BlendBob/
