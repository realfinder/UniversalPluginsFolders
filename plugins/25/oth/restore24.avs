# # Restore24 v0.4c
# This script tries to restore 24 progressive frames 
# out of 25 interlaced frames with blended fields resulting 
# from 24p -> TeleCine -> NTSC -> FieldBlendDecimation -> PAL
#


Function Restore24(clip worki,clip outi, int "numr", int "deno" )
{
global r24numr = default(numr, 2997)
global r24deno = default(deno, 6250)

global work = blankclip(worki).loop().trim(1,50)+worki 

###### OUTPUT STREAM ######-----------------------------------------------------------------------

global out = outi.trim(0,1).loop().trim(1,50)+outi 



global out0=blankclip(out).trim(1,1)+out # .subtitle("p")
global out1=out.trim(1,0)                # .subtitle("          n")
# global out =out.subtitle("   c")
###### WORKING STREAM ######----------------------------------------------------------------------
work=work.greyscale().levels(0,1.75,255,16,235).crop(8,8,-8,-8) .BicubicResize(work.width/2,work.height/2-32,.0,.5)

###### BUILD EDGEMASK ######----------------------------------------------------------------------

tmpp= isyv12(work) ? work : work.ConvertToYV12()

edgeRGB = logic(tmpp.DEdgemask(0,255,0,255,"5 0 -5 10 0 -10 5 0 -5",setdivisor=true,divisor=6),
 \              tmpp.DEdgemask(0,255,0,255,"5 10 5 0 0 0 -5 -10 -5",setdivisor=true,divisor=6),"max")

           
#
###### PRECEEDING & PROCEEDING ######
global edge_c  = edgeRGB 
global edge_c  = edge_c.levels(0,0.5,160,0,255,false) #.levels(64,8.0,128,0,255) #.levels(0,0.25,127,0,255)
global edge_p2 = BlankClip(edge_c).trim(1,2)+edge_c
global edge_p1 = edge_p2.trim(1,0)
global edge_n1 = edge_c .trim(1,0)
global edge_n2 = edge_c .trim(2,0)
#
####### WEAKEN STATIC PARTS, BIAS TO MOTION ######
global edge_p2_dark_n = YV12layer(edge_p2, edge_p1.invert(),"mul",chroma=false)
global edge_p1_dark_p = YV12layer(edge_p1, edge_p2.invert(),"mul",chroma=false)
#
global edge_n2_dark_p = edge_p1_dark_p.trim(3,0)
global edge_n1_dark_n = edge_p2_dark_n.trim(3,0)
global edge_n1_dark_p = edge_p1_dark_p.trim(2,0)
global edge_c_dark_n  = edge_p2_dark_n.trim(2,0)
global edge_c_dark_p  = edge_p1_dark_p.trim(1,0)
global edge_p1_dark_n = edge_p2_dark_n.trim(1,0)
#
########################################################
###### End of implementation with MaskTools       ######
########################################################


###### INITIALIZING MORE VARS ######
global btest_p  = 0
global btest_p1  = 0
global btest_pc = 0
global btest_c  = 0
global btest_cn = 0
global btest_n  = 0
global btest_n1  = 0
global btest_p2_n = 0
global btest_p2   = 0
global btest_p1_p = 0
global btest_p1   = 0
global btest_p1_n = 0
global btest_c_p  = 0
global btest_c    = 0
global btest_c_n  = 0
global btest_n1_p = 0
global btest_n1_n = 0
global btest_n2_p = 0
global IsBlend_n = false
global IsBlend_c = false
global IsBlend_p1 = false
global IsBlend_p2 = false
global frametype_p3 = 0
global frametype_p2 = 0
global frametype_p1 = 0
global frametype_c = 0
global frametype_n = 0
global single_ahead = false
global in_pattern = false
global pattern_guidance = 0
global count_p=0
global count_n=0
global P2_motion_btest = 0
global P1_motion_btest = 0
global N1_motion_btest = 0
global N2_motion_btest = 0


##### DEBUGGING, CHANGES ALL TIME ######
function ShowAll ()
{
stackvertical(stackhorizontal(edge_p2_dark_n.ColorYUV(analyze=true).crop(0,0,-0,40),
 \                            edge_n2_dark_p.ColorYUV(analyze=true).crop(0,0,-0,40) 
 \                            ),
 \            stackhorizontal(edge_p1_dark_p.ColorYUV(analyze=true).crop(0,0,-0,40),
 \                            edge_n1_dark_n.ColorYUV(analyze=true).crop(0,0,-0,40) 
 \                            ),
 \            stackhorizontal(edge_p1_dark_n.ColorYUV(analyze=true).crop(0,0,-0,40),
 \                            edge_n1_dark_p.ColorYUV(analyze=true).crop(0,0,-0,40) 
 \                            ),  
 \            stackhorizontal(edge_c_dark_p.ColorYUV(analyze=true).crop(0,0,-0,40),
 \                            edge_c_dark_n.ColorYUV(analyze=true).crop(0,0,-0,40)  
 \                            ),
 \            Calculate(work).crop(0,0,-0,-16).ConvertToYV12(),
 \            out.crop(0,16,-0,-16).ConvertToYV12()
 \            )
}

function ShowMetrics( clip clip )
{ 
clip=clip.subtitle("detected is "+string(IsBlend_c),       y=16)
clip=clip.subtitle("diff prev= "+string(btest_c_p-btest_p1_n) + "   nxt ="+string(btest_c_n-btest_n1_p) , y=32) 
clip=clip.subtitle("ratio prv= "+string(btest_c_p/btest_p1_n) + "   nxt ="+string(btest_c_n/btest_n1_p) , y=48) 
clip=clip.subtitle("pattern lock is "+string(in_pattern),  y=64)
clip=clip.subtitle("pattern guideance = "+string(pattern_guidance),  y=80)
clip=clip.subtitle("single ahead is "+string(single_ahead),y=96)
clip=clip.subtitle("frametype_p3 = "+string(frametype_p3) + "   IsBlend_p3 = "+string(IsBlend_p3),y=112)
clip=clip.subtitle("frametype_p2 = "+string(frametype_p2) + "   IsBlend_p2 = "+string(IsBlend_p2),y=128)
clip=clip.subtitle("frametype_p1 = "+string(frametype_p1) + "   IsBlend_p1 = "+string(IsBlend_p1),y=144)
clip=clip.subtitle("frametype_c  = "+string(frametype_c)  + "   IsBlend_c  = "+string(IsBlend_c), y=160)
clip=clip.subtitle(             "                               IsBlend_n  = "+string(IsBlend_n), y=176)
return( clip ) 
}

###### REPLACE FUNCTIONS ######
function PutCurr( ) { 
         global count_p = count_p+1
         global count_n = count_n+1
         global frametype_c = 0
         return( out ) 
         }
         
function PutPrev( ) { 
         global count_p = 0
         global count_n = count_n+1
         global frametype_c = -1
         return( out0 ) 
         }
         
function PutNext( ) { 
         global count_p = count_p+1
         global count_n = 0
         global frametype_c = 1
         return( out1 ) 
         }
         
###### REPLACE DECISION, SAFETY CHECK TO AVOID SINGLES & TRIPLES ######
function PREV( ) { 
         # it's no good idea to put a 'prev' if the decision two frames back was 'next'. 
         (frametype_p3 == 1) ? PutNext() : PutPrev()
         return( last ) 
         }
         
function NEXT( ) { 
         # it's a bad idea to put a 'next' if two frames earlier we put a 'prev': 
         # this is very likely to leave a 'single' frame
         (frametype_p2 == -1) ? PutPrev() : PutNext()
         return( last ) 
         }

function CURR( ) { 
         PutCurr()
         return( last ) 
         }

###### REPLACE BLEND WITH MOST SIMILAR NEIGHBOR ######
function UseMostSimilar( ) 
{
# The frame which blend-test's ratio is closer to 1 should be more similar
ratio_p = abs(btest_c_p/btest_p1_n)
ratio_n = abs(btest_c_n/btest_n1_p)
(ratio_p > ratio_n) ? PREV() : NEXT()   # putPrev() : putNext()

return( last ) 
}

###### REPLACE BLEND ACC. TO PATTERN GUIDANCE ######
# currently: only detect by pattern, but guidance not used (SOFT PATTERN)
function UsePattern( ) 
{
pattern_guidance == 1 ? NEXT() : NOP   # PutNext() : NOP
pattern_guidance == 0 ? CURR() : NOP   # PutCurr() : NOP
pattern_guidance ==-1 ? PREV() : NOP   # PutPrev() : NOP

return( last ) 
}

###### CHECK IF A SINGLE FRAME IS PROBABLY AHEAD ######
function CheckSingleAhead( ) 
{ 
# if brightness of *both* edges n+1 & n+2 is greater than past two frames, that means more motion
# in them, whilst n+1 can't be a double of n+2, cause it was bright enough to outrace n-1 & n-2
# Seems good theoretically, but it seems not to work quite as expected. No tragedy, 'cause false 
# decisions should be caught by the safety check in NEXT() & PREV()
#global single_ahead = (   ( (btest_n1_p > btest_c_p)  && (btest_n2_p > btest_c_p)  )
# \                     && ( (btest_n1_p > btest_p1_p) && (btest_n2_p > btest_p1_p) ) 
# \                       )
global single_ahead = (   ( (btest_n1_n > btest_p2_n) && (btest_n2_p > btest_p2_n) )
 \                     && ( (btest_n1_n > btest_p1_p) && (btest_n2_p > btest_p1_p) ) 
 \                       )  ### Is this second variant better??? ###

in_pattern = single_ahead ? false : true 
return( last ) 
}

###### CHECK IF HISTORY-OF-BLENDS SHOWS A PATTERN ######
function CheckPattern( ) 
{ 
#--- not bad, but still to improve
global in_pattern =
 \              ( (IsBlend_c == false) && (frametype_p1 == 0) && (frametype_p2 != 0) && (frametype_p3 == 0) && (Isblend_n == false) )
# \           || ( (IsBlend_c == false) && (frametype_p2 == 0) && ( (frametype_p1 != 0) || (frametype_p3 != 0) ) && (Isblend_n == true) )
# SOFT: use pattern only to detect blends that arn't detected by metrics

# \              ( (IsBlend_c == false) && (frametype_p1 == 0) && (frametype_p2 != 0) && (frametype_p3 == 0) && (Isblend_n == false) )
# \           || ( (IsBlend_c == false) && (IsBlend_p2 == true) && (frametype_p1 == 0) && (frametype_p3 == 0) )# && (Isblend_n == true) )
# STRONG: use pattern even if blend is detected at n+1: OVERRIDE! - requires atleast one 'real' detection in the past

global pattern_guidance = in_pattern ? frametype_p2 : 99  # currently not used
return( last ) 
}

###### REPLACE DECISION ######
function Replace( ) 
{ 
# If next frame is detected as a single, replace current blend with it to double it. Else, use
# pattern guidance, if a pattern is actually locked. If not, simply use most similar neighbor.
CheckSingleAhead()
single_ahead ? NEXT() : UseMostSimilar()                                 # SOFT pattern: replace undetected blends
                      # ( in_pattern ? UsePattern() : UseMostSimilar() ) # STRONG pattern: replace acc. to pattern
return( last ) 
}

###### DO WE HAVE A BLEND TO REPLACE ? ######
function Evaluate( ) 
{ 
# If current frame is detected or predicted as a blend, replace it. Else it's clean, put it out
CheckPattern()
( IsBlend_c || in_pattern ) ? Replace() : PutCurr()
#( IsBlend_c || ( in_pattern && (pattern_guidance != 0)) ) ? Replace() : PutCurr() # Pattern guidance is not yet final

debug ? ShowMetrics() : NOP

return( last ) 
}

###### CALCULATE METRICS ######
function Calculate( clip clip ) 
{
c99=scriptclip(out, "Evaluate()")

c16=FrameEvaluate(c99, "global IsBlend_n = (btest_n1_p<btest_c_n)&&(btest_n1_n<btest_n2_p)")
c15=FrameEvaluate(c16, "global IsBlend_c = IsBlend_n")
c14=FrameEvaluate(c15, "global IsBlend_p1 = IsBlend_c")
c13=FrameEvaluate(c14, "global IsBlend_p2 = IsBlend_p1")
c12=FrameEvaluate(c13, "global IsBlend_p3 = IsBlend_p2")
c11=FrameEvaluate(c12, "global frametype_p1 = frametype_c")
c10=FrameEvaluate(c11, "global frametype_p2 = frametype_p1")
c9 =FrameEvaluate(c10, "global frametype_p3 = frametype_p2")
c8=FrameEvaluate(c9, "global btest_n1_n = AverageLuma(edge_n1_dark_n)") # 
c7=FrameEvaluate(c8, "global btest_n2_p = AverageLuma(edge_n2_dark_p)") # 
c6=FrameEvaluate(c7, "global btest_p2_n = btest_p1_n") # 
c5=FrameEvaluate(c6, "global btest_p1_p = btest_c_p") # 
c4=FrameEvaluate(c5, "global btest_p1_n = btest_c_n") # enhanced blend-test -
c3=FrameEvaluate(c4, "global btest_c_p  = btest_n1_p")  # test with darkened
c2=FrameEvaluate(c3, "global btest_c_n  = btest_n1_n")  # static edges, making
c1=FrameEvaluate(c2, "global btest_n1_p = btest_n2_p") # motion more important 
return(c1) 
}

###### DO IT ######
function DoIt ()
{
Calculate(work)
AlreadyBobbed = last
assumeframebased()
#converttorgb32().generalconvolution(1,0,"0 1 0 0 1 0 0 1 0").convertbacktoyuy2()  #stutter prevention due to vertical smearing?!?

separatefields.selectevery(4,1,2).weave
SmartDecimate(r24numr, r24deno, bob=AlreadyBobbed, weave=AlreadyBobbed, tel=0.3, t_max=0.0000050, console=false)
trim(round(50*r24numr/r24deno),0)
return(last)
}

###### DEBUG, OR NORMAL OUTPUT ? ######

global debug =  false # true # 
debug ? ShowAll() : DoIt()

return( last )
}

###	Analyse bobbers for Restore24

function r24kernelbob(clip a, int "th")
{
	th=default(th,0)
	ord = getparity(a) ? 1 : 0
	a.leakkernelbob(order=ord, sharp=false, twoway=true, threshold=th) 
	(ord == 1) ? assumetff() : assumebff()
}




