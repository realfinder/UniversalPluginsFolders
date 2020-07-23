Internaly multi-threaded resampling and desampling functions.

************************
Resampling
************************

The functions inside this plugin are :
PointResizeMT
BilinearResizeMT
BicubicResizeMT
LanczosResizeMT
Lanczos4ResizeMT
BlackmanResizeMT
Spline16ResizeMT
Spline36ResizeMT
Spline64ResizeMT
GaussResizeMT
SincResizeMT

Parameters are exactly the same than the orignal resampling functions, and in the same order, so they are totaly
backward compatible.

Several new parameters are added at the end of all the parameters :

   threads -
      Controls how many threads will be used for processing. If set to 0, threads will
      be set equal to the number of detected logical or physical cores,according logicalCores parameter.

      Default:  0  (int)

   logicalCores -
      If threads is set to 0, it will specify if the number of threads will be the number
      of logical CPU (true) or the number of physical cores (false). If your processor doesn't
      have hyper-threading or threads<>0, this parameter has no effect.

      Default: true (bool)

   MaxPhysCore -
      If true, the threads repartition will use the maximum of physical cores possible. If your
      processor doesn't have hyper-threading or the SetAffinity parameter is set to false,
      this parameter has no effect.

      Default: true (bool)

   SetAffinity -
      If this parameter is set to true, the pool of threads will set each thread to a specific core,
      according MaxPhysCore parameter. If set to false, it's leaved to the OS.
      If prefecth>number of physical cores, it's automaticaly set to false.

      Default: false (bool)

  sleep -
      If this parameter is set to true, once the filter has finished one frame, the threads of the
      threadpool will be suspended (instead of still running but waiting an event), and resume when
      the next frame will be processed. If set to false, the threads of the threadpool are always
      running and waiting for a start event even between frames.

      Default: false (bool)

  prefetch -
      This parameter will allow to create more than one threadpool, to avoid mutual resources acces
      if "prefetch" is used in the avs script.
      0 : Will set automaticaly to the prefetch value use in the script. Well... that's what i wanted
          to do, but for now it's not possible for me to get this information when i need it, so, for
          now, 0 will result in 1. For now, if you're using "prefetch" in your script, put the same
          value on this parameter.

      Default: 0

  range -
      This parameter specify the range the output video data has to comply with.
      Limited range is 16-235 for Y, 16-240 for U/V. Full range is 0-255 for all planes.
      Alpha channel is not affected by this paramter, it's always full range.
      Values are adjusted according bit depth of course. This parameter has no effect
      for float datas.
      0 : Automatic mode. If video is YUV mode is limited range, if video is RGB mode is
          full range, if video is greyscale (Y/Y8) mode is Y limited range.
      1 : Force full range whatever the video is.
      2 : Force limited Y range for greyscale video (Y/Y8), limited range for YUV video,
          no effect for RGB video.
      3 : Force limited U/V range for greyscale video (Y/Y8), limited range for YUV video,
          no effect for RGB video.
      4 : Force special camera range (16-255) for greyscale video (Y/Y8) and YUV video,
          no effect for RGB video.

      Default: 1

  ThreadLevel -
      This parameter will set the priority level of the threads created for the processing (internal
      multithreading). No effect if threads=1.
      1 : Idle level.
      2 : Lowest level.
      3 : Below level.
      4 : Normal level.
      5 : Above level.
      6 : Highest level.
      7 : Time critical level (WARNING !!! use this level at your own risk)

      Default : 6

The logicalCores, MaxPhysCore, SetAffinity and sleep are parameters to specify how the pool of thread
will be created and handled, allowing if necessary each people to tune according his configuration.

So, syntax is :
ResampleFunction([original parameters],int threads, bool logicalCores, bool MaxPhysCore, bool SetAffinity,
  bool sleep, int prefetch,int range,int ThreadLevel)


************************
Desampling
************************

The functions inside this plugin are :
DeBilinearResizeMT
DeBicubicResizeMT
DeLanczosResizeMT
DeLanczos4ResizeMT
DeBlackmanResizeMT
DeSpline16ResizeMT
DeSpline36ResizeMT
DeSpline64ResizeMT
DeGaussResizeMT
DeSincResizeMT

Parameters are identicals to the resampling functions, except there is two others parameters at the end.

   accuracy -
      Will specify the accuracy used for the desampling.
      0 : Average
      1 : A little less than 0.
      2 : A little better than 0.

      Default:  0  (int)

   order -
      Will specify in what order the desampling will be done (process horizontal or vertical first).
      0 : Automatic, will choose according the same method implemented in the core filters.
      1 : Process vertical first.
      2 : Process horizontal first.

      Default:  0  (int)


So, syntax is :
DesampleFunction([parameters of ResampleMT without ThreadLevel],int accuracy,int order,int ThreadLevel)

The usage is the following : You have to enter in the parameters exactly the same that have been
used for the original resampling, except the size of course, where you specify the original size you want back.

For exemple, if the source file is a 1280x720 video :

Spline36ResizeMT(1920,1080,src_left=-0.2)
# or Spline36Resize(1920,1080,src_left=-0.2)
# To revert :
DeSpline36ResizeMT(1280,720,src_left=-0.2)

For more informations, go here : https://forum.doom9.org/showthread.php?p=1817097#post1817097

