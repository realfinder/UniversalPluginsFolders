/*
    SpotLess v1.04. temporal spot/noise remover, by StainlessS @ Doom9.   https://forum.doom9.org/showthread.php?t=181777
    Original idea from Didée post :-                                      https://forum.doom9.org/showthread.php?p=1402690#post1402690
    Req:- Pinterf MvTools2(), Pinterf Medianblur2() with MedianBlurTemporal rather than the MedianBlurT() from Didée post.
          With appropriate plugins, will be AVS+ colorspace and x64 compatible.
          Fine using Avs+ Prefetch() so long as current Pinterf plugins, and Frame Accurate source.

    NOT FOR cartoon/anime, live video only, sorry.

    v1.01, Remove RadT Max check. Add MSuper(hpad=16,vpad=16). Add BlkSz arg.
    v1.02, Add some stuff.
    v1.03, Frame size auto config of args removed (found instances where caused problems). Added Glob and bBlur args.
    v1.04, Script breaking changes, I guess is more flexible if can also set ThSAD, inserted ThSAD 3rd arg. RadT now default 1, was 2, dont over denoise unless requested.

    SpotLess(clip c,int "RadT"=1,int "ThSAD"=10000,int "ThSAD2"=ThSAD,int "pel"=2,bool "chroma"=true, int "BlkSz"=8,Int "Olap"=BlkSz/2,bool "tm"=true,Bool "glob"=Tm,Float "bBlur"=0.0)

    RadT, 1 or more, Default 1. Removes Spots on up to RadT [Temporal Radius] consecutive frames.
        RadT > 2 will usually be overkill. Setting too high could possibly result in blurring.
        Each pixel in result frame is median pixel value of (2*RadT+1) motion compensated frames (including source, ie current_frame-RadT to current_frame+RadT).

    ThSAD, Default 10000=NEARLY OFF(ie ignore hardly any bad blocks), 0 < ThSAD < 16320(8*8*255). 8x8 block SAD threshold at radius 1 (ie at current_frame +- 1) [SAD, Sum of Absolute (pixelwise) Differences].
        ThSAD and ThSAD2 suggested absolute minimum of maybe about 400.
        ThSAD and ThSAD2 thresholds are based on 8 bit 8x8 block, irrespective of colorspace depth or BlkSz, max=8x8x255=16320, use same thresholds where High Bit Depth.
        In mvTools MCompensate(), when creating a compensated block the SAD between compensated block and the same original block in current_frame, the 8 bit SAD is measured and if
        greater than SAD threshold then that block is ignored and uses original block from current frame instead. [The compensated block is judged too different, so ignored & original block used instead
        in the result MCompensated frame].
        Where eg ThSAD=64, AVERAGE absolute single pixel difference threshold would be 64/(8*8)=1, so AVERAGE absolute pixel difference greater than 1 would ignore that mcompensated block and use the
        block from current frame in the resulting mcompensated frame instead. This example allows for all pixels in a 8x8 block to be different by 1, or a single pixel in 8x8 block to be different by 64,
        or some other mixture.
          A problem with above is, if a low ThSAD and current_frame block is mostly noise, so compensated blocks could be judged bad because they are too different to the bad noisey block, and the result
        block may/will be just as bad as the noisy source block. A possible solution to this problem is to have a higher SAD threshold and/or have a bigger BlkSize so that the number of bad source pixels
        after converting/scaling to as if an 8x8 block, will contain fewer bad noise pixels. So, SpotLess BlkSz arg would ideally maybe 4 or more times the area of the largest spots that you have, and a SAD
        threshold big enough so as to not ignore the block [ wild guess minimum SAD threshold for big spot sizes of (8x8x255)/4 = 4080 ].
        Where a complete source frame is bad, then maybe should have very high (eg 10000) SAD threshold, and BlkSz may not really matter too much.
          It is not the end of the world if some of the compensated blocks are ignored and swapped for the original current_frame block. Nor is it the end of the world if
        no blocks were ignored because of high SAD threshold. The final result pixel is median pixel value of (2*RadT+1) motion compensated blocks, so allowing for some mistakes by choosing the
        middle pixel value.
        I've just tested real bad double frame, full frame luma and chroma corruption, with below line:
            SpotLess(RadT=5,ThSAD=1000000,ThSAD2=1000000,pel=2,chroma=false,BlkSz=8,Olap=4,tm=false,glob=false,bBlur=0.0)
        And although both SAD thresholds of 1 million, are totally impossible and so no blocks could possibly be ignored and yet we still got pretty good results, all frames were fixed
        as we still had the temporal median filter to fall back on and pick the middle pixel value.

        From mvtools2 docs:
          ThSAD is SAD threshold for safe (dummy) compensation.
              If block SAD is above the thSAD, the block is bad, and we use source block instead of the compensated block. Default is 10000 (practically disabled).

    ThSAD2, Default ThSAD, 0 < ThSAD2 < 16320(8*8*255), Lower removes fewer spots, but less chance of blurring.
        ThSAD2 sets the SAD [Sum of Absolute Differences] threshold for most distant frame from current_frame at distance RadT, with those frames that are distances in-between 1 and RadT
        acquiring a SAD threshold linearly interpolated between the two.
        From mvtools2 docs:
          ThSAD2:
              Defines the SAD soft threshold for the furthest frames at current_frame +- RadT.
              The actual SAD threshold for each reference frame is a smooth interpolation between the original thSAD (close to the current frame)
              and thSAD2. Setting thSAD2 lower than thSAD allows large temporal radii and good compensation for low SAD blocks while reducing the global error and the
              risk of bluring when the result of MCompensate is passed to a temporal denoising filter.
        EDIT: Although I have said that SAD threshold being too high could result in blurred frames, that is really taken from above "risk of bluring" line from mvtools docs,
        however, that warning says "temporal denoising filter", which might suggest pixel averaging, whereas we are using pixel median. I'm not sure that blurring would be the result
        of having too high a SAD threshold.

    Pel,     Default 2. 1, 2, or 4. Maybe set 1 for HD+. (1=precision to pixel, 2=half pixel, 4=quarter pixel)

    Chroma,  Default True. MAnalyse chroma arg. If true, use chroma in block matching when creating vectors. Maybe use False if source B&W or color noise.

    BlkSz,   Default 8. MAnalyse BlkSize. Bigger blksz quicker and perhaps better for HD clips. [Info: current Pinterf MvTools allows for BlkSize=12, and overlap=6]

    OLap,    Default half BlkSz, Block overlap.

    Tm,      TrueMotion Default True. Some folk swear truemotion=false is better.

    Glob,    Default Tm, Allow set MAnalyse(global) independently of TrueMotion.
             From MvTools2 docs for MAnalyse,
               global
                 Estimate global motion (at every level) and use it as an additional predictor.
                 Only pan shift is estimated (no zoom and rotation).
                 Use false to disable, use true to enable. Default is like truemotion.

    bBlur,   Default 0.0 [OFF]. If used, Suggest about 0.6, where MAnalyse create vectors is performed on denoised (blurred) super clip.
*/

Function SpotLess(clip c,int "RadT",int "ThSAD",int "ThSAD2",int "pel",bool "chroma", int "BlkSz",Int "Olap",bool "tm",Bool "glob",Float "bBlur") {
    RadT     = Default(RadT,1)        # Temporal radius. (MCompensate arg)
    ThSAD    = Default(ThSAD,10000)   # SAD threshold at radius 1 (Default Nearly OFF).
    ThSAD2   = Default(ThSAD2,ThSAD)  # SAD threshold at radius RadT.
    Pel      = Default(pel,2)         # Default 2. 1, 2, or 4. Maybe set 1 for HD+. (1=precision to pixel, 2=precision to half pixel, 4=quarter pixel)
    Chroma   = Default(chroma,True)   # MAnalyse chroma arg. If set to true, use chroma in block matching.
    BlkSz    = Default(BlkSz,8)       # Default 8. MAnalyse BlkSize. Bigger blksz quicker and perhaps  better, esp for HD clips. Maybe also better where BIG noise.
    OLap     = Default(OLap, BlkSz/2) # Default half of BlkSz.
    Tm       = Default(tm,True)       # TrueMotion, Some folk swear MAnalyse(truemotion=false) is better.
    Glob     = Default(glob,Tm)       # Default Tm, Allow set MAnalyse(global) independently of TrueMotion.
    Bblur    = Default(bblur,0.0)     # Default OFF
    Assert(1 <= RadT,"SpotLess: 1 <= RadT")
    pad      = max(BlkSz,8)
    sup      = (bBlur<=0.0  ? c   : c.blur(bblur)).MSuper(hpad=pad,vpad=pad,pel=pel,sharp=2)
    sup_rend = (bBlur<=0.0) ? sup : c.MSuper(hpad=pad,vpad=pad,pel=pel,sharp=2,levels=1) # Only 1 Level required where not MAnalyse-ing.
    MultiVec = sup.MAnalyse(multi=true, delta=RadT,blksize=BlkSz,overlap=OLap,search=4,chroma=Chroma,truemotion=Tm,global=Glob)
    c.MCompensate(sup_rend,MultiVec,tr=RadT,thSad=ThSAD,thSad2=ThSAD2)
    MedianBlurTemporal(radiusY=0,radiusU=0,radiusV=0,temporalradius=RadT)  # Temporal median blur only [not spatial]
    SelectEvery(RadT*2+1,RadT)                                             # Return middle frame
}