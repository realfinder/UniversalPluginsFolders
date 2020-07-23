function nnediresize2x(clip c, bool pY, bool pU, bool pV)
{
	v = c.nnedi(field=0,dh=true,Y=pY,U=pU,V=pV).turnleft()
	v = v.nnedi(field=0,dh=true,Y=pY,U=pU,V=pV).turnright()
	return v
}

function nnediresize_YUY2(clip c)
{
	cy = c
	cu = c.utoy()
	cv = c.vtoy()
	cy = nnediresize2x(cy,true,false,false)
	cu = nnediresize2x(cu,true,false,false)
	cv = nnediresize2x(cv,true,false,false)
	return ytouv(cu,cv,cy)
}

function nnediresize_YV12(clip c)
{
	return nnediresize2x(c,true,true,true)
}