# MC_Spuds()  
# Motion compensated noise removal with sharpening -- version: 0.9c BETA - 23.Mar.08
#
# Use import("mc_spuds.avs")  MUST BE IN YV12 and mod 8 size
#
# Thanks to Didee for his comments, scripts and posts from which I learned much and borrowed from :) 

global idx_pointer = 24

FUNCTION MC_Spuds( clip clp, int "frames", int "strength", int "blocksize", int "overlap", int "thsad", int "dct", int "ml", \
                    bool "chro", bool "postprocess", bool "preprocess", bool "aggressive",int "debug", int "thSCD1", int "thSCD2", \                    
                    bool "edgeclean", bool "focus", bool "removeblocks", bool "starfield", bool "anime", float "ss_x", int "sharpp", \
                    float "ss_y", int "lsfstr", bool "addnoise", int "shadow_l", int "shadow_h", float "thStar", int "limit", int "pnew", \
                    int "edm_lo", int "edm_hi", bool "flow", int "search", bool "colorbleed", int "quant1", int "quant2", int "uv" , \
                    bool "temporal", int "pel", int "sharp", bool "premax", int "lumathres")
{
  # set up our parameters based on what the user input 
  starfield   = default( starfield ,    false ) # Special mode to try and keep stars in the sky, mostly for anime
  colorbleed  = default( colorbleed ,   false ) # Special mode to remove color bleeding
  flow        = default( flow ,         false ) # Special mode to use mvcompensate vs mvdegrain3 for frames=3
  lumathres   = default( lumathres,     159) # cut off luma level for spots to be considered stars
  anime       = default( anime ,        false ) # Special mode for anime ... sets dct=3 and removeblocks=true
  addnoise    = default( addnoise ,     false ) # Special mode to add some grain in dark areas, help with compression and detail illusion
  shadow_l    = default( shadow_l ,     24) # Low limit for dark grain mask
  shadow_h    = default( shadow_h ,     42) # high limit for dark grain mask
  edm_lo      = string( default(edm_lo ,55)) # edge detection lo threshold
  edm_hi      = string( default(edm_hi ,255)) # edge detection hi threshold
  focus       = default( focus ,        false ) # special mode to try and crisp up edges of blurry / soft video, code from IIP
  aggressive  = default( aggressive ,   false ) # special two pass mode
  premax      = default( premax ,       false ) # override strength based vector search denoising and turn it on high
  temporal    = default( temporal ,     false ) # special mode for temporal denoising for use with aggressive flag only.
  strength    = default( strength ,     3 ) # how aggressive to remove noise / grain, sets predefined defaults
  frames      = default( frames ,       2 ) # Number of frames to use in MC analysis
  ls_x        = default( ss_x ,         1.25 ) # LSF Smode=4 default
  ls_y        = default( ss_y ,         1.25 ) # LSF Smode=4 default
  lsfstr      = default( lsfstr ,       80 ) # Strength parameter in LSF
  quant1      = default( quant1 ,       0 ) # quant 1 for deblock_qed
  quant2      = default( quant2 ,       45 ) # quant 2 for deblock_qed
  uv          = default( uv ,           1 ) # uv for deblock_qed
  pel         = default( pel ,          2 ) # pel for MVAnalyse
  sharpp      = default( sharpp ,       1 ) # sharpening function to use 1=contra, 2=limitedsharpenfaster, 3=off
  sharp       = default( sharp ,        2 ) # sharpening to use in mvanalysis 0,1,2
  search      = default( search ,       1 ) # search mode for mvanalysis
  thStar      = (defined(thStar))       ? thStar       : (anime) ? 0.0925 : 0.0225 # Frame average luma threshold, is it just noise or a starfield we are looking at
  blocksize   = (defined(blocksize))    ? blocksize    : (defined(strength)) ? select(strength , 8    , 8    , 8    , 8    , 16     , 16    , 16)     : 16    # blocksize for motion search
  overlap     = (defined(overlap))      ? overlap      : (defined(strength)) ? select(strength , 2     , 2     , 2     , 4     ,8     , 8    , 8)     : 2     # overlap of the block for motion search
  pnew        = (defined(pnew))         ? pnew         : (defined(strength)) ? select(strength , 32    , 32    , 32    , 32    , 32    , 32   , 32)    : 32    # prevent replacing of an already good predictor by one thats just a little better 
  thsad       = (defined(thsad))        ? thsad        : (defined(strength)) ? select(strength , 100   , 300   , 400   , 425   , 450   , 450  , 500)   : 400   # threshold to motion, increase for more grain removal ie 500
  thscd1      = (defined(thscd1))       ? thscd1       : (defined(strength)) ? select(strength , 400   , 400   , 500   , 500   , 550   , 600  , 600)   : 400   # threshold to motion compared to SAD
  thscd2      = (defined(thscd2))       ? thscd2       : (defined(strength) && anime) ? select(strength , 105   , 105   , 105   , 105   , 105  , 105  , 105)  \ 
                                                       : (defined(strength)) ? select(strength , 130   , 130   , 130   , 130   , 130   , 130  , 130)   : 130   # Scene detection threshold, how much must a frame must change to be a scene change
  ml          = (defined(ml))           ? ml           : (defined(strength)) ? select(strength , 130   , 130   , 120   , 110   , 100    , 90   , 90)    : 130   # threshold for the motion mask inclusion, lower includes more
  limit       = (defined(limit))        ? limit        : (defined(strength)) ? select(strength , 48   , 96   , 102   , 128   , 156    , 225   , 255)    : 128   # threshold for the motion mask inclusion, lower includes more
  preprocess  = (defined(preprocess))   ? preprocess   : (defined(strength)) ? select(strength , false , false , true  , true  , true  , true , true)  : false # preprocess clip for improved motion search?
  postprocess = (defined(postprocess))  ? postprocess  : (defined(strength)) ? select(strength , false , false , false , false , false , false , true)  : false # postprocess clip for extra noise removal?
  edgeclean   = (defined(edgeclean))    ? edgeclean    : (defined(strength)) ? select(strength , false , false , true  , true  , true  , true , true) : true  # edge clip for extra noise removal?
  dct         = (defined(dct))          ? dct          : (anime && blocksize ==8) ? 3 : 0  # dct should be zero most things, there is a high speed penalty if you use a non zero dct with a blocksize <> 8
  unblock     = (defined(removeblocks)) ? removeblocks : false  # Special mode to try and kill blocking
  chro        = default( chro, false )  #  include chroma planes in the denoising? this takes extra time
  debug       = default( debug, 0 )     # show some debug info on the screen
  
  # input checking and variable changing if necessary, try to resolve conflicts in selected options
  frames      = (frames < 1) ? 1 : (frames > 4)     ? 4          : frames
  flow        = (frames < 4)                        ? flow       : true # if frames=4 make sure flow is on
  blocksize   = (blocksize == 16)                   ? blocksize  : (blocksize == 8) ? blocksize : (blocksize == 4) ? blocksize : 8
  overlap     = (blocksize == 4 && overlap == 2)    ? overlap    : (blocksize == 8 && overlap == 2) ? overlap : (blocksize == 8 && overlap == 4) ? overlap : (blocksize == 16 && overlap == 8) ? overlap : (blocksize == 16 && overlap == 4) ? overlap : (blocksize == 16 && overlap == 2) ? overlap : 0
  dct         = (dct < 0)                           ? 0          : (dct > 4) ? 4 : dct
  sharpp      = (sharpp < 0) ? 0 : (sharpp > 3)     ? 3          : sharpp # which sharpening function to use in the script
  sharp       = (sharp  < 0) ? 0 : (sharp > 3)      ? 3          : sharp # which sharpening to use in mvanalyse
  th_hi       = string(shadow_h)
  th_lo       = string(shadow_l)
  
  # baseline clip color space error check, mod 4 size and confilcting user inputs
  check1 = ((aggressive && !temporal) || (!aggressive && temporal) || (!aggressive && ! temporal)) ? 1 : 0
  Assert((width(clp)%4 == 0 && height(clp)%4 == 0),"Width and Height must be divisible by 4 (Mod 4) for MC_Spuds")
  Assert((isyv12(clp) == true),"Please convert color space to YV12 for MC_Spuds")
  Assert((check1 == 1),"Use Aggressive or Temporal processing, not both")
    
  # calculate the appropriate borders so its width and height are mod 16
  x_temp      = ab16(clp.width)
  x1          = round(x_temp / 2.0)
  x0          = int(x_temp - x1)
  y_temp      = ab16(clp.height)
  y1          = round(y_temp / 2.0)
  y0          = int(y_temp - y1)
  
  # add blank borders (to improve frame edge processsing and make the clip mod 16), we will remove these at the end.  
  clp = clp.addborders(x0,y0,x1,y1)
  nullclp = blankclip(clp)

  # save stars if requested and check the mask is validated via the luma value (ie enough of a mask to be stars and not noise spots)
  maskstar = (starfield) ? Starmask(clp, anime, nullclp, thstar, lumathres) : nullclp.mt_binarize(upper=false)
    
  # Remove color bleeding and make the call to deblock_qed if asked
  clp1 = (colorbleed) ? clp.removegrain(0,11) : clp
  clp1 = (unblock)    ? clp1.deblock_qed(quant1=quant1,quant2=quant2,uv=uv) : clp1
  
  # Are we going to be aggressive? If so make the first pass denoise call but lower the thresholds
  aframes    = (aggressive && frames == 4 && !flow) ? 3  : frames
  aoverlap   = (aggressive)                          ? 4  : overlap
  ablocksize = (aggressive)                          ? 16 : blocksize
  clp1       = (aggressive && flow) ? clp1.f14_flow(chro, aframes, ablocksize, aoverlap, dct, nullclp, unblock, thscd1, thscd2,\
                                                     pnew, preprocess, strength, search, pel, premax, sharp, temporal, thsad) \
             : (aggressive) ? clp1.f13_degrain(chro, preprocess, strength, aframes, ablocksize, aoverlap, dct, thsad, nullclp,  \
                                                unblock, thscd1, thscd2, limit, pnew, search, anime, pel, temporal, premax, sharp, nullclp) \
             : clp1
  
  # Make the denoise function call, this could be a 2nd or first pass
  clp2 = ( flow ) ? clp1.f14_flow(chro, frames, blocksize, overlap, dct, nullclp, unblock, thscd1, thscd2,\
                                   pnew, preprocess, strength, search, pel, premax, sharp, temporal, thsad) \
                  : clp1.f13_degrain(chro, preprocess, strength, frames, blocksize, overlap, dct, thsad, nullclp,  \
                                     unblock, thscd1, thscd2, limit, pnew, search, anime, pel, temporal, premax, sharp, nullclp) 
  
  # replace stars that might have been removed by denoising  
  clp2 = (starfield) ? mt_merge(clp2,clp,maskstar) : clp2
  
  # make a mask based on our denoised framed, we need new vectors since the key frame changed
  vector_prefilter = clp2
  global idx_pointer = idx_pointer + 1
  fv1 =  GetVectors(blocksize,overlap,false,1,chro,vector_prefilter,dct,false,pnew,search,pel,clp2,thscd1,sharp,thscd2,thsad) 
  bv1 =  GetVectors(blocksize,overlap,true,1,chro,vector_prefilter,dct,false,pnew,search,pel,clp2,thscd1,sharp,thscd2,thsad) 

  # use the vectors to create masks, we apply stage two filtering to masked areas.
  maskmotion = mt_average(clp2.mvmask(kind=1, vectors=bv1, gamma=2, ml=ml),clp2.mvmask(kind=1, vectors=fv1, gamma=2, ml=ml)).UtoY().BicubicResize(clp2.width(),clp2.height()) 
  maskstatic = mt_invert(maskmotion).mt_lut("x 48 < 0 x ?") # don't sharpen motion or dark areas
  maskstatic = (starfield) ? mt_makediff(maskstatic,maskstar.mt_expand.mt_inflate) : maskstatic
  
  # create our filtered clips to apply via the masks, don't go to heavy on smoothed since we have already degrained.
  smoothed_clp = (anime && chro) ? clp2.RemoveGrain(mode=5) \
               : (anime) ? clp2.RemoveGrain(mode=5, modeU=0, modeV=0) \
               : (chro) ? clp2.RemoveGrain(mode=17) : clp2.RemoveGrain(mode=17, modeU=0, modeV=0)
  sharp_clp = (sharpp == 2) ? clp2.limitedsharpenfaster(ss_x=ls_x, ss_y=ls_y, strength=lsfstr) \
            : (sharpp == 1) ? ContraSharpening(clp2,clp) : clp2

  # apply smooth and sharp clips with the masks
  clp3 = (strength > 0) ? mt_merge(clp2, smoothed_clp, maskmotion) : clp2
  clp4 = mt_merge(clp3, sharp_clp, maskstatic)
  
  # There could be some edge ringing left behind, this will help it by adding a mild blur to object edges.
  maskedge = (edgeclean) ? dering_mask(clp4, anime, strength, edm_hi, edm_lo) : nullclp
  dering   = (edgeclean) ? dering_clp(clp4, anime, strength, nullclp) : clp4
  clp4     = (edgeclean) ? mt_merge(clp4,dering,maskedge) : clp4
  
  # apply focus function if requested, can help with edges that are blurry, this is from IIP script.
  clp4 = (focus) ? focus(clp4, clp4.width, clp4.height) : clp4
 
  # add grain to dark areas so encoders dont block them up on a low bitrate, also can give detail illusion
  maskdark = (addnoise) ? clp4.mt_lut("x " + th_lo + " < 255 x " + th_hi + " > 0 x " + th_lo + " - " + th_hi + " " + th_lo + " - / 255 * ? ? "): nop()
  clp5 = (addnoise && chro) ? mt_merge(clp4,clp4.sharpen(0.25).addgrain(2,0,0),maskdark,u=3,v=3) \
               : (addnoise) ? mt_merge(clp4,clp4.sharpen(0.25).addgrain(2,0,0),maskdark): clp4

  # apply removedirtdust if requested
  (postprocess) ? clp5.removedustdirt(16,5,5,255) : clp5

  # debug views
  (debug > 0 && debug < 10) ? debug_view(last, clp, debug, blocksize, overlap, thsad, ml, frames, strength, \ 
                                         preprocess, postprocess, chro, dct, maskmotion, maskstatic, maskedge, \
                                         aggressive, fv1, dering, edgeclean, focus, anime, thscd1, thscd2, ls_x, ls_y, \
                                         lsfstr, starfield, addnoise, maskstar, unblock, search, premax, sharp, sharpp, flow) : last
  crop(x0,y0,-x1,-y1)
  RETURN( last )
}

FUNCTION GetVectors( int blksize, int overlap, bool isb, int delta, bool chro, clip prefiltered, int dct, \
                      bool flow, int pnew, int search, int pel, clip input, int thscd1, int sharp, int thscd2, int thsad)
{
  vec = prefiltered.mvanalyse(truemotion=true,pel=pel,sharp=sharp,dct=dct,search=search,blksize=blksize,overlap=overlap, \
                                 chroma=chro,isb=isb,delta=delta,idx=idx_pointer,pnew=pnew) 
  vec = (flow) ? prefiltered.mvcompensate(vec,IDX=idx_pointer,thSCD1=thscd1,thsad=thsad,thscd2=thscd2) : vec

  RETURN( vec )
}

FUNCTION f13_degrain(clip input, bool chro, bool preprocess, int strength, int frames, int blocksize, int overlap, \
                     int dct, int thsad, clip nullclp, bool unblock, int thscd1, int thscd2, \
                     int limit, int pnew, int search, bool anime, int pel, bool temporal, bool premax, int sharp, clip nullclp)
{
  premax = (temporal) ? true : premax 
  vector_prefilter = (preprocess) ? pre_filter(input, strength,  frames,  chro, premax) : input
  
  # compute the motion vectors
  global idx_pointer = idx_pointer + 1
  bv3 = (frames == 3) ? GetVectors(blocksize,overlap,true,3,chro,vector_prefilter,dct,false,pnew,search,pel,input,thscd1,sharp,thscd2,thsad) : nullclp
  bv2 = (frames >= 2) ? GetVectors(blocksize,overlap,true,2,chro,vector_prefilter,dct,false,pnew,search,pel,input,thscd1,sharp,thscd2,thsad) : nullclp
  bv1 =                 GetVectors(blocksize,overlap,true,1,chro,vector_prefilter,dct,false,pnew,search,pel,input,thscd1,sharp,thscd2,thsad)
  fv1 =                 GetVectors(blocksize,overlap,false,1,chro,vector_prefilter,dct,false,pnew,search,pel,input,thscd1,sharp,thscd2,thsad)
  fv2 = (frames >= 2) ? GetVectors(blocksize,overlap,false,2,chro,vector_prefilter,dct,false,pnew,search,pel,input,thscd1,sharp,thscd2,thsad) : nullclp
  fv3 = (frames == 3) ? GetVectors(blocksize,overlap,false,3,chro,vector_prefilter,dct,false,pnew,search,pel,input,thscd1,sharp,thscd2,thsad) : nullclp
  
  # mvdegrain the resulting frame based on the motion vectors
  global idx_pointer = (preprocess || temporal) ? idx_pointer + 1 : idx_pointer
  planes = (chro) ? 4 : 4
  tlimit = (temporal) ? 255 : limit
  clp12 = (frames == 1) ? input.MVDegrain1(bv1,fv1,thSAD=thsad,IDX=idx_pointer,limit=tlimit,thscd1=thscd1,thscd2=thscd2,plane=planes) : \
          (frames == 2) ? input.MVDegrain2(bv1,fv1,bv2,fv2,thSAD=thsad,IDX=idx_pointer,limit=tlimit,thscd1=thscd1,thscd2=thscd2,plane=planes) : \
          (frames == 3) ? input.MVDegrain3(bv1,fv1,bv2,fv2,bv3,fv3,thSAD=thsad,IDX=idx_pointer,limit=tlimit,thscd1=thscd1,thscd2=thscd2,plane=planes) : nullclp

  # mvdegrain can leave blocking for blocksize=16 in areas with ultra fast motion / large luma changes like in anime, this will help 
  # remove block artifacts by adding back mvflowed detail.  
  clp12 = (unblock && blocksize==16 && anime) ? ConditionalFilter(clp12,blockbreaker(input, bv1, bv2, fv1, fv2, clp12, frames),clp12, \
  "((averageluma() > 75) && ((YDifferenceFromPrevious()+YDifferenceToNext()) > 17))","equals","true") : clp12
  
  # are we doing this using didee's limiting concepts?
  clp12 = (temporal) ? Temporal(input, vector_prefilter, clp12, bv3, bv2, bv1, fv1,fv2, fv3, thsad, idx_pointer, limit, thscd1, \
                                thscd2, planes, frames) : clp12
   
  RETURN (clp12)
}

FUNCTION Temporal(clip input, clip vector_prefilter, clip clp12, clip bv3, clip bv2, clip bv1, clip fv1,clip fv2, clip fv3, \
                   int thsad,int idx_pointer,int limit,int thscd1, int thscd2, int planes, int frames)
{
  # NR1D is the difference between the original and the mvdegrained version
  # spatD is the difference between our prefiltered clip and the original clip
  global idx_poiner = idx_pointer + 1
  NR1D   =  mt_makediff(input,clp12)
  spatD  =  mt_makediff(input,vector_prefilter) 
  DD     =  mt_lutxy(spatD,NR1D,"x 128 - abs y 128 - abs < x y ?") 
  NR1x  =  input.mt_makediff(DD,U=2,V=2) 
  clp12 = (frames == 1) ? NR1x.MVDegrain1(bv1,fv1,thSAD=thsad,IDX=idx_pointer,limit=limit,thscd1=thscd1,thscd2=thscd2,plane=planes) : \
          (frames == 2) ? NR1x.MVDegrain2(bv1,fv1,bv2,fv2,thSAD=thsad,IDX=idx_pointer,limit=limit,thscd1=thscd1,thscd2=thscd2,plane=planes) : \
          (frames == 3) ? NR1x.MVDegrain3(bv1,fv1,bv2,fv2,bv3,fv3,thSAD=thsad,IDX=idx_pointer,limit=limit,thscd1=thscd1,thscd2=thscd2,plane=planes) : nop()

RETURN (clp12)
}

FUNCTION f14_flow(clip input, bool chro, int frames, int blocksize, int overlap, int dct, \
                   clip nullclp, bool unblock, int thscd1, int thscd2, int pnew, bool preprocess, \
                   int strength, int search, int pel, bool premax, int sharp, bool temporal, int thsad)
{
  premax = (temporal) ? true : premax 
  vector_prefilter = (preprocess) ? pre_filter(input, strength,  frames,  chro, premax) : input
  
  # compute 1 to  4 new frames depending on how many were requested by the user.
  global idx_pointer = idx_pointer + 1
  bw4 = (frames == 4) ? GetVectors(blocksize,overlap,true, 4,chro,vector_prefilter,dct,true,pnew,search,pel,input,thscd1,sharp,thscd2,thsad) : nullclp
  bw3 = (frames >= 3) ? GetVectors(blocksize,overlap,true, 3,chro,vector_prefilter,dct,true,pnew,search,pel,input,thscd1,sharp,thscd2,thsad) : nullclp  
  bw2 = (frames >= 2) ? GetVectors(blocksize,overlap,true, 2,chro,vector_prefilter,dct,true,pnew,search,pel,input,thscd1,sharp,thscd2,thsad) : nullclp  
  bw1 =                 GetVectors(blocksize,overlap,true, 1,chro,vector_prefilter,dct,true,pnew,search,pel,input,thscd1,sharp,thscd2,thsad)   
  fw1 =                 GetVectors(blocksize,overlap,false,1,chro,vector_prefilter,dct,true,pnew,search,pel,input,thscd1,sharp,thscd2,thsad)   
  fw2 = (frames >= 2) ? GetVectors(blocksize,overlap,false,2,chro,vector_prefilter,dct,true,pnew,search,pel,input,thscd1,sharp,thscd2,thsad) : nullclp  
  fw3 = (frames >= 3) ? GetVectors(blocksize,overlap,false,3,chro,vector_prefilter,dct,true,pnew,search,pel,input,thscd1,sharp,thscd2,thsad) : nullclp 
  fw4 = (frames == 4) ? GetVectors(blocksize,overlap,false,4,chro,vector_prefilter,dct,true,pnew,search,pel,input,thscd1,sharp,thscd2,thsad) : nullclp
                                              
  #interleave a new long mvcompensated clip together and apply our denoising.
  clp14 =  (frames == 4) ? interleave(bw4,bw3,bw2,bw1,input,fw1,fw2,fw3,fw4) : \
           (frames == 3) ? interleave(bw3,bw2,bw1,input,fw1,fw2,fw3) : \
           (frames == 2) ? interleave(bw2,bw1,input,fw1,fw2) : interleave(bw1,input,fw1)
  
  # based on the length of our compensated clip, make the appropriate noise removal call 
  planes = (chro) ? 4 : 4
  uv     = (chro) ? true : false
  ov     = (temporal) ? 8 : 8
  clp14  = (frames == 1) ? clp14.fft3dfilter(sigma=3,sigma2=4,sigma3=3,sigma4=2, bt=3, bw=16, bh=16, ow=ov, oh=ov, plane=planes) : \
           (frames == 2) ? clp14.fft3dfilter(sigma=3,sigma2=4,sigma3=3,sigma4=2, bt=5, bw=16, bh=16, ow=ov, oh=ov, plane=planes) : \
           (frames == 3) ? clp14.dfttest(u=uv,v=uv,sigma=2.9, sbsize=16,sosize=ov,tbsize=7,swin=1,twin=1) : \
                            clp14.dfttest(u=uv,v=uv,sigma=2.9, sbsize=16,sosize=ov,tbsize=9,swin=1,twin=1)
                         
  # recover our denoised frame                        
  clp14 = (frames == 1) ? selectevery(clp14,3,1) : \
          (frames == 2) ? selectevery(clp14,5,2) : \
          (frames == 3) ? selectevery(clp14,7,3) : \
                          selectevery(clp14,9,4)
                          
  # are we doing this using didee's limiting concepts?
  clp14 = (temporal) ? Temporal_flow(input, vector_prefilter, clp14, bw4, bw3, bw2, bw1, fw1, fw2, fw3, fw4, \
                                       chro, premax, frames) : clp14

  RETURN (clp14)
}

FUNCTION Temporal_flow(clip input, clip vector_prefilter, clip clp14, clip bw4, clip bw3, clip bw2, clip bw1, clip fw1,clip fw2, clip fw3, \
                   clip fw4, bool chro, bool premax, int frames)
{
  # NR1D is the difference between the original and the mvdegrained version
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
  clp14  = (frames == 1) ? NR1xf.fft3dfilter(sigma=3,sigma2=4,sigma3=3,sigma4=2, bt=3, bw=16, bh=16, ow=8, oh=8, plane=planes) : \
           (frames == 2) ? NR1xf.fft3dfilter(sigma=3,sigma2=4,sigma3=3,sigma4=2, bt=5, bw=16, bh=16, ow=8, oh=8, plane=planes) : \
           (frames == 3) ? NR1xf.dfttest(u=uv,v=uv,sigma=2.9, sbsize=16,sosize=8,tbsize=7,swin=1,twin=1) : \
                            NR1xf.dfttest(u=uv,v=uv,sigma=2.9, sbsize=16,sosize=8,tbsize=9,swin=1,twin=1)
                         
  # recover our denoised frame                        
  clp14 = (frames == 1) ? selectevery(clp14,3,1) : \
          (frames == 2) ? selectevery(clp14,5,2) : \
          (frames == 3) ? selectevery(clp14,7,3) : \
                          selectevery(clp14,9,4)
                          
RETURN (clp14)
}

FUNCTION RemoveDustDirt(clip input, int repmode, int clmode, int limitY, int limitUV)
{
  repmode   = default(repmode, 16)
  clmode    = default(clmode, 5)
  limitY    = default(limitY, 5)
  limitUV   = default(limitUV, 255)
  clensed   = Clense(input)
  repaired  = Repair(clensed, input, mode=repmode)
  degrained = RemoveGrain(repaired, mode=clmode)
  degrained = mt_lutxy(degrained,input, \
              expr="x y - abs " + string(limitUV + 1) + " < x x y - 128 + 128 < y " + string(limitUV) + " - y " + string(limitUV) + " + ? ?", \
              yexpr="x y - abs " + string(limity + 1) + " < x x y - 128 + 128 < y " + string(limity) + " - y " + string(limity) + " + ? ?",y=3,u=3,v=3)
  
  RETURN (degrained)
}

FUNCTION ContraSharpening(clip denoised, clip original)
{
  # contra-sharpening: sharpen the denoised clip, but don't add more to any pixel than what was removed previously.
  # script function from Didee from the VERY GRAINY thread
  s    = denoised.minblur(1,1)                       # Damp down remaining spots of the denoised clip.
  allD = mt_makediff(original,denoised)             # The difference achieved by the denoising.
  ssD  = mt_makediff(s,s.removegrain(11,-1))      # The difference of a simple kernel blur.
  ssDD = ssD.repair(allD,1)                          # Limit the difference to the max of what the denoising removed locally.
  ssDD = SSDD.mt_lutxy(ssD,"x 128 - abs y 128 - abs < x y ?") # abs(diff) after limiting may not be bigger than before.

  denoised.mt_adddiff(ssDD,U=2,V=2)                  # Apply the limited difference. (Sharpening is just inverse blurring.)

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
  
  RETURN (input.mt_makediff(DD,U=uv,V=uv))
}

FUNCTION dering_mask(clip input, bool anime, int strength, string edm_hi, string edm_lo)
{
  nmask = input.mt_edge(mode="min/max",thy1=0,thy2=255,thC1=0,thC2=255,Y=3,V=1,U=1)
  amask = (anime) ? nop() : nmask.mt_lut("x " + edm_lo + " > 255 x ?").removegrain(11,modeU=0,modeV=0)
  tmask = (anime) ? nop() : amask.mt_expand.mt_inflate
  maskedge = (anime) ? nmask.mt_lut("x 70 < 0 x ?").mt_expand \
                     : mt_lutxy(amask.mt_invert(), tmask, expr="x y * 255 /").mt_lut("x " + edm_hi + " > 255 x " + edm_lo + " < 0 x " + edm_lo + " - " + edm_hi + " " + edm_lo + " - / 255 * ? ? ")
  
  RETURN (maskedge)
}

FUNCTION dering_clp(clip input, bool anime, int strength, clip nullclp)
{
  dering = (anime && strength < 5) ? minblur(input,1,1) \
         : (anime && strength > 4) ? minblur(input,2,1) \
         : (strength > 2) ? input.fft3dfilter(sigma=strength*2,sigma2=strength,bt=2,bw=8,bh=8,ow=4,oh=4) \
         : (strength < 3) ? input.unfilter(-5,-5) : nullclp
         
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
  input  = input.LanczosResize(xx_ss2,yy_ss2)
  
  # apply our transfors to the edges (blur, warpsharp (only to luma), and xsharpen)
  input = input.removegrain(20)
  input = input.awarpsharp(depth=10.5, thresh=0.5, blurlevel=2, cm=0)
  input = input.xsharpen(255,255)
  
  # return the clip in its original size, this will just have enhanced edges
  RETURN input.Lanczos4Resize(clp_width,clp_height).RemoveGrain(mode=5)
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

FUNCTION pre_filter (clip input, int strength, int frames, bool chro, bool premax)
{
  # Preprocess the clip for use in mvanalyse if asked (based on preprocess true/false).  We like to prefilter
  # so the clip is void of noise, almost over filtered so mvanalyse can see the real motion and not noise or grain motion.
  # preprocess clip for improved motion search
  
  bt = (premax && frames > 1) ? 5 : (premax) ? 3 : (strength < 4) ? select(frames , 0 , 1 , 2  , 3  , 3) : select(frames , 0 ,2 , 3  , 4  , 5) 
  ov = (premax) ? 8 : select(strength , 2 , 4 , 4 , 4 , 8 , 8 , 8)
  vector_prefilter = (frames == 1) ? input.removegrain(17) \
  : (chro && strength <= 3) ? input.fft3dfilter(sigma=strength*4.,sigma2=strength*3.,sigma3=strength*2.,sigma4=strength*1.,bt=bt,bw=16,bh=16,ow=ov,oh=ov,plane=4) \
  : (chro && strength > 3) ? input.fft3dfilter(sigma=16.,sigma2=12.,sigma3=8.,sigma4=4.,bt=bt,bw=16,bh=16,ow=ov,oh=ov,plane=4).hqdn3d(4.0,3.0,6.0,4.5) \
  : (!chro && strength <= 4) ? input.fft3dfilter(sigma=strength*4.,sigma2=strength*3.,sigma3=strength*2.,sigma4=strength*1.,bt=bt,bw=16,bh=16,ow=ov,oh=ov,plane=0) \
  : input.fft3dfilter(sigma=16.,sigma2=12.,sigma3=8.,sigma4=4.,bt=bt,bw=16,bh=16,ow=ov,oh=ov,plane=0).hqdn3d(4.0,0.0,6.0,0.0)
    
  RETURN (vector_prefilter)
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

FUNCTION Starmask(clip input, bool anime, clip nullclp, float thstar, int lumathres)
{
lumathres = string(lumathres)

# for non anime, get the differance between a light and heavy noise removal pass
nrdl = (!anime) ? input.greyscale.fft3dfilter(sigma=4,bt=1) : nullclp 
nrdh = (!anime) ? input.greyscale.fft3dfilter(sigma=12,bt=1).removegrain(17) : nullclp 

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
                     bool premax, int sharp, int sharpp, bool flow)
{
  overlay_yellow = BlankClip( length=1, width=end.width(), height=end.height(), color=$FFFF0F, pixel_type="yv12")
  overlay_red    = BlankClip( length=1, width=end.width(), height=end.height(), color=$FF0808, pixel_type="yv12")
  overlay_black  = BlankClip( length=1, width=end.width(), height=end.height(), color=$000000, pixel_type="yv12")
  size = 14
  font = "Lucida Console"
  
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
  : (debug == 1) ? subtitle(end, " Frames      = " + String (frames),size=14,font=font) \
    .subtitle(" Blocksize   = " + string(blocksize),size=14,font=font,y=(size+2)*1) \ 
    .subtitle(" Overlap     = " + string(overlap),size=14,font=font,y=(size+2)*2) \
    .subtitle(" Strength    = " + string(strength),size=14,font=font,y=(size+2)*3) \ 
    .subtitle(" Thsad       = " + string(thsad),size=14,font=font,y=(size+2)*4) \
    .subtitle(" Ml          = " + string(ml),size=14,font=font,y=(size+2)*5) \
    .subtitle(" Search      = " + string(search),size=14,font=font,y=(size+2)*6) \
    .subtitle(" Preprocess  = " + string(preprocess),size=14,font=font,y=(size+2)*7) \ 
    .subtitle(" Postprocess = " + string(postprocess),size=14,font=font,y=(size+2)*8) \
    .subtitle(" Dct         = " + string(dct),size=14,font=font,y=(size+2)*9) \
    .subtitle(" Aggressive  = " + string(aggressive),size=14,font=font,y=(size+2)*10) \
    .subtitle(" Edgeclean   = " + string(edgeclean),size=14,font=font,y=(size+2)*11) \
    .subtitle(" Focus       = " + string(focus),size=14,font=font,y=(size+2)*12) \
    .subtitle(" Anime       = " + string(anime),size=14,font=font,y=(size+2)*13) \
    .subtitle(" ThScd1      = " + string(thscd1),size=14,font=font,y=(size+2)*14) \
    .subtitle(" ThScd2      = " + string(thscd2),size=14,font=font,y=(size+2)*15) \
    .subtitle(" LSF SS_x    = " + string(ls_x),size=14,font=font,y=(size+2)*16) \
    .subtitle(" LSF SS_y    = " + string(ls_y),size=14,font=font,y=(size+2)*17) \
    .subtitle(" LSF Str     = " + string(lsfstr),size=14,font=font,y=(size+2)*18) \
    .subtitle(" StarField   = " + string(starfield),size=14,font=font,y=(size+2)*19) \
    .subtitle(" AddNoise    = " + string(addnoise),size=14,font=font,y=(size+2)*20) \
    .subtitle(" Removeblocks= " + string(removeblocks),size=14,font=font,y=(size+2)*21) \
    .subtitle(" Premax      = " + string(premax),size=14,font=font,y=(size+2)*22) \
    .subtitle(" Sharp       = " + string(sharp),size=14,font=font,y=(size+2)*23) \
    .subtitle(" Sharpening  = " + string(sharpp),size=14,font=font,y=(size+2)*24) \
    .subtitle(" Flow        = " + string(flow),size=14,font=font,y=(size+2)*25) \
  : (debug == 2) ? stackhorizontal(start.subtitle("Original",size=14), subtract(start, end).levels(107,1,149,0,255).subtitle("Noise map",size=14)) \
  : (debug == 3) ? stackhorizontal(start.subtitle("Original",size=14), end.subtitle("Final w/ Frames = " + string(frames) + " Strength = " + string(strength)+" Agressive = " + string(aggressive),size=14))   \
  : (debug == 4) ? stackhorizontal(end.subtitle("Final",size=14),mt_lutxy(start,end, "x y - abs 1 <= 0 "+"x y - abs 11 <= 64 "+"x y - abs 21 <= 128 "+"x y - abs 31 <= 192 255 ? ? ? ?",Y=3,U=-128,V=-128).subtitle("White - Most change",size=14).subtitle("Grey - Some change",y=size*1,size=14).subtitle("Black - No change",y=size*2,size=14))  \
  : (debug == 5) ? stackhorizontal(Overlay(end, overlay_yellow, Mask=maskmotion,  mode="blend", opacity=0.4).subtitle("Motion mask",size=14),Overlay(end, overlay_yellow, Mask=maskstatic, mode="blend", opacity=0.4).subtitle("Static Mask",size=14)) \
  : (debug == 6) ? stackhorizontal(Overlay(end, overlay_yellow, Mask=maskmotion,  mode="blend", opacity=0.4).subtitle("Motion mask",size=14),mvshow(end,fv1,scale=1,sil=0).subtitle("Motion vectors",size=14)) \
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
