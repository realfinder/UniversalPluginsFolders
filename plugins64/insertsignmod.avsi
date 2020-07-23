function insertsignmod(clip mainclip, clip overlayclip, int startframe, int endframe, int "in", int "out", int "x1", int "y1", bool "to", int "x2", int "y2") {
        in	= default(in,  0)
        out	= default(out,  0)
        x1	= default(x1,  0)
        y1	= default(y1,  0)
	to	= default(to, false)
        x2	= default(x2,  0)
        y2	= default(y2,  0)

	# make the endframe parameter optional (defaulting to where the overlay clip ends)
	endframe = default(endframe,startframe+overlayclip.framecount-1)

	# make sure the special case startframe=1 is dealt with correctly
	# (needed because trim(0,0) returns the entire clip, which is obviously not what we want)
	# note that the first frame of the clip is ZER0, _not_ one!
	begin	= (startframe == 1) ? mainclip.trim(0,-1) : mainclip.trim(0,startframe-1)
	middle	= mainclip.trim(startframe,endframe)
	end	= mainclip.trim(endframe+1,0) # BUG: setting endframe=0 doesn't do what you think it does.

	to == true ? Eval("""
	duration = endframe-startframe
	bg	= blankclip(duration, mainclip.width, mainclip.height, fps=mainclip.framerate)
	pic	= overlayclip
	l	= layer(bg, pic)
	middleoverlay = Animate(middle, 0, overlayclip.framecount, "Overlay", l, x1, y1, l.showalpha, l, x2, y2, l.showalpha).ConvertToRGB32
	insertsignmod(mainclip,middleoverlay,startframe,endframe,in,out)
	 
""") : Eval ("""
	show = blankclip(2, middle.width, middle.height, fps=middle.framerate, pixel_type="rgb32").killaudio + middle
	middleoverlay = Overlay(middle, overlayclip, x1, y1, overlayclip.showalpha.Fadein(in).fadeout(out)).trim(1,0)
	# deal with the special case startframe=0 (in which case we don't have anything before the overlay)
	# note that trim(-1,0) does nothing (it returns the same as trim(0,0)...)
	static = (startframe == 0) ? middleoverlay ++ end : begin ++ middleoverlay ++ end
	return static
""")
}