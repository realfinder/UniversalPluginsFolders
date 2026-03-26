GamMac(), [Gamma Machine] An extraordinary Idea by VideoFred (the gent from Gent). Coded by StainlessS.
Requires CPP runtimes from VS 2008.

    Home Thread:- http://forum.doom9.org/showthread.php?p=1774281#post1774281
    Idea:-        http://forum.doom9.org/showthread.php?t=173683

RGB Only.

    Useful to correct color cast on old 8mm films.
    Alters channel pixel average to match LockChan using Gamma correction. (By default alters Red and Blue channels to match Green).
    Additional tweaking via RedMul, GrnMul and BluMul multipliers.

    What it does(roughly):-
        Firstly, RAW input channel Ranges are measured for all three channels (see RngLim).
        If ALL THREE raw input ranges are less than RngLim (single color frame), then for current frame,
          there is no scaling nor gamma estimation, and only linear rendering is done to output range omin -> omax.
          [Channels multipliers RedMul, GrnMul and BluMul NOT applied either.]
        OtherWise,
            If ANY ONE channel input range is less than RngLim and Scale==2, then Scale is (for current frame) knocked down to Scale=1.
            Get Channel averages, minimums, and maximums (using loTh for minimums and hiTh for maximums).
            if(Scale==0 OR (loTh<0.0 AND hiTh<0.0)) then
                No rescaling.
            if(Scale == 1 AND (loTh>=0.0 OR hiTh>=0.0)) then
                rescales averages using combined dynamic range of r,g,b ie 0.0 -> (max(redMax,grnMax,bluMax) - min(redMin,grnMin,bluMin)).
            else if(Scale == 2 AND (loTh>=0.0 OR hiTh>=0.0)) then
                rescales averages using separate dynamic ranges ie 0.0->(redMax-redMin), 0.0->(grnMax-grnMin), 0.0->(bluMax-bluMin).
            For each channel, estimate gamma function that will remap (scaled channel average * channel multiplier) to match a particular
            LockVal (chosen via LockChan) when rendered to the chosen output range specified by omin and omax.
            Then renders frame using the output averages from estimated gamma with output channel minimums at omin, and maximums at omax.

GamMac(Clip c,int "LockChan"=1,int "Scale"=2,
      \ Float "RedMul"=1.0,Float "GrnMul"=1.0, Float "BluMul"=1.0,
      \ Float "Th"= 0.0,Float "loTh"=Th,Float "hiTh"=Th,
      \ Float "LockVal"=128.0,int "RngLim"=11,Float "GamMax"=10.0,
      \ Clip "dc",
      \ int "x"=20,int "y"=20,int "w"=-20,int "h"=-20,
      \ int "omin"=0, int "omax"=255,
      \ Bool "Show"=True,int "Verbosity"=2,Bool "Coords"=false,
      \ Bool "Dither=False"
      \ )

    LockChan Default 1(Grn).    Channel for lock to Average. [range -3 -> 2]
                                 0 ] LockVal = Scaled(RedAve)
                                 1 ] LockVal = Scaled(GrnAve)
                                 2 ] LockVal = Scaled(BluAve)
                                 -1] LockVal = Use explicit LockVal arg (see below).
                                 -2] LockVal = (Scaled(RedAve)+Scaled(GrnAve)+Scaled(BluAve))/3.0. [Mean]
                                 -3] LockVal = Median(Scaled(RedAve),Scaled(GrnAve),Scaled(BluAve))
                                Where Scaled(Channel Average) depends upon RngLim, Scale, and loTh, and hiTh.

    Scale, default 1           Range 0 -> 1.
                                There is NO SCALING DONE if ALL THREE channels range is less than RngLim, see RngLim, linear render only.
                                If ANY ONE channel input range is less than RngLim and Scale==2, then Scale is (for current frame) knocked down to Scale=1.

                                    where some described for Red Channel only:-
                                         redMin = RedChanMin(ignorePerc=loTh)        # Pixel minimum for red channel, ignoring up to loTh%, ie noise.
                                         redMax = RedChanMax(ignorePerc=hiTh)        # Pixel maximum for red channel, ignoring up to hiTh%, ie noise.
                                         redAve = RedChanAve()                       # Pixel average for red Channel.
                                         redRng = redMax - redMin
                                         inMin  = min(redMin,grnMin,bluMin)          # Min of minimums
                                         inMax  = max(redMax,grnMax,bluMax)          # Max of maximums

                                     0 (Scale==0 || (loTh==-1.0 && hiTh==-1.0))      # No Effect on scale.
                                         scaledAveR = redAve
                                         scaledAveG = grnAve
                                         scaledAveB = bluAve
                                     1) Scales input channel average maximum dynamic range of R,G,B, to 0.0->(ChanAve-inMin)*255.0/(inMax-inMin)
                                         scaler = 255.0 / (inMax - inMin)
                                         scaledAveR = min(max((RedAve - inMin) * scaler,0.0),255.0)
                                         scaledAveG = min(max((GrnAve - inMin) * scaler,0.0),255.0)
                                         scaledAveB = min(max((BluAve - inMin) * scaler,0.0),255.0)
                                     2) Scales input channel average dynamic range of R & G & B, Individually, to 0.0->(ChanAve-Chan_min)*255.0/(ChanMax-ChanMin)
                                         scalerR = 255.0 / (redMax-redMin)
                                         scalerG = 255.0 / (grnMax-grnMin)
                                         scalerB = 255.0 / (bluMax-bluMin)
                                         scaledAveR = min(max((redAve - redMin) * scalerR,0.0),255.0)
                                         scaledAveG = min(max((grnAve - grnMin) * scalerG,0.0),255.0)
                                         scaledAveB = min(max((bluAve - bluMid) * scalerB,0.0),255.0)

    RedMul, default 1.0         Red channel multiplier adjustment.   [0.1 <= RedMul <= 10.0]
    GrnMul, default 1.0         Green channel multiplier adjustment. [0.1 <= GrnMul <= 10.0]
    BluMul, default 1.0         Blue channel multiplier adjustment.  [0.1 <= BluMul <= 10.0]
                                Scaled averages are multiplied by their multiplier then given as args to the gamma estimator.
                                Allow tweaking of R,G,B channels.
                                   Above Multipliers only shown in metrics when at least one is != 1.0 (Always shown when Verbosity=3=FULL).

    Th, Default 0.00           Sets Default for loTh and hiTh. Suggest Default, 0.00(percent).  [-1.0(OFF) , or 0.0 -> 1.0]
    loTh, Default Th           As for Ignore_low in AutoLevels, or Threshold in YPlaneMin.  [-1.0, or 0.0 -> 1.0]
                               Percent, amount of extreme pixels (eg noise) to ignore when finding minimum R, G or B channel values.
                               -1.0 is OFF, input channel minimum is set to 0 as for levels(0,gamma,input_max, ... ).
                               If loTh >=0.0, then will scan frame looking for lowest pixel value whose cumulative sum
                               [including all pixels counts of lower value pixels] is greater than loTh%.
                               loTh, only shown in metrics if greater or equal to 0.0 ie switched ON (Always shown when Verbosity=3=FULL).
    hiTh, Default Th           As for Ignore_high in AutoLevels, or Threshold in YPlaneMax. [-1.0, or 0.0 -> 1.0]
                               Percent, amount of extreme pixels (eg noise) to ignore when finding maximum R, G or B channel values.
                               -1.0 is OFF, input channel maximum set to 255, as in levels(input_min,gamma,255, ... ).
                               If hiTh >=0.0, then will scan frame looking for highest pixel value whose cumulative sum
                               [including all pixels counts of higher value pixels] is greater than hiTh%.
                               hiTh, only shown in metrics if greater or equal to 0.0 ie switched ON (Always shown when Verbosity=3=FULL).

    LockVal, default 128.0     Only used if LockChan = -1. [0.0 < LockVal < 255.0] (set via LockChan if LockChan != -1)
                               There is no restricted range on this (other than 0.0 < LockVal < 255.0), so if you set a stupid value,
                               you will likely get stupid results.

    RngLim, default 11         [1 <= RngLim <= 32]
                               If ALL THREE RAW input channel ranges ie (ChannelMax(max(hiTh,0.0))-ChannelMin(max(loTh,0.0))) are less than RngLim then
                               all scaling is disabled, and remapping is linear without gamma estimation, to range omin -> omax,
                               ie avoid remapping of Black, White frames, or single color frames.

    GamMax, default 10.0       Upper value for guess gamma [1.0 < GamMax <= 10.0]
                                   Starting guess upper range and limit for gamma estimator (probably best left alone).
                                   The lower guess range and limit will be set to 1.0 / GamMax, by default 0.1.
                               Now allowing lower limit of GamMax to go as low as almost 1.0, GamMax now usable as
                               a gamma correction limiting device, where correction not allowed to exceed GamMax or go lower than
                               its reciprocal ie 1.0/GamMax. 'G' limited flag now added to flags line in metrics, hi-lited if Gamma
                               limited by GamMax (limiting includes any Red,Grn,BluMul, multiplier result).

    dc, default clip c.        Detection clip, Must be same ColorSpace and FrameCount as source clip, no other similarities enforced.
                               (can be different size, denoised etc).

    x,y, Both default 20.      Area of dc Detect clip frame to sample when getting averages and estimating Gamma function, allows to ignore rubbish at frame edges.
    w,h, Both default -20.     Specified as for crop eg x=10,y=20,w=-30,h=-40, as in crop(10,20,-30,-40).

    omin, default 0.           Output limits for all three R, and G, and B channels. [Range 0 -> 16]
    omax, default 255.         [Range 235 -> 255] (extremes 16->235 allow for Studio RGB output).
                               May want to give yourself a little head/foot room by setting eg omin=5, omax=250, so that you leave a little room for
                               further manual color tweaking.

    Show, default true        True, show metrics info on frame.
    Verbosity, default 2       0 = Only upper frame metrics Flags line only
                               1 = Upper frame metrics
                               2 = Upper + important ones. (default)
                               3 = Nearly Full metrics.
                               4 = Full Metrics except version info
                               5 = Full Metrics including version info
                               Upper frame metrics shown as eg:- (when Verbosity=5=FULL)

                                  nnnnn] Flags:- 1SRG
                                             R         G         B
                                  RAW:     10,253    10,253    10,253
                                  IN:      10,253    10,253    10,253
                                  IN_AVE:  78.466    88.552    78.767
                                  SCALED:  71.847    82.431    72.162
                                  GAMMA:    1.135     1.000     1.123
                                  OUTAVE:  82.431    82.422    82.451

                               where,
                                  nnnnn, is the frame number.
                                  Flags:- (Specific to current frame, can change frame to frame)
                                      '1' = LockChan, as above, channel '1'[ScaleAveG].
                                            Can be, '0', '1', '2' [ScaleAve Channel number LockChan=-3(median) assigns '0', '1' or '2' as appropriate]
                                                    'A'[LockChan=-2, (ScaleAveR+ScaleAveG+ScaleAveB)/3.0]
                                                    'V'[LockChan=-1, Explicit LockVal]
                                      'S' = Scale, mode signified by color.
                                            Greyed out. Scale = 0(No Effect). May be Greyed out if all channels Min/Max are 0,255.
                                            White.  Scale = 1[Scales input channel average maximum dynamic range of R,G,B]
                                            Orange. Scale = 2[Scales input channel average dynamic range of R and G and B, Individually]
                                      'R' = Limited by RngLim, mode signfied by color.
                                            Greyed out. Not Range Limited.
                                            Red, at least 1 channel has remapping disabled.
                                      'G' = Correction limited by GamMax, mode signfied by color.
                                            Greyed out. Not Range Limited.
                                            Orange hi-lite, at least 1 channel has GamMax limited gamma correction.                                            
                                  RAW:    Shows RAW comma separated channel minimum and maximum, eg ChannelMin(max(loTh,0.0)) and (ChannelMax(max(hiTh,0.0)),
                                          only shown if Verbosity>=3 or, if any RAW input range is less than RngLim AND any of the RAW inputs are different
                                          to the equivalent standard input.
                                  IN:     Shows comma separated channel minimum and maximum (dependent upon Scale, loTh, hiTh).
                                  IN_AVE: Input channel averages.
                                  SCALED: Scaled input averages, (dependent upon Scale, loTh, hiTh, channel minimums and maximums).
                                  GAMMA:  Estimated gamma to achieve lockval for channel. (dependent upon pretty much everything).
                                  OUTAVE: Output channel average ie rendered result.

                               ALL metrics derived from the detection clip dc (Including OutAve's).

    Coords, default False.  If True, then shows DC clip with dotted lines showing the x,y,w,h coords plotted on frame. (All other functionality disabled).

    Dither, default False. If true, then dithers output, hopefully reducing banding (will be quite a lot slower, no ASM).
    
