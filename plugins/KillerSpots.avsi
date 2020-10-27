# Function KillerSpots 2.0
# For primitive videos
# Function for spot removal
# Original idea by Didée (https://forum.doom9.org/showthread.php?p=1402690#post1402690)
# Adapted by GMJCZP
# Requirements: MVTools, RGTools, RemoveDirtSSE2 (part of RemoveDirt v0.9 package)

Function KillerSpots(clip o, int "limit", bool "advanced", bool "comp")
{
advanced = Default(advanced, false) # best performance, otherwise is the original KillerSpots
limit    = Default(limit, 10) # spot removal limit (for advanced=true only)
comp     = Default(comp, false) # for compare results

osup   = o.MSuper(pel=2,sharp=2)
bv1    = osup.MAnalyse(isb=true, delta=1,blksize=8,overlap=4,search=4)
fv1    = osup.MAnalyse(isb=false,delta=1,blksize=8,overlap=4,search=4)
bc1    = o.MCompensate(osup,bv1)
fc1    = o.MCompensate(osup,fv1)

Interleave(fc1,o,bc1)

advanced ? RemoveDirtMod(limit) : Clense()

SelectEvery(3,1)

comp ? StackHorizontal(o,last) : last
}

# From function RemoveDirt, original adaptation thanks to johnmeyer
Function RemoveDirtMod(clip input, int "limit")
{
 clensed = input.Clense()
 alt=input.RemoveGrain(1)
 return RestoreMotionBlocks(clensed,input,alternative=alt,pthreshold=4,cthreshold=6, gmthreshold=40,
 \ dist=3,dmode=2,debug=false,noise=limit,noisy=12)
}