File: Readme_TomsMoComp.txt 

TomsMoComp - Motion Compensating Deinterlace Filter

Copyright (c) 2002 Tom Barry.  All rights reserved.
    trbarry@trbarry.com

Requires Avisynth source code to compile for Avisynth
Avisynth Copyright 2000 Ben Rudiak-Gould.
    http://www.math.berkeley.edu/~benrg/avisynth.html

This file is subject to the terms of the GNU General Public License as
published by the Free Software Foundation.  A copy of this license is
included with this software distribution in the file COPYING.  If you
do not have a copy, you may obtain a copy by writing to the Free
Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.

This software is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details

Also, this program is "Philanthropy-Ware".  That is, if you like it and feel
the need to reward or inspire the author then please feel free (but not obligated) 
to consider joining or donating to the Electronic Frontier Foundation. This will 
help keep cyber space free of barbed wire and bullsh*t.  

See their web page at www.eff.org.


***************

Okay, on to business. 

TomsMoComp.dll is a filter (for Avisynth and DScaler 4.0) that uses motion compensation
and adaptive processing to deinterlace video source. It uses a variable amount of CPU 
time based upon the user specified SearchEffort parameter.  The SearchEffort may currently be
set anywhere from 0 (a smarter Bob) to about 30 (too CPU intensive for everybody). Only certain
values are actually implemented (currently 0,1,3,5,9,11,13,15,19,21,max) but the nearest value
will be used.  Values above 15 have not been well tested and should probably be avoided for now.

TomsMoComp should run on all MMX machines or higher. It has also has some added code 
for 3DNOW instructions for when it is running on a K6-II or higher and some SSEMMX 
for P3 & Athlon.


***************

For DScaler:

TomsMoComp will be included with future releases of DScaler but to test with a current alpha 
R4.0 release just unzip the DI_TomsMoComp.dll file into your DScaler folder. Then restart
DScaler and choose Settings/Deinterlace/TomsMoComp as your deinterlace method.

You may also want to leave Auto Pulldown Detection turned on because TomsMoComp is strictly
for pure video source and does not offer the implied pulldown removal of methods like
Greedy (High Motion).  If you are getting jerkiness or dropped frames you should lower
the SearchEffort value (default 5).


***************

For Avisynth:

Just unzip the TomsMoComp.dll from the Avisynth zip folder into your Avisynth directory, or 
somewhere. As the script below shows, I made a subdirectory under Avisynth just to keep it separate.

Sample avs script:

LoadPlugin("d:\AVISynth\TomsMoComp\Release\TomsMoComp.dll")
clip = AVISource("c:\vcr\bikes.avi")
return clip.TomsMoComp(-1,5,1)

Of course replace the file and directory names with your own and supply the desired integer
values for parameters.

The above avs file specifies for TopFirst=auto, SearchEffort=5, and a Vertical Filter option to be
turned on.  

***************

A WARNING FOR DEVELOPERS

There is a quirk in TomsMoComp inline assembly code or in VS6 such that it will crash
if compiled with C optimizations (or at least auto inlining) turned on. They must
be OFF. Since all the work is done in assembly anyway you don't need them. I'll
figure it out someday.


***************

TomsMoComp Parm list:

  TomsMoComp(TopFirst, SearchEffort, VerticalFilter)

All the values are integer, 0=no, 1=yes:

  TopFirst - assume the top field, lines 0,2,4,... should be displayed first. 
    The default is the supposedly more common BottomFirst (not for me). You may
	have to bring it up in Virtualdub and look at a few frames to see which 
	looks best. (0=BottomFirst, 1=TopFirst)
	
	New - setting TopFirst=-1 will automatically pick up whatever Avisynth reports.
	
  SearchEffort - determines how much effort (CPU time) will be used to find 
    moved pixels. Currently numbers from -1 to 30 with 0 being practically
	just a smarter bob and 30 being fairly CPU intensive. 
	
	For Avisynth only, a value of -1 is supported. In this case the TomsMoComp
	filter will not deinterlace but instead assume you already have progressive
	frames but want to double the vertical size.  I found by accident that this could 
	give slightly better apparent detail than regular scaling algorithms and is useful
	for low bit rate captures that are hard to IVTC/deinterlace or where you have just
	kept the even fields for some other reason.  I'm considering making a DirectShow
	version of this to be run at display time, or possibly adding it to ffDshow.

	
  VerticalFilter - If turned on will very slightly blend each pair of horizontal lines
    together.  This loses only a small amount of vertical resolution but is probably
	a good idea as it can somewhat hide remaining deinterlace artifacts and will 
	probably also make you clip compress a bit better. (0 = no filter, 1 = filter)

***

Known issues and limitations (for both DScaler and Avisynth):

1) 	Assumes YUV (YUY2 or YV12) Frame Based input. Use an Avisynth function to convert first if
    needed.  YV12 is supported by the 2.5 Avisynth Alpha version only.        

2)  Currently still requires the pixel width to be a multiple of 4. This probably
    shouldn't be required but I pilfered the code from some of my other filters.
	Sorry, I'll fix it later.

3)  So far it has only been tested on SSEMMX machines. (now others)

4)  TomsMoComp is for pure video source material. Use IVTC, DeComb, or DScaler's
    Auto Pulldown processing for mixed or film source material.
	
	
Temporary file locations:

For now, both source, this readme, and DLL should be at:
	
	www.trbarry.com/TomsMoComp.zip
	

A copy of this Readme_TomsMoComp.txt file should be at:
  	
	www.trbarry.com/Readme_TomsMoComp.txt
	
The source is included in above zip file and also in the TomsMoComp directory
of the DScaler project at SourceForge, www.sourceforge.org (including Avisynth version)
	
If you have questions email Tom Barry, trbarry@trbarry.com

Cheers,

- Tom

***************

// Change Log
//
// Date          Version    Developer          Changes
//
// 17 Jun 2003   0.0.1.7    Tom Barry	       Fix YV12 crash bug when TF=0
// 17 Jun 2003   0.0.1.6    Tom Barry	       Fix SearchEffortW for YUY2
											   Change various "2" to BPP for YV12 (bits/pixel
// 21 Jan 2003   0.0.1.5    Tom Barry	       Same source compiled without Optimize 
// 18 Jan 2003   0.0.1.4    Tom Barry	       Use AvisynthPluginit2 
// 12 Nov 2002   0.0.1.3    Tom Barry	       YV12 support for Avisynth 2.5 Alpha 
// 07 Jul 2002   0.0.1.0    Tom Barry	       Create TomsMoComp Deinterlacer 
//                                             (still brand new and experimental!)





















