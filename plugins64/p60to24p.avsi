Function p60to24p (clip full, int "blksize", int "pel", int "search", \
int "searchparam", int "idx", int "dct", bool "truemotion", bool "motionblur") {       


# error check variables
blksize = Default (blksize, 4)
pel = Default (pel, 2)
search = Default (search, 3)
searchparam = Default (searchparam, 1)
idx = Default (idx, 1)
idx = (idx < 1) ? 1 : idx
truemotion = Default (truemotion, true)
motionblur = Default (motionblur, true)
dct = Default (dct, 3)

# idx's allow multiple instances of function in script with any integer
idx1 = (idx * 2) - 2
idx2 = (idx * 2) - 1

# cropping for 2nd pass - depends on blksize
cropped = (blksize == 4) ? full.Crop (2, 2, -6, -6) : \
	  (blksize == 8) ? full.Crop (4, 4, -4, -4) : \
	  (blksize == 16) ? full.Crop (8, 8, -8, -8) : Last

f1 = full.MVAnalyse (blksize=blksize, pel=pel, truemotion = truemotion, \
     isb = false, idx = idx1, dct=dct)
b1 = full.MVAnalyse (blksize=blksize, pel=pel, truemotion = truemotion, \
     isb = true, idx = idx1, dct=dct)
f2 = cropped.MVAnalyse(blksize=blksize, pel=pel, truemotion = truemotion, \
     isb = false, idx = idx2, dct=dct)
b2 = cropped.MVAnalyse(blksize=blksize, pel=pel, truemotion = truemotion, \
     isb = true, idx = idx2, dct=dct)

p24 = full.MVFlowFPS2 (b1, f1, b2, f2, 24000, 1001,\
      idx = idx1, idx2 = idx2)
p120 = full.MVFlowFPS2 (b1, f1, b2, f2, 120000, 1001,\
      idx = idx1, idx2 = idx2)

# everything above this point is basically MVConv (), slightly optimized.
# now apply motion blur via Merge ()

a = p120.SelectEvery (5, 0)
b = p120.SelectEvery (5, 1)
c = p120.SelectEvery (5, 2)
d = p120.SelectEvery (5, 3)
e = p120.SelectEvery (5, 4)

ae = Merge (a, e)		# final weight on frames - 0.1
bd = Merge (b, d)		# final weight on frames - 0.2
abde = Merge (ae, bd, 2/3.0)
abcde = Merge (abde, c, 0.4)	# final weight on - 0.4

Return (motionblur == True) ? abcde : p24

}