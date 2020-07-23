# MC_Spuds()  
# Motion compensated noise removal with sharpening -- version: 1.1 BETA - 21.AUG.08
#
# Use import("mc_spuds.avs")  MUST BE IN YV12 and mod 8 size
#
# Thanks to Didee for his comments, scripts and posts from which I learned much and borrowed from :) 

global idx_pointer = 24

FUNCTION MC_Spuds_mvt( clip clp, int "frames", int "strength", int "blocksize", int "overlap", int "thsad", int "dct", int "ml", \
                    bool "chro", bool "postprocess", bool "preprocess", bool "aggressive",int "debug", int "thSCD1", int "thSCD2", \                    
                    bool "edgeclean", bool "focus", bool "removeblocks", bool "starfield", bool "anime", float "ss_x", int "sharpp", \
                    float "ss_y", int "lsfstr", bool "addnoise", int "shadow_l", int "shadow_h", float "thStar", int "limit", int "pnew", \
                    int "edm_lo", int "edm_hi", bool "flow", int "search", bool "colorbleed", int "quant1", int "quant2", int "uv" , \
                    bool "temporal", int "pel", int "sharp", bool "premax", int "lumathres", int "lambda", bool "truemotion" , \
                    int "lsad", int "plevel", bool "mvglobal", float "fs1", float "fs2", float "fs3", float "fs4", bool "prefast", \
                    int "prefilter", bool "gpu", bool "premc", string "mode")
{
  # some quick presets to make things easy
  mode_num = 0
  mode     = Default(mode, "")
  mode_num = mode == "very low"   ? 1 : mode_num
  mode_num = mode == "low"        ? 2 : mode_num
  mode_num = mode == "medium"     ? 3 : mode_num
  mode_num = mode == "medium high"? 4 : mode_num
  mode_num = mode == "high"       ? 5 : mode_num
  mode_num = mode == "very high"  ? 6 : mode_num
  mode_num = mode == "anime low"  ? 7 : mode_num
  mode_num = mode == "anime high" ? 8 : mode_num

  #                             default   vlow    low     med     med hi  hi      vhi    anim1   anim2
  _frames     = Select(mode_num   , 2     , 1     , 1     , 2     , 3     , 3     , 4    , 2     , 3)
  _strength   = Select(mode_num   , 3     , 1     , 2     , 3     , 4     , 4     , 5    , 2     , 3)
  _temporal   = Select(mode_num   , false , false , false , false , false  , true  , false, false , true)
  _anime      = Select(mode_num   , false , false , false , false , false , false , false, true  , true)
  _aggressive = Select(mode_num   , false , false , false , false , false , false , true , false , false)
  _prefilter  = Select(mode_num   , 2     , 0     , 1     , 2     , 2     , 2     , 3    , 2     , 2)
  _starfield  = Select(mode_num   , false , false , false , false , false , true  , true , true  , true)
  _chro       = Select(mode_num   , false , false , false , false , false , true  , true , false , true)

  # set up our parameters based on what the user input 
  starfield   = default( starfield ,    _starfield ) # Special mode to try and keep stars in the sky, mostly for anime
  aggressive  = default( aggressive ,   _aggressive ) # special two pass mode
  prefilter   = default( prefilter ,    _prefilter) # 0 off, 1 fast, 2 strength based, 3 max, 4 motion compensated
  temporal    = default( temporal ,     _temporal ) # special mode for temporal denoising for use with aggressive flag only.
  strength    = default( strength ,     _strength ) # how aggressive to remove noise / grain, sets predefined defaults
  frames      = default( frames ,       _frames ) # Number of frames to use in MC analysis
  anime       = default( anime ,        _anime ) # Special mode for anime ... sets dct=3 and removeblocks=true
  chro        = default( chro,          _chro ) #  include chroma planes in the denoising? this takes much extra time
  
  # special processing modes
  colorbleed  = default( colorbleed ,   false ) # Special mode to remove color bleeding
  flow        = default( flow ,         false ) # Special mode to use mvcompensate vs mvdegrain3 for frames=3
  addnoise    = default( addnoise ,     false ) # Special mode to add some grain in dark areas, help with compression and detail illusion
  focus       = default( focus ,        false ) # special mode to try and crisp up edges of blurry / soft video, code from IIP
  gpu         = default( gpu ,          false ) # if true us fft3dgpu
  unblock     = default( removeblocks,  false ) # Special mode to try and kill blocking
  debug       = default( debug,              0 ) # show some debug info on the screen
  
  # defaults for various processing modes
  lumathres   = default( lumathres,     159)   # cut off luma level for spots to be considered stars
  shadow_l    = default( shadow_l ,     24)    # Low limit for dark grain mask
  shadow_h    = default( shadow_h ,     42)    # high limit for dark grain mask
  edm_lo      = string( default(edm_lo ,75))   # edge detection low threshold
  edm_hi      = string( default(edm_hi ,255))  # edge detection hi threshold
  sharpp      = default( sharpp ,       3 )    # sharpening function to use 0=off 1=contra, 2=limitedsharpenfaster, 3=mc
  ls_x        = (sharpp == 3 ) ? default( ss_x , 1.25 ) : default( ss_x , 1.50 ) # LSF ss_x
  ls_y        = (sharpp == 3 ) ? default( ss_y , 1.25 ) : default( ss_y , 1.50 ) # LSF ss_y
  lsfstr      = default( lsfstr ,       100 )  # Strength parameter in limited sharpen faster
  quant1      = default( quant1 ,       0 )    # quant 1 for deblock_qed
  quant2      = default( quant2 ,       45 )   # quant 2 for deblock_qed
  uv          = default( uv ,           1 )    # uv for deblock_qed
  pel         = default( pel ,          2 )    # pel for MVAnalyse
  sharp       = default( sharp ,        2 )    # sharpening to use in mvanalysis 0,1,2
  search      = default( search ,       2 )    # search mode for mvanalysis
  truemotion  = default( truemotion ,  false ) # mvtools preset for seting lambda, lsad, pnew, plevel, global
  
  # Parameters that are based off the strength value
  blocksize   = (defined(blocksize))    ? blocksize    : select(strength , 8    , 8    , 8    , 16    , 16     , 16    , 16)  # blocksize for motion search
  lsad        = (defined(lsad))         ? lsad         : truemotion ? 1150 * blocksize * blocksize / 64 : 375 * blocksize * blocksize / 64 # SAD limit for lambda
  pnew        = (defined(pnew))         ? pnew         : truemotion ? 32 : 0   # prevent replacing of an already good predictor by one thats just a little better 
  lambda      = (defined(lambda))       ? lambda       : truemotion ? select(strength , 256   , 256   , 256   , 256   , 512   , 512  , 512)   : 32   # set the coherence of the field of vectors. The higher, the more coherent
  plevel      = (defined(plevel))       ? plevel       : truemotion ? 1 : 0 # penalty factor lambda level scaling mode. Value=0 - no scaling, 1 - linear, 2 - quadratic
  mvglobal    = (defined(mvglobal))     ? mvglobal     : truemotion # estimate global motion (at every level) and use it as an additional predictor
  thStar      = (defined(thStar))       ? thStar       : (anime) ? 0.0925 : 0.0225 # Frame average luma threshold, is it just noise or a starfield we are looking at
  overlap     = (defined(overlap))      ? overlap      : select(strength , 2     , 2     , 2     , 4     ,8     , 8    , 8)  # overlap of the block for motion search
  thsad       = (defined(thsad))        ? thsad        : select(strength , 100   , 300   , 400   , 425   , 450   , 450  , 500) # threshold to motion, increase for more grain removal ie 500
  thscd1      = (defined(thscd1))       ? thscd1       : select(strength , 400   , 400   , 500   , 500   , 550   , 600  , 600) # threshold to motion compared to SAD
  thscd2      = (defined(thscd2))       ? thscd2       : (anime) ? select(strength , 85   , 85   , 85   , 85   , 85  , 85  , 85)  \ 
                                                       : select(strength , 115   , 115   , 115   , 115   , 115   , 115  ,115) # Scene detection threshold, how much must a frame must change to be a scene change
  ml          = (defined(ml))           ? ml           : select(strength , 130   , 130   , 120   , 110   , 100    , 90   , 90) # threshold for the motion mask inclusion, lower includes more
  limit       = (defined(limit))        ? limit        : select(strength , 48   , 96   , 102   , 160   , 192    , 225   , 255) # threshold for the motion mask inclusion, lower includes more
  premax      = (defined(premax))       ? premax       : select ( prefilter , false, false, false, true, false) # override strength based vector search denoising and turn it on high
  prefast     = (defined(prefast))      ? prefast      : (prefilter == 2) ? select(strength , true , true , true , true , false , false , false) : select ( prefilter , false, true, false, false, false ) # special pre-process mode which is faster but less aggressive.  Speeds up overall processing
  premc       = (defined(premc))        ? premc        : select ( prefilter , false , false, true, false, true) # turn on mc prefiltering
  preprocess  = (defined(preprocess))   ? preprocess   : (prefilter == 2) ? select(strength , false , false , true  , true  , true  , true , true) : select ( prefilter , false, true, true, true, true ) # pre-process for improved motion vector search
  postprocess = (defined(postprocess))  ? postprocess  : select(strength , false , false , false , false , false , false , true) # postprocess clip for extra noise removal?
  edgeclean   = (defined(edgeclean))    ? edgeclean    : select(strength , false , false , false  , true  , true  , true , true) # edge clip for extra noise removal?
  dct         = (defined(dct))          ? dct          : (anime && blocksize ==8) ? 3 : 0  # dct should be zero most things, there is a high speed penalty if you use a non zero dct with a blocksize <> 8
  
  # input checking and variable changing if necessary, try to resolve conflicts in selected options
  frames      = (frames < 1) ? 1 : (frames > 4)     ? 4          : frames
  fs1         = (flow && frames > 2) ? default( fs1 ,          2.75 ) : default( fs1 ,          3.0 ) # first sigma value for flow processing
  fs2         = default( fs2 ,          2.5 ) # second sigma value for flow processing
  fs3         = default( fs3 ,          1.5 ) # third sigma value for flow processing
  fs4         = default( fs4 ,          0.5 ) # fourth sigma value for flow processing
  blocksize   = (blocksize == 16)                   ? blocksize  : (blocksize == 8) ? blocksize : (blocksize == 4) ? blocksize : 8
  overlap     = (blocksize == 4 && overlap == 2)    ? overlap    : (blocksize == 8 && overlap == 2) ? overlap : (blocksize == 8 && overlap == 4) ? overlap : (blocksize == 16 && overlap == 8) ? overlap : (blocksize == 16 && overlap == 4) ? overlap : (blocksize == 16 && overlap == 2) ? overlap : 0
  dct         = (dct < 0)                           ? 0          : (dct > 4) ? 4 : dct
  sharpp      = (sharpp < 0) ? 0 : (sharpp > 3)     ? 3          : sharpp # which sharpening function to use in the script
  sharp       = (sharp  < 0) ? 0 : (sharp > 3)      ? 3          : sharp # which sharpening to use in mvanalyse
  premax      = (temporal) ? true : premax 
  prefast     = (temporal) ? false : prefast
  th_hi       = string(shadow_h)
  th_lo       = string(shadow_l)
  fft         = (gpu) ? "fft3dgpu(mode=1,precision=1," : "fft3dfilter("

  # baseline clip color space error check, mod 4 size and confilcting user inputs
  check1 = ((aggressive && !temporal) || (!aggressive && temporal) || (!aggressive && ! temporal)) ? 1 : 0
  Assert((width(clp)%4 == 0 && height(clp)%4 == 0),"Width and Height must be divisible by 4 (Mod 4) for MC_Spuds")
  Assert((isyv12(clp) == true),"Please convert color space to YV12 for MC_Spuds")
  Assert((check1 == 1),"Use Aggressive or Temporal processing, not both")
    
  # calculate the appropriate borders so its width and height are mod 16, these will be removed later
  x_temp      = ab16(clp.width)
  x1          = round(x_temp / 2.0)
  x0          = int(x_temp - x1)
  y_temp      = ab16(clp.height)
  y1          = round(y_temp / 2.0)
  y0          = int(y_temp - y1)
  
  # add blank borders (to improve frame edge processsing and make the clip mod 16), we will remove these at the end.  
  # clp = clp.addborders(x0,y0,x1,y1)
  clp = clp.pointresize( clp.width()+x_temp, clp.height()+y_temp, -x0, -y0, clp.width()+x_temp+.001, clp.height()+y_temp+.001 )
  nullclp = blankclip(clp)

  # save stars if requested and check the mask is validated via the luma value (ie enough of a mask to be stars and not noise spots)
  maskstar = (starfield) ? Starmask(clp, anime, nullclp, thstar, lumathres, fft) : nullclp.mt_binarize(upper=false)
    
  # Make the call to deblock_qed if asked
  clp1 = (unblock) ? clp.deblock_qed(quant1=quant1,quant2=quant2,uv=uv) : clp
  
  # Are we going to be aggressive? If so make the first pass denoise call but lower the thresholds
  aframes    = (aggressive && frames == 4 && !flow) ? 3  : 2
  aoverlap   = (aggressive)                          ? 4  : overlap
  ablocksize = (aggressive)                          ? 16 : blocksize
  apremc     = (aggressive)                          ? false : premc
  clp1       = (aggressive && flow) ? clp1.f14_flow_mvt(chro, aframes, ablocksize, aoverlap, dct, nullclp, unblock, thscd1, thscd2, preprocess, \
                                                     strength, search, pel, premax, sharp, temporal, thsad, lambda, lsad, pnew, plevel, \
                                                     mvglobal, fs1, fs2, fs3, fs4, prefast, fft, apremc, nullclp, nullclp) \
             : (aggressive) ? clp1.f14_degrain_mvt(chro, preprocess, strength, aframes, ablocksize, aoverlap, dct, thsad, nullclp, unblock, \
                                                thscd1, thscd2, limit, search, anime, pel, temporal, premax, sharp, lambda, lsad, pnew, plevel, \
                                                mvglobal, prefast, fft, apremc, nullclp, nullclp) \
             : clp1
 
  # Compute our static and motion masks now, we will use these later for prefilter and sharpening masks. For now use the two trailing vectors bv1 bv2  
  global idx_pointer = idx_pointer + 1
  vector_prefilter = clp1
  bv1 =  vector_prefilter.mvanalyse(lambda=128,blksize=blocksize,overlap=overlap,chroma=chro,isb=true,delta=1,idx=idx_pointer) 
  bv2 =  vector_prefilter.mvanalyse(lambda=128,blksize=blocksize,overlap=overlap,chroma=chro,isb=true,delta=2,idx=idx_pointer) 

  # Use the vectors to create motion and static masks, we use these for prefilter and sharpening masks
  maskmotion1 = (premc || sharpp > 0) ? mt_average(clp1.mvmask(kind=0, vectors=bv2, gamma=1, ml=ml),clp1.mvmask(kind=0, vectors=bv1, gamma=1, ml=ml)) : nullclp
  maskmotion1 = (premc || sharpp > 0) ? mt_adddiff(maskmotion1, mt_makediff(maskmotion1,nullclp)).mt_inflate : nullclp # normalize upward
  maskmotion2 = (premc || sharpp > 0) ? clp1.mt_motion(thy1=5,thy2=10,thc1=5,thc2=10,u=3,v=3).mt_lut(expr="x 255 == x 156 - 0 ?") : nullclp # soften the hard mask
  maskmotion  = (premc || sharpp > 0) ? mt_lutxy(maskmotion1,maskmotion2,expr="x 0 == 0 x y < y x ? ?") : nullclp # if it exists in the first mask then keep the max of the two 
  maskstatic  = (premc || sharpp > 0) ? mt_invert(maskmotion) : nullclp
  
  # Make the denoise function call, this could be a 2nd or first pass if not aggressive
  preprocess = (aggressive) ? false : preprocess # no need to preprocess a second time when aggressive processing is on
  clp2 = ( flow ) ? clp1.f14_flow_mvt(chro, frames, blocksize, overlap, dct, nullclp, unblock, thscd1, thscd2,\
                                  preprocess, strength, search, pel, premax, sharp, temporal, thsad, lambda, lsad, pnew, plevel, \
                                  mvglobal, fs1, fs2, fs3, fs4, prefast, fft, premc, maskmotion, maskstatic) \
                  : clp1.f14_degrain_mvt(chro, preprocess, strength, frames, blocksize, overlap, dct, thsad, nullclp,  \
                                     unblock, thscd1, thscd2, limit, search, anime, pel, temporal, premax, sharp, \
                                     lambda, lsad, pnew, plevel, mvglobal, prefast, fft, premc, maskmotion, maskstatic) 
 
  # replace stars that might have been removed by denoising  
  clp2 = (starfield) ? mt_merge(clp2,clp,maskstar) : clp2
  
  # don't sharpen motion, dark area or starfield areas
  maskstatic = (sharpp > 0) ? mt_lutxy(clp2,maskstatic,"x 32 < 0 y ?") : maskstatic  
  maskstatic = (starfield && sharpp > 0) ? mt_makediff(maskstatic,maskstar.mt_expand.mt_inflate) : maskstatic
  
  # create our filtered clips to apply via the masks, don't go to heavy on smoothed since we have already degrained.
  #smoothed_clp = (anime && chro) ? clp2.RemoveGrain(mode=5) \
  #             : (anime) ? clp2.RemoveGrain(mode=5, modeU=0, modeV=0) \
  #             : (chro) ? clp2.RemoveGrain(mode=17) : clp2.RemoveGrain(mode=17, modeU=0, modeV=0)
  sharp_clp = (sharpp == 1) ? clp2.ContraSharpening(clp,frames,strength) \
            : (sharpp == 2) ? clp2.limitedsharpenfaster(ss_x=ls_x, ss_y=ls_y, strength=lsfstr) \
            : (sharpp == 3) ? clp2.MCSharpening(clp,frames,strength,flow,thsad,lsfstr,ls_x,ls_y) : clp2

  # apply smooth and sharp clips with the masks
  #clp3 = (strength > 0) ? mt_merge(clp2, smoothed_clp, maskmotion) : clp2
  clp4 = (sharpp > 0) ? mt_merge(clp2, sharp_clp, maskstatic) : clp2
  
  # There could be some edge ringing left behind, this will help it by adding a mild blur to object edges.
  maskedge = (edgeclean) ? dering_mask(clp4, anime, strength, edm_hi, edm_lo) : nullclp
  dering   = (edgeclean) ? dering_clp(clp4, anime, strength, nullclp, chro) : clp4
  clp5     = (edgeclean) ? mt_merge(clp4,dering,maskedge) : clp4
  
  # apply focus function if requested, can help with edges that are blurry, this is from IIP script.
  clp6 = (focus) ? focus(clp5, clp5.width, clp5.height) : clp5
 
  # apply removedirtdust postprocess if requested
  clp7 = (postprocess) ? clp6.removedustdirt(16,5,15,45,false) : clp6
  
  # add grain to dark areas so encoders dont block them up on a low bitrate, also can give detail illusion
  maskdark = (addnoise) ? clp7.mt_lut("x " + th_lo + " < 255 x " + th_hi + " > 0 x " + th_lo + " - " + th_hi + " " + th_lo + " - / 255 * ? ? "): nop()
  clp8 = (addnoise && chro) ? mt_merge(clp7,clp7.sharpen(0.25).addgrain(2,0,0),maskdark,u=3,v=3) \
               : (addnoise) ? mt_merge(clp7,clp7.sharpen(0.25).addgrain(2,0,0),maskdark): clp7

  # Remove color bleeding if asked
  (colorbleed) ? clp8.removegrain(0,11) : clp8

  # debug views
  (debug > 0 && debug < 10) ? debug_view(last, clp, debug, blocksize, overlap, thsad, ml, frames, strength, \ 
                                         preprocess, postprocess, chro, dct, maskmotion, maskstatic, maskedge, \
                                         aggressive, bv2, dering, edgeclean, focus, anime, thscd1, thscd2, ls_x, ls_y, \
                                         lsfstr, starfield, addnoise, maskstar, unblock, search, premax, sharp, sharpp, flow, temporal, \
                                         edm_hi, edm_lo, thstar, lumathres, quant1, quant2, uv, truemotion, thsad, lambda, lsad, \
                                         pnew, plevel, mvglobal, th_lo, th_hi, limit, fs1, fs2, fs3, fs4, prefast, premc) : last
                                         
  # Remove the mod 16 borders we added 
  (debug > 0) ? last : last.crop(x0,y0,-x1,-y1)
 
   RETURN( last )
}

FUNCTION f14_degrain_mvt(clip input, bool chro, bool preprocess, int strength, int frames, int blocksize, int overlap, \
                     int dct, int thsad, clip nullclp, bool unblock, int thscd1, int thscd2, \
                     int limit, int search, bool anime, int pel, bool temporal, bool premax, int sharp, int lambda, \
                     int lsad, int pnew, int plevel, bool mvglobal, bool prefast, string fft, bool premc, clip maskmotion, clip maskstatic)
{
  vector_prefilter = (preprocess && !prefast) ? pre_filter(input, strength,  frames,  chro, premax, fft) : (preprocess) ? pre_filter_fast(input, chro, 16, 17, frames) : input
  vector_prefilter = (premc) ? mt_merge(mt_merge(input, vector_prefilter, maskstatic), input.removegrain(mode=17), maskmotion) : vector_prefilter
  
  # compute the motion vectors
  global idx_pointer = idx_pointer + 1
  multivecs = vector_prefilter.MVAnalyseMulti(refframes=frames,pel=pel,sharp=sharp,dct=dct,search=search,lambda=lambda,blksize=blocksize, \
                                                overlap=overlap,chroma=chro,idx=idx_pointer,pnew=pnew,lsad=lsad,plevel=plevel,global=mvglobal) 

  # Save the vectors for later use by mc sharpening
  bv1 = multivecs.MVMultiExtract(frames - 1)
  fv1 = multivecs.MVMultiExtract(frames)
  bv2 = multivecs.MVMultiExtract(frames - 2)
  fv2 = multivecs.MVMultiExtract(frames)
  global sv_b1 = bv1
  global sv_f1 = fv1
  
  # mvdegrain the resulting frame based on the motion vectors
  global idx_pointer = (preprocess || temporal) ? idx_pointer + 1 : idx_pointer
  tlimit = (temporal) ? 255 : limit
  clp12 = input.MVDegrainMulti(multivecs,refframes=frames,thSAD=thsad,IDX=idx_pointer,limit=tlimit,thscd1=thscd1,thscd2=thscd2)
          
  # mvdegrain can leave blocking for blocksize=16 in areas with ultra fast motion / large luma changes like in anime, this will help 
  # remove block artifacts by adding back mvflowed detail.  
  clp12 = (blocksize==16 && anime) ? ConditionalFilter(clp12,blockbreaker(input, bv1, bv2, fv1, fv2, clp12, frames),clp12, \
  "((averageluma() > 75) && ((YDifferenceFromPrevious()+YDifferenceToNext()) > 17))","equals","true") : clp12
  
  # are we doing this using didee's temporal limiting concepts
  clp12 = (temporal) ? Temporal_mvt(input, vector_prefilter, clp12, multivecs, thsad, idx_pointer, limit, thscd1, \
                                thscd2, frames) : clp12
   
  RETURN (clp12)
}

FUNCTION Temporal_mvt(clip input, clip vector_prefilter, clip clp12, clip multivecs, int thsad,int idx_pointer,int limit,int thscd1, int thscd2, int frames)
{
  # NR1D is the difference between the original and the mvdegrained version
  # spatD is the difference between our prefiltered clip and the original clip
  global idx_poiner = idx_pointer + 1
  NR1D   =  mt_makediff(input,clp12)
  spatD  =  mt_makediff(input,vector_prefilter) 
  DD     =  mt_lutxy(spatD,NR1D,"x 128 - abs y 128 - abs < x y ?") 
  NR1x   =  input.mt_makediff(DD,U=2,V=2) 
  clp12  =  NR1x.MVDegrainMulti(multivecs,refframes=frames,thSAD=thsad,IDX=idx_pointer,limit=limit,thscd1=thscd1,thscd2=thscd2)
          
RETURN (clp12)
}

FUNCTION f14_flow_mvt(clip input, bool chro, int frames, int blocksize, int overlap, int dct, clip nullclp, bool unblock, int thscd1, \
                   int thscd2, bool preprocess, int strength, int search, int pel, bool premax, int sharp, bool temporal, int thsad, \
                   int lambda, int lsad, int pnew, int plevel, bool mvglobal, float fs1, float fs2, float fs3, float fs4, bool prefast, \
                   string fft, bool premc, clip maskmotion, clip maskstatic)
{
  vector_prefilter = (preprocess && !prefast) ? pre_filter(input, strength,  frames,  chro, premax, fft) : (preprocess) ? pre_filter_fast(input, chro, 16, 17, frames) : input
  vector_prefilter = (premc) ? mt_merge(mt_merge(input, vector_prefilter, maskstatic), input.removegrain(mode=17), maskmotion) : vector_prefilter

  # compute 1 to 4 new frames depending on how many were requested by the user.
  global idx_pointer = idx_pointer + 1
  multivecs = vector_prefilter.MVAnalyseMulti(refframes=frames,pel=pel,sharp=sharp,dct=dct,search=search,lambda=lambda,blksize=blocksize, \
                                                overlap=overlap,chroma=chro,idx=idx_pointer,pnew=pnew,lsad=lsad,plevel=plevel,global=mvglobal) 
  
  bw4 = (frames == 4) ? vector_prefilter.mvcompensate(multivecs.MVMultiExtract(frames - 4),IDX=idx_pointer,thSCD1=thscd1,thsad=thsad,thscd2=thscd2) : nullclp
  bw3 = (frames >= 3) ? vector_prefilter.mvcompensate(multivecs.MVMultiExtract(frames - 3),IDX=idx_pointer,thSCD1=thscd1,thsad=thsad,thscd2=thscd2) : nullclp  
  bw2 = (frames >= 2) ? vector_prefilter.mvcompensate(multivecs.MVMultiExtract(frames - 2),IDX=idx_pointer,thSCD1=thscd1,thsad=thsad,thscd2=thscd2) : nullclp  
  bw1 =                 vector_prefilter.mvcompensate(multivecs.MVMultiExtract(frames - 1),IDX=idx_pointer,thSCD1=thscd1,thsad=thsad,thscd2=thscd2)  
  fw1 =                 vector_prefilter.mvcompensate(multivecs.MVMultiExtract(frames),IDX=idx_pointer,thSCD1=thscd1,thsad=thsad,thscd2=thscd2)   
  fw2 = (frames >= 2) ? vector_prefilter.mvcompensate(multivecs.MVMultiExtract(frames + 1),IDX=idx_pointer,thSCD1=thscd1,thsad=thsad,thscd2=thscd2) : nullclp  
  fw3 = (frames >= 3) ? vector_prefilter.mvcompensate(multivecs.MVMultiExtract(frames + 2),IDX=idx_pointer,thSCD1=thscd1,thsad=thsad,thscd2=thscd2) : nullclp
  fw4 = (frames == 4) ? vector_prefilter.mvcompensate(multivecs.MVMultiExtract(frames + 3),IDX=idx_pointer,thSCD1=thscd1,thsad=thsad,thscd2=thscd2) : nullclp
                          
  # save the compensations for later use by mc sharpening
  global sv_cb1 = bw1
  global sv_cf1 = fw1                                                                      
                                                                                                          
  #interleave a new long mvcompensated clip together and apply our denoising.
  clp14 =  (frames == 4) ? interleave(bw4,bw3,bw2,bw1,input,fw1,fw2,fw3,fw4) : \
           (frames == 3) ? interleave(bw3,bw2,bw1,input,fw1,fw2,fw3) : \
           (frames == 2) ? interleave(bw2,bw1,input,fw1,fw2) : interleave(bw1,input,fw1)
  
  # based on the length of our compensated clip, make the appropriate noise removal call 
  planes = (chro) ? 4 : 0
  uv     = (chro) ? true : false
  ov     = (temporal) ? 8 : 8
  bs     = select(strength,48,32,32,32,16,16,16)
  
  clp14  = (frames == 1) ? eval("clp14." + fft + "sigma=fs1,sigma2=fs2,sigma3=fs3,sigma4=fs4,bt=3,bw=bs,bh=bs,ow=ov,oh=ov,plane=planes)") : \
           (frames == 2) ? eval("clp14." + fft + "sigma=fs1,sigma2=fs2,sigma3=fs3,sigma4=fs4, bt=5, bw=bs, bh=bs, ow=ov, oh=ov, plane=planes)") : \
           (frames == 3) ? clp14.dfttest(u=uv,v=uv,sigma=fs1, sbsize=bs,sosize=ov,tbsize=7,swin=1,twin=1) : \
                            clp14.dfttest(u=uv,v=uv,sigma=fs1, sbsize=bs,sosize=ov,tbsize=9,swin=1,twin=1)
                         
  # recover our denoised frame                        
  clp14 = (frames == 1) ? selectevery(clp14,3,1) : \
          (frames == 2) ? selectevery(clp14,5,2) : \
          (frames == 3) ? selectevery(clp14,7,3) : \
                          selectevery(clp14,9,4)
                          
  # are we doing this using didee's limiting concepts?
  clp14 = (temporal) ? Temporal_flow_mvt(input, vector_prefilter, clp14, bw4, bw3, bw2, bw1, fw1, fw2, fw3, fw4, \
                                       chro, premax, frames, fs1, fs2, fs3, fs4, fft, strength) : clp14

  RETURN (clp14)
}

FUNCTION Temporal_flow_mvt(clip input, clip vector_prefilter, clip clp14, clip bw4, clip bw3, clip bw2, clip bw1, clip fw1,clip fw2, clip fw3, \
                   clip fw4, bool chro, bool premax, int frames, float fs1, float fs2, float fs3, float fs4, string fft, int strength)
{
  # NR1D is the difference between the original and the mvcompensated version
  # spatD is the difference between our prefiltered clip and the original clip
  NR1D   =  mt_makediff(input,clp14)
  spatD  =  mt_makediff(input,vector_prefilter) 
  DD     =  mt_lutxy(spatD,NR1D,"x 128 - abs y 128 - abs < x y ?") 
  NR1x   =  input.mt_makediff(DD,U=2,V=2) 
  
  #interleave a new long mvcompensated clip together and apply our denoising.
  NR1xf =  (frames == 4) ? interleave(bw4,bw3,bw2,bw1,NR1x,fw1,fw2,fw3,fw4) : \
           (frames == 3) ? interleave(bw3,bw2,bw1,NR1x,fw1,fw2,fw3) : \
           (frames == 2) ? interleave(bw2,bw1,NR1x,fw1,fw2) : interleave(bw1,NR1x,fw1)
  
  # based on the length of our compensated clip, make the appropriate noise removal call 
  planes = (chro) ? 4 : 0
  uv     = (chro) ? true : false
  bs     = select(strength,48,32,32,32,16,16,16)
  clp14  = (frames == 1) ? eval("NR1xf." + fft + "sigma=fs1,sigma2=fs2,sigma3=fs3,sigma4=fs4, bt=3, bw=bs, bh=bs, ow=8, oh=8, plane=planes)") : \
           (frames == 2) ? eval("NR1xf." + fft + "sigma=fs1,sigma2=fs2,sigma3=fs3,sigma4=fs4, bt=5, bw=bs, bh=bs, ow=8, oh=8, plane=planes)") : \
           (frames == 3) ? NR1xf.dfttest(u=uv,v=uv,sigma=fs1, sbsize=bs,sosize=8,tbsize=7,swin=1,twin=1) : \
                            NR1xf.dfttest(u=uv,v=uv,sigma=fs1, sbsize=bs,sosize=8,tbsize=9,swin=1,twin=1)
                         
  # recover our denoised frame                        
  clp14 = (frames == 1) ? selectevery(clp14,3,1) : \
          (frames == 2) ? selectevery(clp14,5,2) : \
          (frames == 3) ? selectevery(clp14,7,3) : \
                          selectevery(clp14,9,4)
                          
RETURN (clp14)
}

FUNCTION RemoveDustDirt(clip input, int repmode, int clmode, int limitY, int limitUV, bool chro)
{
  repmode   = default(repmode, 16)
  modeU     = !chro ? -1 : repmode
  clmode    = default(clmode, 5)
  limitY    = default(limitY, 10)
  limitUV   = default(limitUV, 45)
  
  clensed   = Clense(input,grey=!chro,cache=4)
  repaired  = Repair(clensed, input, mode=repmode, modeU = modeU)
  degrained = RemoveGrain(repaired, mode=clmode,modeU = !chro ? -1 : clmode)
  degrained = (chro) ? degrained : degrained.mergechroma(input)
  
  # limit the changes based on our Y and UV limits
  degrained = mt_lutxy(degrained,input, \
              expr="x y - abs " + string(limitUV + 1) + " < x x y - 128 + 128 < y " + string(limitUV) + " - y " + string(limitUV) + " + ? ?", \
              yexpr="x y - abs " + string(limity + 1) + " < x x y - 128 + 128 < y " + string(limity) + " - y " + string(limity) + " + ? ?",y=3,u=3,v=3)
  
  RETURN (degrained)
}

FUNCTION ContraSharpening(clip denoised, clip original, int frames, int strength)
{
  # contra-sharpening: sharpen the denoised clip, but don't add more to any pixel than what was removed previously.
  # script function from Didee from the VERY GRAINY thread
  s    = denoised.minblur(1,1) # Damp down remaining spots of the denoised clip.
  allD = mt_makediff(original,denoised) # The difference achieved by the denoising.
  
  # The difference of a simple kernel blur. Use a larger radius for stronger strength values 
  ssD  = (strength < 4) ? mt_makediff(s,s.removegrain(11,-1)) \
                        : mt_makediff(s,s.removegrain(11,-1).removegrain(20,-1),u=3,v=3)
                                       
  # Limit the difference to the max of what the denoising removed locally. Use a larger radius for larger strenght values
  ssDD = (strength < 4) ?  ssD.repair(allD,1) \
                        :  ssD.repair(ssD.repair(allD,1),1)  
                                                             
  ssDD = SSDD.mt_lutxy(ssD,"x 128 - abs y 128 - abs < x y ?",u=3,v=3) # abs(diff) after limiting may not be bigger than before.

  denoised.mt_adddiff(ssDD,U=3,V=3) # Apply the limited difference. (Sharpening is just inverse blurring.)

RETURN (last)
}

FUNCTION MCSharpening(clip denoised, clip original, int frames, int strength, bool flow, int thsad, int sharpen_strength, float ss_x, float ss_y)
{                                                     
  # determine our clamping limits based of our original clip and a simple MVcompensate 
  global idx_pointer = (flow) ? idx_pointer : idx_pointer + 1                                    
  comp_bw1 = (flow) ? sv_cb1 : original.MVCompensate(sv_b1,thsad=thsad,idx=idx_pointer) 
  comp_fw1 = (flow) ? sv_cf1 : original.MVCompensate(sv_f1,thsad=thsad,idx=idx_pointer)
  pmax = original.mt_logic(comp_bw1,"max",u=3,v=3).mt_logic(comp_fw1,"max",u=3,v=3)
  pmin = original.mt_logic(comp_bw1,"min",u=3,v=3).mt_logic(comp_fw1,"min",u=3,v=3)
  
  # Work on an upsized clip to improe edge detection
  ox = denoised.width
  oy = denoised.height
  xxs=round(ox*ss_x/8)*8
  yys=round(oy*ss_y/8)*8
  ss_x != 1.0 || ss_y != 1.0 ? denoised.spline36resize(xxs,yys) : denoised
  
  # non linear sharpener with variable strength, from LSF, smode=4
  Str=string(float(sharpen_strength)/80.0)
  tmp = last.RemoveGrain(11,-1)
  sharp = mt_lutxy(last,tmp,"x y == x x x y - abs 16 / 1 2 / ^ 16 * "+Str+" * x y - 2 ^ x y - 2 ^ "+Str+" 100 * 25 / + / * x y - x y - abs / * + ?")
  
  # return clip size to normal
  ss_x != 1.0 || ss_y != 1.0 ? sharp.spline36resize(ox,oy) : sharp
    
  # limit the sharpened clip to not exceed the original temporal neighborhood
  last.mt_clamp(pmax,pmin,0,0,U=3,V=3) 
  
RETURN (last)
}

FUNCTION MinBlur(clip input, int r, int "uv")
{
  # Taken from MCBob.avs:
  uv   = default(uv,3)
  
  # process chroma if uv==3, otherwise just luma
  uv2  = (uv==2) ? 1  : uv
  rg4  = (uv==3) ? 4  : -1
  rg11 = (uv==3) ? 11 : -1
  rg20 = (uv==3) ? 20 : -1
  medf = (uv==3) ? 1  : -200
  
  # make our blur clips, r controls amount ...keep the best blur pixel from each
  RG11D = (r==1) ? mt_makediff(input,input.removegrain(11, rg11),U=uv2,V=uv2)
   \    : (r==2) ? mt_makediff(input,input.removegrain(11,rg11).removegrain(20,rg20),U=uv2,V=uv2)
   \    :          mt_makediff(input,input.removegrain(11,rg11).removegrain(20,rg20).removegrain(20,rg20),U=uv2,V=uv2)
  RG4D  = (r==1) ? mt_makediff(input,input.removegrain(4,rg4),U=uv2,V=uv2)
   \    : (r==2) ? mt_makediff(input,input.medianblur(2,2*medf,2*medf),U=uv2,V=uv2)
   \    :          mt_makediff(input,input.medianblur(3,3*medf,3*medf),U=uv2,V=uv2)
  DD    = mt_lutxy(RG11D,RG4D,"x 128 - y 128 - * 0 < 128 x 128 - abs y 128 - abs < x y ? ?",U=uv2,V=uv2)
  input.mt_makediff(DD,U=uv,V=uv)
  RETURN (last)
}

FUNCTION dering_mask(clip input, bool anime, int strength, string edm_hi, string edm_lo)
{
  nmask = input.mt_edge(mode="prewitt",thy1=0,thy2=255,thC1=0,thC2=255,Y=3,V=1,U=1)
  amask = (anime) ? nop() : nmask.mt_lut("x " + edm_lo + " > 255 x ?").removegrain(11,modeU=0,modeV=0)
  tmask = (anime) ? nop() : amask.mt_expand.mt_inflate
  maskedge = (anime) ? nmask.mt_lut("x 70 < 0 x ?").mt_expand \
                     : mt_lutxy(amask.mt_invert(), tmask, expr="x y * 255 /").mt_lut("x " + edm_hi + " > 255 x " + edm_lo + " < 0 x " + edm_lo + " - " + edm_hi + " " + edm_lo + " - / 255 * ? ? ")
  
  RETURN (maskedge)
}

FUNCTION dering_clp(clip input, bool anime, int strength, clip nullclp, bool chro)
{
  dering = (anime && strength < 5) ? minblur(input,1,1) \
         : (anime && strength > 4) ? minblur(input,2,1) \
         : (strength > 3) ? input.removedustdirt(4,1,35,35,chro) \ 
         : (strength <= 3) ? input.removedustdirt(4,1,20,20,chro) : nullclp

  RETURN (dering)
}

FUNCTION Focus(clip input, int clp_width, int clp_height)
{
  # May help some edge blurred sources by defining the edges
  ssx = 3.5
  ssy = 3.5
  
  # Supersize the clip ensuring its mod16
  xx_ss2 = int(clp_width * ssx / 16 + 0.5) * 16 
  yy_ss2 = int(clp_height * ssy / 16 + 0.5) * 16 
  input  = input.spline36Resize(xx_ss2,yy_ss2)
  
  # apply our transfors to the edges (blur, warpsharp (only for luma), and xsharpen)
  input = input.minblur(2)
  input = input.awarpsharp2(depth=24, thresh=1, blur=2, chroma=2, type=1)
  input = input.xsharpen(255,255)
  
  # return the clip in its original size, this will just have enhanced edges
  RETURN input.BicubicResize(clp_width,clp_height).RemoveGrain(mode=1)
}

FUNCTION blockbreaker(clip input, clip bv1,clip bv2, clip fv1, clip fv2, clip clp12, int frames)
{
  _frames = (frames > 2) ? 2 : frames
  
  # create a blockmask
  blockmask = mvmask(input,bv1,kind=1,ml=6,gamma=3).mt_invert.mt_binarize.mt_expand.mt_inflate
  
  # create a flowed and stabilized clip
  clpnb = (_frames==2) ? interleave(input.mvflow(bv2,IDX=idx_pointer),input.mvflow(bv1,IDX=idx_pointer),input,input.mvflow(fv1,IDX=idx_pointer),input.mvflow(fv2,IDX=idx_pointer)) \
                      : interleave(input.mvflow(bv1,IDX=idx_pointer),input,input.mvflow(fv1,IDX=idx_pointer))
  clpnb = (_frames==2) ? clpnb.temporalsoften(2,1,1,32,2) : clpnb.temporalsoften(1,1,1,32,2) 
  clpnb = (_frames==2) ? selectevery(clpnb,5,2) : selectevery(clpnb,3,1) 
  
  # merge the clips together to smooth the blocks
  clp12 = mt_merge(clp12,clpnb,blockmask)
  
  RETURN (clp12)
}

FUNCTION pre_filter(clip input, int strength, int frames, bool chro, bool premax, string fft)
{
  # Preprocess the clip for use in mvanalyse if asked (based on preprocess true/false).  We like to prefilter
  # so the clip is void of noise, almost over filtered so mvanalyse can see the real motion and not noise or grain motion.
  # preprocess clip for improved motion search
  
  bt = (premax && frames > 1) ? 4 : (premax) ? 3 : (strength < 5) ? select(frames , 1 , 1 , 2  , 2  , 3) : select(frames , 1 ,1 , 2  , 3  , 4) 
  ov = (premax) ? 8 : select(strength , 2 , 4 , 4 , 4 , 8 , 8 , 8)
  vector_prefilter = (frames == 1) ? input.removegrain(17) \
  : (chro && strength <= 4) ? eval("input." + fft + "sigma=strength*4.,sigma2=strength*3.,sigma3=strength*2.,sigma4=strength*1.,bt=bt,bw=16,bh=16,ow=ov,oh=ov,plane=4)") \
  : (chro && strength > 4) ? eval("input.hqdn3d(3.0,2.0,4.0,3.5)." + fft + "sigma=16.,sigma2=12.,sigma3=8.,sigma4=4.,bt=bt,bw=16,bh=16,ow=ov,oh=ov,plane=4)") \
  : (!chro && strength <= 4) ? eval("input." + fft + "sigma=strength*4.,sigma2=strength*3.,sigma3=strength*2.,sigma4=strength*1.,bt=bt,bw=16,bh=16,ow=ov,oh=ov,plane=0)") \
  : eval("input.hqdn3d(4.0,3.0,6.0,3.5)." + fft + "sigma=16.,sigma2=12.,sigma3=8.,sigma4=4.,bt=bt,bw=16,bh=16,ow=ov,oh=ov,plane=0)")
    
  RETURN (vector_prefilter)
}

FUNCTION pre_filter_fast(clip input, bool "chro", int "repmode", int "clmode", int "frames") 
{
  repmode = default(repmode, 16)
  modeU   = !chro ? -1 : repmode
  clmode  = default(clmode, 17)
  
  save      = input
  input     = input.TemporalSoften(frames,255,255,25,2)
  clensed   = RemoveGrain(input, mode=clmode, modeU = !chro ? -1 : clmode )
  corrected = Repair(clensed, save, mode=repmode, modeU = modeU)
  corrected = (chro) ? corrected : corrected.mergechroma(input)
  
  RETURN corrected
}	

FUNCTION m4(float x) {RETURN( x < 16 ? 16 : int( round( x / 4.0 ) * 4) ) }

FUNCTION ab16(float x) 
{
  #y = float( ( round(x / 16.0) - (x / 16.0) ) * 16.0 ) # number of lines to add / remove to make mod 16
  y = frac (x / 16.0) * 16.0 # number of lines to add / remove to make mod 16
  z = ( y < 0 ) ? 16.0 - abs(Y) : y # we only want to add borders so adjust up if negative  
  z = ( z == 0 ) ? 16.0 : z # we always want to add a border to help properly process our borders
  
  RETURN int(z)
}

FUNCTION Starmask(clip input, bool anime, clip nullclp, float thstar, int lumathres, string fft)
{
  # for non anime, get the difference between a light and heavy noise removal pass
  nrdl = (!anime) ? eval("input.greyscale." + fft + "sigma=4,bt=1)") : nullclp 
  nrdh = (!anime) ? eval("input.greyscale." + fft + "sigma=12,bt=1).removegrain(17)") : nullclp 

  # the difference is just the stars that heavy removal would have killed, only consider brighter points, for anime use despot
  maskstar = (!anime) ? mt_makediff(nrdl,nrdh).mt_lut("x " + string(lumathres) + " < 0 x ?") \ 
                      : input.despot(sign=-2,pwidth=9,pheight=9,maxpts=64,minpts=2,seg=0,blur=0,dilate=0,motpn=false,p1=9,mthres=9,p2=2,show=2).mt_binarize(threshold=lumathres)

  # check the mask is validated via the luma value (ie enough of a mask to be stars and not noise spots)  
  maskstarvalidate = (!anime) ? maskstar.removegrain(4) : maskstar.mt_inflate

  # return a mask
  maskstar = ConditionalFilter(maskstarvalidate, nullclp.mt_binarize(upper=false), maskstar.mt_inflate().mt_inflate, "AverageLuma()", "<", string(thStar),false) 

RETURN maskstar
}

FUNCTION debug_view(clip end, clip start, int debug, int blocksize, int overlap, int thsad, int ml, int frames, int strength, \
                     bool preprocess, bool postprocess, bool chro,int dct, clip maskmotion, clip maskstatic, clip maskedge, \
                     bool aggressive, clip fv1, clip dering, bool edgeclean, bool focus, bool anime, int thscd1, int thscd2, \
                     float ls_x, float ls_y, int lsfstr, bool starfield, bool addnoise, clip maskstar, bool removeblocks, int search, \
                     bool premax, int sharp, int sharpp, bool flow, bool temporal, string edm_hi, string edm_lo, float thstar, int lumathres, \
                     int quant1, int quant2, int uv, bool truemotion, int thsad, int lambda, int lsad, int pnew, int plevel, bool mvglobal, \
                     string th_lo, string th_hi, int limit, float fs1, float fs2, float fs3, float fs4, bool prefast, bool premc)
{
  overlay_yellow = BlankClip( length=1, width=end.width(), height=end.height(), color=$FFFF0F, pixel_type="yv12")
  overlay_red    = BlankClip( length=1, width=end.width(), height=end.height(), color=$FF0808, pixel_type="yv12")
  overlay_black  = BlankClip( length=1, width=end.width(), height=end.height(), color=$000000, pixel_type="yv12")
  size = 11
  font = "Lucida Console"
  temp = select(sharpp," No Sharpening"," Contra Sharpen"," LimitedSharpenFaster"," MC Contra Sharpen")
  bt = (premax && frames > 1) ? 3 : (premax) ? 3 : (strength < 5) ? select(frames , 1 , 1 , 1  , 2  , 2) : select(frames , 1 ,1 , 2  , 2  , 3) 
  ov = (premax) ? 8 : select(strength , 2 , 4 , 4 , 4 , 8 , 8 , 8)
  ptemp = (chro && strength <= 3) ? string(strength*4) + " ," + string(strength*3) + " ," + string(strength*2) + " ," + string(strength*1) \
        : (chro && strength > 3) ? "16, 12, 8, 4" \
        : (!chro && strength <= 4) ? string(strength*4) + " ," + string(strength*3) + " ," + string(strength*2) + " ," + string(strength*1) \
        : "16, 12, 8, 4"
  ftemp = (frames > 2) ? "DFTtest" : "FFT3d"
  
  # 1 = show settings
  # 2 = show input/ouput what changed frame
  # 3 = side by side input and output
  # 4 = side by side, final view and grayscale difference map
  # 5 = side by side motion mask and static mask
  # 6 = side by side motion mask and motion vectors
  # 7 = side by side edge mask and inverse edge view
  # 8 = side by side motion mask and edge mask
  # 9 = 4view of motion,static,edge and star masks
  (debug == 0) ? end \
  : (debug == 1) ? end.subtitle(" Processing Settings",size=11,font=font) \
  .subtitle(" Frames      = " + String(frames),size=11,font=font,x=15,y=(size+2)*1) \
  .subtitle(" Blocksize   = " + string(blocksize),size=11,font=font,x=15,y=(size+2)*2) \ 
  .subtitle(" Overlap     = " + string(overlap),size=11,font=font,x=15,y=(size+2)*3) \
  .subtitle(" Strength    = " + string(strength),size=11,font=font,x=15,y=(size+2)*4) \ 
  .subtitle(" Preprocess  = " + string(preprocess),size=11,font=font,x=15,y=(size+2)*5) \ 
  .subtitle(" Postprocess = " + string(postprocess),size=11,font=font,x=15,y=(size+2)*6) \
  .subtitle(" Aggressive  = " + string(aggressive),size=11,font=font,x=15,y=(size+2)*7) \
  .subtitle(" Edgeclean   = " + string(edgeclean),size=11,font=font,x=15,y=(size+2)*8) \
  .subtitle(" Focus       = " + string(focus),size=11,font=font,x=15,y=(size+2)*9) \
  .subtitle(" Anime       = " + string(anime),size=11,font=font,x=15,y=(size+2)*10) \
  .subtitle(" StarField   = " + string(starfield),size=11,font=font,x=15,y=(size+2)*11) \
  .subtitle(" AddNoise    = " + string(addnoise),size=11,font=font,x=15,y=(size+2)*12) \
  .subtitle(" Removeblocks= " + string(removeblocks),size=11,font=font,x=15,y=(size+2)*13) \
  .subtitle(" Premax      = " + string(premax),size=11,font=font,x=15,y=(size+2)*14) \
  .subtitle(" Prefast     = " + string(prefast),size=11,font=font,x=15,y=(size+2)*15) \
  .subtitle(" PreMC       = " + string(premc),size=11,font=font,x=15,y=(size+2)*16) \
  .subtitle(" Flow        = " + string(flow),size=11,font=font,x=15,y=(size+2)*17) \
  .subtitle(" Temporal    = " + string(temporal),size=11,font=font,x=15,y=(size+2)*18) \
  .subtitle(" Chroma      = " + string(chro),size=11,font=font,x=15,y=(size+2)*19) \
  .subtitle("EDGECLEAN PARAMETERS",size=11,font=font,x=15,y=(size+2)*20) \
  .subtitle(" Edm_Hi      = " + string(edm_hi),size=11,font=font,x=15,y=(size+2)*21) \
  .subtitle(" Edm_Lo      = " + string(edm_lo),size=11,font=font,x=15,y=(size+2)*22) \
  .subtitle("STARFIELD PARAMETERS",size=11,font=font,x=15,y=(size+2)*23) \
  .subtitle(" Thstar      = " + string(thstar),size=11,font=font,x=15,y=(size+2)*24) \
  .subtitle(" Lumathres   = " + string(lumathres),size=11,font=font,x=15,y=(size+2)*25) \
  .subtitle("DEBLOCKING PARAMETERS",size=11,font=font,x=15,y=(size+2)*26) \
  .subtitle(" Quant1      = " + string(quant1),size=11,font=font,x=15,y=(size+2)*27) \
  .subtitle(" Quant2      = " + string(quant2),size=11,font=font,x=15,y=(size+2)*28) \
  .subtitle(" UV          = " + string(uv),size=11,font=font,x=15,y=(size+2)*29) \
  .subtitle("SHARPENING PARAMETERS",size=11,font=font,x=15,y=(size+2)*30) \
  .subtitle(temp,size=11,font=font,x=15,y=(size+2)*31) \
  .subtitle(" LSF SS_x    = " + string(ls_x),size=11,font=font,x=15,y=(size+2)*32) \
  .subtitle(" LSF SS_y    = " + string(ls_y),size=11,font=font,x=15,y=(size+2)*33) \
  .subtitle(" LSF Str     = " + string(lsfstr),size=11,font=font,x=15,y=(size+2)*34) \
  .subtitle("MVANALYSIS PARAMETERS",size=11,font=font,x=175) \
  .subtitle(" Blocksize   = " + string(blocksize),size=11,font=font,x=175,y=(size+2)*1) \ 
  .subtitle(" Overlap     = " + string(overlap),size=11,font=font,x=175,y=(size+2)*2) \
  .subtitle(" chroma      = " + string(chro),size=11,font=font,x=175,y=(size+2)*3) \ 
  .subtitle(" Dct         = " + string(dct),size=11,font=font,x=175,y=(size+2)*4) \
  .subtitle(" search      = " + string(search),size=11,font=font,x=175,y=(size+2)*5) \ 
  .subtitle(" Sharp       = " + string(sharp),size=11,font=font,x=175,y=(size+2)*6) \
  .subtitle(" TrueMotion  = " + string(truemotion),size=11,font=font,x=175,y=(size+2)*7) \
  .subtitle(" thsad       = " + string(thsad),size=11,font=font,x=175,y=(size+2)*8) \
  .subtitle(" lambda      = " + string(lambda),size=11,font=font,x=175,y=(size+2)*9) \ 
  .subtitle(" lsad        = " + string(lsad),size=11,font=font,x=175,y=(size+2)*10) \
  .subtitle(" pnew        = " + string(pnew),size=11,font=font,x=175,y=(size+2)*11) \
  .subtitle(" plevel      = " + string(plevel),size=11,font=font,x=175,y=(size+2)*12) \
  .subtitle(" Global      = " + string(mvglobal),size=11,font=font,x=175,y=(size+2)*13) \
  .subtitle("AddGrain PARAMETERS",size=11,font=font,x=175,y=(size+2)*14) \
  .subtitle(" Th_Lo       = " + string(th_lo),size=11,font=font,x=175,y=(size+2)*15) \
  .subtitle(" Th_Hi       = " + string(th_hi),size=11,font=font,x=175,y=(size+2)*16) \
  .subtitle("GENERAL MV PARAMETERS",size=11,font=font,x=175,y=(size+2)*17) \
  .subtitle(" Thsad       = " + string(thsad),size=11,font=font,x=175,y=(size+2)*18) \
  .subtitle(" Limit       = " + string(limit),size=11,font=font,x=175,y=(size+2)*19) \
  .subtitle(" ML          = " + string(ml),size=11,font=font,x=175,y=(size+2)*20) \
  .subtitle(" ThScd1      = " + string(thscd1),size=11,font=font,x=175,y=(size+2)*21) \
  .subtitle(" ThScd2      = " + string(thscd2),size=11,font=font,x=175,y=(size+2)*22) \
  .subtitle("FLOW PARAMETERS",size=11,font=font,x=175,y=(size+2)*23) \
  .subtitle(" Denoiser    = " + ftemp,size=11,font=font,x=175,y=(size+2)*24) \
  .subtitle(" Sigma1      = " + string(fs1),size=11,font=font,x=175,y=(size+2)*25) \
  .subtitle(" Sigma2      = " + string(fs2),size=11,font=font,x=175,y=(size+2)*26) \
  .subtitle(" Sigma3      = " + string(fs3),size=11,font=font,x=175,y=(size+2)*27) \
  .subtitle(" Sigma4      = " + string(fs4),size=11,font=font,x=175,y=(size+2)*28) \
  .subtitle("Prefilter PARAMETERS",size=11,font=font,x=175,y=(size+2)*29) \
  .subtitle(" bt          = " + string(bt),size=11,font=font,x=175,y=(size+2)*30) \
  .subtitle(" ov          = " + string(ov),size=11,font=font,x=175,y=(size+2)*31) \
  .subtitle(" Blocksize   = " + string(16),size=11,font=font,x=175,y=(size+2)*32) \
  .subtitle(" Sigmas      = " + string(ptemp),size=11,font=font,x=175,y=(size+2)*33) \
  : (debug == 2) ? stackhorizontal(start.subtitle("Original",size=14), subtract(start, end).levels(107,1,149,0,255).subtitle("Noise map",size=14)) \
  : (debug == 3) ? stackhorizontal(start.subtitle("Original",size=14), end.subtitle("Final w/ Frames = " + string(frames) + " Strength = " + string(strength)+" Agressive = " + string(aggressive),size=14))   \
  : (debug == 4) ? stackhorizontal(end.subtitle("Final",size=14),mt_lutxy(start,end, "x y - abs 1 <= 0 "+"x y - abs 11 <= 64 "+"x y - abs 21 <= 128 "+"x y - abs 31 <= 192 255 ? ? ? ?",Y=3,U=-128,V=-128).subtitle("White - Most change",size=14).subtitle("Grey - Some change",y=size*1,size=14).subtitle("Black - No change",y=size*2,size=14))  \
  : (debug == 5) ? stackhorizontal(Overlay(end, overlay_yellow, Mask=maskmotion,  mode="blend", opacity=0.4).subtitle("Motion mask",size=14),Overlay(end, overlay_yellow, Mask=maskstatic, mode="blend", opacity=0.4).subtitle("Static Mask",size=14)) \
  : (debug == 6) ? stackhorizontal(Overlay(end, overlay_yellow, Mask=maskmotion,  mode="blend", opacity=0.8).subtitle("Motion mask",size=14),mvshow(end,fv1,scale=1,sil=0).subtitle("Motion vectors",size=14)) \
  : (debug == 7) ? stackhorizontal(Overlay(end, overlay_yellow, Mask=maskedge,  mode="blend", opacity=0.9).subtitle("Edge Mask",size=14),overlay(dering,overlay_black,mask=mt_invert(maskedge),mode="blend",opacity=1.0).subtitle("Edges",size=14)) \
  : (debug == 8) ? stackhorizontal(Overlay(end, overlay_yellow, Mask=maskmotion,  mode="blend", opacity=0.4).subtitle("Motion mask",size=14),Overlay(end, overlay_yellow, Mask=maskedge, mode="blend", opacity=0.4).subtitle("Edge Mask",size=14)) \
  : (debug == 9) ? stackVertical( \
  stackhorizontal(Overlay(end, overlay_yellow, Mask=maskmotion,  mode="blend", opacity=0.9).subtitle("Motion mask - For Denoising",size=14), \
                    Overlay(end, overlay_yellow, Mask=maskstatic, mode="blend", opacity=0.9).subtitle("Static Mask - For Sharpening",size=14)), \
  Stackhorizontal(Overlay(end, overlay_yellow, Mask=maskedge, mode="blend", opacity=0.9).subtitle("Edge Mask - For Deringing",size=14), \
                    Overlay(end, overlay_yellow, Mask=maskstar, mode="blend", opacity=0.9).subtitle("Star Mask - For Star Retention",size=14))) \
  : end
  RETURN(last)
}
