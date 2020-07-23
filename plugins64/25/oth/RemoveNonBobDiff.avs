function RemoveNonBobDiff( clip Input, clip Ref, int rep )
{
	# ed is the erosion distance - how much to deflate then reflate to remove thin areas of interest: 0 = minimum to 5 = maximum
	# od is over-dilation level  - extra inflation to ensure areas to restore back are fully caught:  0 = none to 3 = one full pixel
	# If rep < 10, then ed = rep and od = 0, otherwise ed = 10s digit and od = 1s digit (nasty method, but kept for compatibility with original TGMC)
	rep = default( rep, 1 )
	ed = (rep < 10) ? rep : rep/10  
	od = (rep < 10) ? 0   : rep%10  

	diff = mt_makediff( Ref, Input, U=3,V=3 )

	# Areas of positive difference                                                          # ed = 0 1 2 3 4 5
	choke1 =                        diff.  mt_inpand( mode="vertical", U=3,V=3 )            #      x x x x x x    1 pixel   \
	choke1 = (ed > 2)             ? choke1.mt_inpand( mode="vertical", U=3,V=3 ) : choke1   #      . . . x x x    1 pixel    | Deflate to remove thin areas
	choke1 = (ed != 0 && ed != 3) ? choke1.TGMC_deflate( U=3,V=3 )               : choke1   #      . x x . x x    a bit more |
	choke1 = (ed == 2 || ed == 5) ? choke1.RemoveGrain(4)                        : choke1   #      . . x . . x    & more(?) / [median - may actually inflate??]
	
	choke1 =                        choke1.mt_expand( mode="vertical", U=3,V=3 )            #      x x x x x x    1 pixel  \
	choke1 = (ed > 1)             ? choke1.mt_expand( mode="vertical", U=3,V=3 ) : choke1   #      . . x x x x    1 pixel   | Reflate again
	choke1 = (ed > 4)             ? choke1.mt_expand( mode="vertical", U=3,V=3 ) : choke1   #      . . . . . x    1 pixel  /
	
	# Over-dilation - extra reflation up to 1 pixel
	choke1 = (od == 0)            ? choke1 : \
	         (od == 1)            ? choke1.TGMC_inflate( U=3,V=3 ) : \                      
	         (od == 2)            ? choke1.TGMC_inflate( U=3,V=3 ).TGMC_inflate( U=3,V=3 ) : \
	                                choke1.mt_expand( U=3,V=3 )
	
	# Areas of negative difference (similar to above)
	choke2 =                        diff.  mt_expand( mode="vertical", U=3,V=3 )
	choke2 = (ed > 2)             ? choke2.mt_expand( mode="vertical", U=3,V=3 ) : choke2
	choke2 = (ed != 0 && ed != 3) ? choke2.TGMC_inflate( U=3,V=3 )               : choke2
	choke2 = (ed == 2 || ed == 5) ? choke2.RemoveGrain(4)                        : choke2
	choke2 =                        choke2.mt_inpand( mode="vertical", U=3,V=3 )
	choke2 = (ed > 1)             ? choke2.mt_inpand( mode="vertical", U=3,V=3 ) : choke2
	choke2 = (ed > 4)             ? choke2.mt_inpand( mode="vertical", U=3,V=3 ) : choke2
	choke2 = (od == 0)            ? choke2 : \
	         (od == 1)            ? choke2.TGMC_deflate( U=3,V=3 ) : \  
	         (od == 2)            ? choke2.TGMC_deflate( U=3,V=3 ).TGMC_deflate( U=3,V=3 ) : \  
	                                choke2.mt_inpand( U=3,V=3 )
	
	# Combine above areas to find those areas of difference to restore
	restore = diff.mt_lutxy( choke1, "x 129 < x y 128 < 128 y ? ?", U=3,V=3 ).mt_lutxy( choke2, "x 127 > x y 128 > 128 y ? ?", U=3,V=3 )
	
	return Input.mt_adddiff( restore, U=3,V=3 )
}

function TGMC_inflate( clip c, int "Y", int "U", int "V" )
{
	mtY =default( Y, 3 )
	mtU =default( U, 1 )
	mtV =default( V, 1 )
	rgY = (mtY == 3) ? 20 : -1
	rgU = (mtU == 3) ? 20 : -1
	rgV = (mtV == 3) ? 20 : -1 
	mt_logic( c, c.RemoveGrain( rgY, rgU, rgV ), "max", Y=mtY,U=mtU,V=mtV )
}

function TGMC_deflate( clip c, int "Y", int "U", int "V" )
{
	mtY =default( Y, 3 )
	mtU =default( U, 1 )
	mtV =default( V, 1 )
	rgY = (mtY == 3) ? 20 : -1
	rgU = (mtU == 3) ? 20 : -1
	rgV = (mtV == 3) ? 20 : -1 
	mt_logic( c, c.RemoveGrain( rgY, rgU, rgV ), "min", Y=mtY,U=mtU,V=mtV )
}
