Function MedSharp(Clip C, int "thresh", int "rad", int "mode", bool "lp", bool "hp", bool "nr", float "str", int "kernel")
{

	_Thr = Default(thresh, 256)
	_Rad = Default(rad, 1)
	Mode = Default(mode, 1)
	str = Default(str, 1.5)
		THR  = string(_Thr)
		RAD  = string(_Rad)
		RAD2  = string(_Rad)

	lp = Default(lp, false)
	hp = Default(hp, false)
	nr = Default(nr, false)
	kernel = Default(kernel, 1)


	Lowpass = C
	Lowpass = lp == true ? _Rad >= 2 ? Lowpass.NLLV(rad=1).NLLH(rad=1) : Lowpass : Lowpass 
	Lowpass = lp == true ? _Rad >= 4 ? Lowpass.NLLV(rad=2).NLLH(rad=2) : Lowpass : Lowpass 
	Lowpass = lp == true ? _Rad == 6 ? Lowpass.NLLV(rad=3).NLLH(rad=3) : Lowpass : Lowpass 
	Lowpass = lp == true ? _Rad >= 8 ? Lowpass.NLLV(rad=4).NLLH(rad=4) : Lowpass : Lowpass 
	Lowpass = lp == true ? _Rad == 10 ? Lowpass.NLLV(rad=4).NLLH(rad=5) : Lowpass : Lowpass 
	Lowpass = lp == true ? _Rad == 12 ? Lowpass.NLLV(rad=4).NLLH(rad=6) : Lowpass : Lowpass 
	Lowpass = lp == true ? _Rad == 14 ? Lowpass.NLLV(rad=4).NLLH(rad=7) : Lowpass : Lowpass 
	Lowpass = lp == true ? _Rad >= 16 ? Lowpass.NLLV(rad=4).NLLH(rad=8) : Lowpass : Lowpass
	Lowpass = nr == true ? Lowpass.TMed2(rad=_Rad, thresh=thresh, Kernel=Kernel) : Lowpass

	Diff = Mode==0 ? MT_Luts(C, Lowpass, mode="med", pixels = "0 "+RAD+" "+RAD+" 0 -"+RAD+" 0 0 -"+RAD ,\
	expr = "X Y - X Y - X Y - abs 1 + * X Y - abs 1 + "+THR+" 1 >= "+THR+" 0.5 ^ "+THR+" ? + / - 128 +", u=1,v=1)\
	 : MT_Luts(C, Lowpass, mode="med", pixels = "0 "+RAD+" "+RAD+" 0 -"+RAD+" 0 0 -"+RAD+" 0 0" ,\
	 expr = "X Y - X Y - X Y - abs 1 + * X Y - abs 1 + "+THR+" 1 >= "+THR+" 0.5 ^ "+THR+" ? + / - 128 +", u=1,v=1)

        Diff = Kernel > 1 ? MT_Luts(C, Lowpass, mode="med", pixels = "-"+RAD2+" -"+RAD2+"-"+RAD2+" "+RAD2+" "+RAD2+" -"+RAD2+" "+RAD2+" "+RAD2+" 0 "+RAD+" "+RAD+" 0 -"+RAD+" 0 0 -"+RAD ,\
          expr = "X Y - X Y - X Y - abs 1 + * X Y - abs 1 + "+THR+" 1 >= "+THR+" 0.5 ^ "+THR+" ? + / - 128 +", u=1,v=1) : Diff 
		
		Diff = Diff.mt_Lut("X 128 - "+string(str)+" * 128 +")
		
		Diff2 = Diff.NLLV(rad=_Rad).NLLH(rad=_Rad)
		Diff = hp == true ? Mt_Makediff(diff, diff2) : Diff
		#Diff = hp == true ? Diff.lanczosresize(c.width*2, c.height*2, 0.25, 0.25, taps=3).NLHH().NLHV().pointresize(c.width, c.height) : Diff
		#Diff = hp == true ? Diff.NLHH2().NLHV2() : Diff
	  
	  
		MT_adddiff(C, Diff, u=2, v=2)

Return(Last)
}