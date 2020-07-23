///////////////////////////////////////////////////////////////////////////////
//              Debilinear for Avisynth - r6

Info:
    This filter is designed to reverse the effects of bilinear upsampling.
    Parameters and sampling pattern try to mimic Avisynth's bilinearResize
    

Syntax:

    debilinear(clip, int target_width, int target_height, [float src_left, 
      float src_top, float src_width, float src_height, Boolean lsb_inout])
    debilinearY(clip, int target_width, int target_height, [float src_left, 
      float src_top, float src_width, float src_height, Boolean lsb_inout])
    
    (debilinearY ignores chroma planes)
    

Parameters:

    target_width, target_height: 
    
        presumed `native' resolution
        
    src_left, src_top, src_width, src_height:
        
        optional crop rectangle in the input frame
        
    lsb_inout:
        
        16-bit input and output. uses dithertools' format
        
    

Limitations:
    debilinear works in RGB24/32 or YV12.
    debilinearY only works in YV12.
    requires SSE2.
    Sampling at 1:1 resolution is known to be unstable. (will be fixed)
    This filter is not made for upsampling.
    

Changelog:

    26 July 2012 - r6
        + more optimizations (~50% speedup)
        - fixed 16-bit rounding bug
        
    20 July 2012 - r5
        + some small optimizations (~35% speedup)
        - fixed UV shift glitch
        
    16 July 2012 - r4
        - fixed RGB highdepth bug
        - fixed border glitch
        
    01 July 2012 - r3
        - memory leak fixed
    
    01 July 2012 - r2
        + some SSE code (~4x speedup)
        - fixed little glitch in 16-bit mode
        + full YV12 support
        
    30 June 2012 - r1
        + changed sampling patterns (mimics bilinearResize)
        + YV12 luma support
        + 16-bit (dithertools format) support
        
    

(c) 2012 prunedtree - contact: IRC