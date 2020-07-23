Function MedSharp2(Clip C, int "thresh", int "rad", int "mode", bool "lp", bool "hp", bool "nr", float "str", int "kernel")
{

	_Thr = Default(thresh, 256)
	_Rad = Default(rad, 1)
	Mode = Default(mode, 1)
	str = Default(str, 1)
		THR  = string(_Thr)
		RAD  = string(_Rad)
		RAD2  = string(_Rad)

	lp = Default(lp, false)
	hp = Default(hp, false)
	nr = Default(nr, false)
	kernel = Default(kernel, 2)


	inputclipproperties = c
	blank = BlankClip(length=inputclipproperties.framecount, width=inputclipproperties.width,\
	 height=inputclipproperties.height, pixel_type="rgb32", fps=inputclipproperties.framerate,\
	  fps_denominator=1, audio_rate=inputclipproperties.Audiorate, stereo=true, sixteen_bit=true,\
	   color=$828282).converttoyv12()

	Lowpass1 =  C.NLLV(rad=1).NLLH(rad=1) 
		Lowpass_Return = lp == true ? _Rad >= 2 ? Lowpass1 : C : C 

	Lowpass_NR_1 = Lowpass_Return.TMed2(rad=_Rad, thresh=_Thr, Kernel=1)
	Lowpass_NR_2 = Lowpass_Return.TMed2(rad=_Rad, thresh=_Thr/4, Kernel=2)

	Diff1 = MT_Luts(C, Lowpass_NR_1, mode="med", pixels = "0 "+RAD+" "+RAD+" 0 -"+RAD+" 0 0 -"+RAD+" 0 0" ,\
	 expr = "X Y - X Y - X Y - abs 1 + * X Y - abs 1 + "+THR+" 1 >= "+THR+" 0.5 ^ "+THR+" ? + / - 128 +", u=1,v=1)
	Diff2 = MT_Luts(C, Lowpass_NR_2, mode="med", pixels = "-"+RAD2+" -"+RAD2+"-"+RAD2+" "+RAD2+" "+RAD2+" -"+RAD2+" "+RAD2+" "+RAD2+" 0 "+RAD+" "+RAD+" 0 -"+RAD+" 0 0 -"+RAD ,\
	 expr = "X Y - X Y - X Y - abs 1 + * X Y - abs 1 + "+THR+" 2 * 1 >= "+THR+" 2 * 0.5 ^ "+THR+" 2 * ? + / - 128 +", u=1,v=1)
		
	mask1 = Mt_Lut(Diff1, " X 128 - 255 * ", u=1, v=1)#.NLLV().NLLH()
	#mask2 = Mt_Lut(Diff2, " X 128 - 255 * ", u=1, v=1)#.NLLV().NLLH()
		
	s1 = mt_merge(Diff2, blank, mask1).mt_Lut("X 128 - "+string(str)+" 2 / * 128 +")
		s1b = s1.NLLV().NLLH()
			s1s = mt_makediff(s1, s1b)
	s2 = Diff1.mt_Lut("X 128 - "+string(str)+" * 128 +")
		s2b = s1.NLLV().NLLH()
			s2s = mt_makediff(s2, s2b)
		

	out = MT_adddiff(C, s1s, u=2, v=2)
	out = MT_adddiff(out, s2s, u=2, v=2)
	out

Return(Last)
}