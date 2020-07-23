Function TMed2(Clip C, int "thresh", int "rad", int "mode", int "kernel")
{

	_Thr = Default(thresh, 256)
	_Rad = Default(rad, 1)
	Mode = Default(mode, 1)
		THR  = string(_Thr)
		RAD  = string(_Rad)
		RAD2  = string(_Rad)
		kernel = Default(kernel, 1)

	Diff = Mode==0 ? MT_Luts(C, C, mode="med", pixels = "0 "+RAD+" "+RAD+" 0 -"+RAD+" 0 0 -"+RAD ,\
	expr = "X Y - X Y - X Y - abs 1 + * X Y - abs 1 + "+THR+" 1 >= "+THR+" 0.5 ^ "+THR+" ? + / - 128 +", u=1,v=1)\
	 : MT_Luts(C, C, mode="med", pixels = "0 "+RAD+" "+RAD+" 0 -"+RAD+" 0 0 -"+RAD+" 0 0" ,\
	 expr = "X Y - X Y - X Y - abs 1 + * X Y - abs 1 + "+THR+" 1 >= "+THR+" 0.5 ^ "+THR+" ? + / - 128 +", u=1,v=1)
        Diff = Kernel > 1 ? MT_Luts(C, C, mode="med", pixels = "-"+RAD2+" -"+RAD2+"-"+RAD2+" "+RAD2+" "+RAD2+" -"+RAD2+" "+RAD2+" "+RAD2+" 0 "+RAD+" "+RAD+" 0 -"+RAD+" 0 0 -"+RAD ,\
          expr = "X Y - X Y - X Y - abs 1 + * X Y - abs 1 + "+THR+" 1 >= "+THR+" 0.5 ^ "+THR+" ? + / - 128 +", u=1,v=1) : Diff 

	 
	 
	 	MT_Makediff(C, Diff, u=2, v=2)

Return(Last)
}

Function NLHH2(Clip C)
{


	B1 = C.BlurH(1, 0.833)
	B2 = C.BlurH(2, 0.750)
	B3 = C.BlurH(3, 0.944)
	B4= C.BlurH(4, 0.981)

		B1_D = Mt_Makediff(c, b1, u=1, v=1)
		B2_D = Mt_MakeDiff(b2, c, u=1, v=1)
		B3_D = Mt_MakeDiff(c, b3, u=1, v=1)
		B4_D = Mt_MakeDiff(b4, c, u=1, v=1)

			B2_DT = Mt_LutXY(B1_D, B2_D, " X 128 - Y 128 - X 128 - abs Y 128 - abs * 1 + * X 128 - abs Y 128 - abs * Y 128 - abs 0.75 * X 128 - abs - 0 > \
			Y 128 - abs 0.75 * X 128 - abs - 0 ?  X 128 - abs 0 > X 128 - abs -1 X 128 - abs 0 > X 128 - 1 ? / ^ 1 ? / 1 * + 1 + / +  128 + ", u=1, v=1)
			B3_DT = Mt_LutXY(B2_DT, B3_D, " X 128 - Y 128 - X 128 - abs Y 128 - abs * 1 + * X 128 - abs Y 128 - abs * Y 128 - abs 2.25 * X 128 - abs - 0 > \
			Y 128 - abs 2.25 * X 128 - abs - 0 ?  X 128 - abs 0 > X 128 - abs -1 X 128 - abs 0 > X 128 - 1 ? / ^ 1 ? / 1 * + 1 + / +  128 + ", u=1, v=1)
			B4_DT = Mt_LutXY(B3_DT, B4_D, " X 128 - Y 128 - X 128 - abs Y 128 - abs * 1 + * X 128 - abs Y 128 - abs * Y 128 - abs 6.75 * X 128 - abs - 0 > \
			Y 128 - abs 6.75 * X 128 - abs - 0 ?  X 128 - abs 0 > X 128 - abs -1 X 128 - abs 0 > X 128 - 1 ? / ^ 1 ? / 1 * + 1 + / +  128 + ", u=1, v=1)

	Mt_AddDiff(B4_DT, C)

Return(last)
}

Function NLHV2(Clip C)
{


	B1 = C.BlurH(1, 0.833)
	B2 = C.BlurH(2, 0.750)
	B3 = C.BlurH(3, 0.944)
	B4= C.BlurH(4, 0.981)

		B1_D = Mt_Makediff(c, b1, u=1, v=1)
		B2_D = Mt_MakeDiff(b2, c, u=1, v=1)
		B3_D = Mt_MakeDiff(c, b3, u=1, v=1)
		B4_D = Mt_MakeDiff(b4, c, u=1, v=1)

			B2_DT = Mt_LutXY(B1_D, B2_D, " X 128 - Y 128 - X 128 - abs Y 128 - abs * 1 + * X 128 - abs Y 128 - abs * Y 128 - abs 0.75 * X 128 - abs - 0 > \
			Y 128 - abs 0.75 * X 128 - abs - 0 ?  X 128 - abs 0 > X 128 - abs -1 X 128 - abs 0 > X 128 - 1 ? / ^ 1 ? / 1 * + 1 + / +  128 + ", u=1, v=1)
			B3_DT = Mt_LutXY(B2_DT, B3_D, " X 128 - Y 128 - X 128 - abs Y 128 - abs * 1 + * X 128 - abs Y 128 - abs * Y 128 - abs 2.25 * X 128 - abs - 0 > \
			Y 128 - abs 2.25 * X 128 - abs - 0 ?  X 128 - abs 0 > X 128 - abs -1 X 128 - abs 0 > X 128 - 1 ? / ^ 1 ? / 1 * + 1 + / +  128 + ", u=1, v=1)
			B4_DT = Mt_LutXY(B3_DT, B4_D, " X 128 - Y 128 - X 128 - abs Y 128 - abs * 1 + * X 128 - abs Y 128 - abs * Y 128 - abs 6.75 * X 128 - abs - 0 > \
			Y 128 - abs 6.75 * X 128 - abs - 0 ?  X 128 - abs 0 > X 128 - abs -1 X 128 - abs 0 > X 128 - 1 ? / ^ 1 ? / 1 * + 1 + / +  128 + ", u=1, v=1)

	Mt_AddDiff(B4_DT, C)

Return(last)
}


Function NLLH(Clip C, int "rad")
{


	Rad = Default(Rad, 1)

	B1 = C.BlurH(1*rad, 0.439)
	B2 = C.BlurH(3*rad, 0.833)
	B3 = C.BlurH(5*rad, 0.934)
	B4= C.BlurH(7*rad, 0.983)

		B1_D = Mt_Makediff(B1, C, u=1, v=1)
		B2_D = Mt_MakeDiff(C, B2, u=1, v=1)
		B3_D = Mt_MakeDiff(B3, C, u=1, v=1)
		B4_D = Mt_MakeDiff(C, B4, u=1, v=1)

			B2_DT = Mt_LutXY(B1_D, B2_D, " X 128 - Y 128 - X 128 - abs Y 128 - abs * 1 + * X 128 - abs Y 128 - abs * Y 128 - abs 1.915 * X 128 - abs - 0 > \
			Y 128 - abs 1.915 * X 128 - abs - 0 ?  X 128 - abs 0 > X 128 - abs -1 X 128 - abs 0 > X 128 - 1 ? / ^ 1 ? / 1 * + 1 + / +  128 + ", u=1, v=1)
			B3_DT = Mt_LutXY(B2_DT, B3_D, " X 128 - Y 128 - X 128 - abs Y 128 - abs * 1 + * X 128 - abs Y 128 - abs * Y 128 - abs 2.025 * X 128 - abs - 0 > \
			Y 128 - abs 2.025 * X 128 - abs - 0 ?  X 128 - abs 0 > X 128 - abs -1 X 128 - abs 0 > X 128 - 1 ? / ^ 1 ? / 1 * + 1 + / +  128 + ", u=1, v=1)
			B4_DT = Mt_LutXY(B3_DT, B4_D, " X 128 - Y 128 - X 128 - abs Y 128 - abs * 1 + * X 128 - abs Y 128 - abs * Y 128 - abs 2.077 * X 128 - abs - 0 > \
			Y 128 - abs 2.077 * X 128 - abs - 0 ?  X 128 - abs 0 > X 128 - abs -1 X 128 - abs 0 > X 128 - 1 ? / ^ 1 ? / 1 * + 1 + / +  128 + ", u=1, v=1)

	Mt_AddDiff(B4_DT, C)

Return(last)
}

Function NLLV(Clip C, int "rad")
{


	Rad = Default(Rad, 1)

	B1 = C.BlurV(1*rad, 0.439)
	B2 = C.BlurV(3*rad, 0.833)
	B3 = C.BlurV(5*rad, 0.934)
	B4= C.BlurV(7*rad, 0.983)

		B1_D = Mt_Makediff(B1, C, u=1, v=1)
		B2_D = Mt_MakeDiff(C, B2, u=1, v=1)
		B3_D = Mt_MakeDiff(B3, C, u=1, v=1)
		B4_D = Mt_MakeDiff(C, B4, u=1, v=1)

			B2_DT = Mt_LutXY(B1_D, B2_D, " X 128 - Y 128 - X 128 - abs Y 128 - abs * 1 + * X 128 - abs Y 128 - abs * Y 128 - abs 1.915 * X 128 - abs - 0 > \
			Y 128 - abs 1.915 * X 128 - abs - 0 ?  X 128 - abs 0 > X 128 - abs -1 X 128 - abs 0 > X 128 - 1 ? / ^ 1 ? / 1 * + 1 + / +  128 + ", u=1, v=1)
			B3_DT = Mt_LutXY(B2_DT, B3_D, " X 128 - Y 128 - X 128 - abs Y 128 - abs * 1 + * X 128 - abs Y 128 - abs * Y 128 - abs 2.025 * X 128 - abs - 0 > \
			Y 128 - abs 2.025 * X 128 - abs - 0 ?  X 128 - abs 0 > X 128 - abs -1 X 128 - abs 0 > X 128 - 1 ? / ^ 1 ? / 1 * + 1 + / +  128 + ", u=1, v=1)
			B4_DT = Mt_LutXY(B3_DT, B4_D, " X 128 - Y 128 - X 128 - abs Y 128 - abs * 1 + * X 128 - abs Y 128 - abs * Y 128 - abs 2.077 * X 128 - abs - 0 > \
			Y 128 - abs 2.077 * X 128 - abs - 0 ?  X 128 - abs 0 > X 128 - abs -1 X 128 - abs 0 > X 128 - 1 ? / ^ 1 ? / 1 * + 1 + / +  128 + ", u=1, v=1)

	Mt_AddDiff(B4_DT, C)

Return(last)
}

Function blurH(clip c, int "rad", Float "CW")
{
	
	Rad = Default(rad, 1)
	CW = Default(CW, 0.5)
	
	Center = C
	Left = C.PointResize(C.width, C.height, -rad, 0, C.width, C.height)
	Right = C.PointResize(C.width, C.height, rad, 0, C.width, C.height)
	
	Average(Center, CW/2, Left, (1-CW)/2, Right, (1-CW)/2, Center, CW/2)
	
Return(last)
}

Function BlurV(clip c, int "rad", Float "CW")
{
	
	Rad = Default(rad, 1)
	CW = Default(CW, 0.5)
	
	Center = C
	Down = C.PointResize(C.width, C.height, 0, -rad, C.width, C.height)
	Up = C.PointResize(C.width, C.height, 0, rad, C.width, C.height)
	
	Average(Center, CW/2, Down, (1-CW)/2, Up, (1-CW)/2, Center, CW/2)
	
Return(last)
}