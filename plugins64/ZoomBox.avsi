# ZoomBox() - June 12st, 2008
#  Put a "box" around a clip. Box can be used to zoom in or out. Accepts Any Colorspace. Can correct for DAR (Display Aspect Ratio).
# 
# 
# Inputs
#   clip c: Accepts Any Colorspace.
#  Optional Parameters:
#   int width: output width
#   int height: output height
#   string ResizeMethod: name of resize function. Default = BilinearResize
#   float ModAR: Set the Output Aspect Ratio. If 0 then it uses the source aspect ratio (needed for animate).
# 
#  Mode 2 - Align clip
#   int Align: -9 to +9 (0=Do not use Align). Positive values - fit with no black borders, may crop clip. Negative values - fit with black borders, may letterbox clip.
#                1:top left.     2:top center.     3:top right. 
#                4:middle left.  5:middle center.  6:middle bottom. 
#                7:bottom left.  8:bottom center.  9:bottom right.
# 
#  Mode 1 - Coordinates for ZoomBox:
#   float x1: upper left x cord
#   float y1: upper left y cord
#   float x2: lower right x cord
#   float y2: lower right y cord
#               3 or 4 out of 4 points must be defined when using Mode 1
#               when omitting a single point, it will calculate the missing value, with the Aspect Ratio in mind.
#  
#  float zoomFactor: 100 = 100%, ect... 
#                      Negative values is the zoom of the pixels, positive values is the zoom of the frame. 
#                      When converting AR, this isn't perfect.
#  float panX: shift the clip x pixels. Value in source pixels. - left, + right
#  float panY: shift the clip x pixels. Value in source pixels. - up, + down
#  int color: Color of letterbox border. Default: $000000 (Black).
# 
# 
# Notes
#  Clip should be deinterlaced for best visual quality.
#  Aspect ratio for output and box(x1,y1,x2,y2) should be the same, unless you want to distort the clip.
#  Default behavor is to center clip by adding borders (Align=-5).
#  Useful for resizing clip sources (like pictures) to match the dimension of another clip.
#  If you specify Align (Mode 2) and x1,y1,x2,y2 (Mode 1), Mode 1 will be used and the align will controll the position of the zoomFactor.
#  Mode 1 (x1,y1,x2,y2) can take values from a crop opperation. x2 and y2 must be negative though; so if x2 or y2 equals 0, replace 0 with -0.00001.

Function ZoomBox(clip c, int "width", int "height", string "ResizeMethod",
\ float "SourcePAR", float "SourceDAR", float "TargetPAR", float "TargetDAR",
\ int "Align", float "x1", float "y1", float "x2", float "y2", float "zoomFactor", float "panX", float "panY", 
\ int "color")
{
	#Set Defaults
	width = Default(width, c.width())
	height = Default(height, c.height())
	ResizeMethod = Default(ResizeMethod, "BilinearResize")
	SourceAR = float(c.width())/float(c.height())
	TargetAR = float(width)/float(height)
	Align = Default(Align, -5) #Align=-5 (center and add borders to fit).
	zoomFactor = Default(zoomFactor, 100.0)
	panX = Default(panX, 0)
	panY = Default(panY, 0)
	color = Default(color, $000000)

	modzoom = Max(Float(c.width())/Float(width),Float(c.height())/Float(height))
	zoomFactor = zoomFactor<0 ? (abs(zoomFactor)/100.0)*modzoom : (abs(zoomFactor)/100.0)
	
	#Check Inputs
	Assert(zoomFactor<>0, "ZoomBox: zoomFactor can not be zero.")
	Assert((Defined(x1) && Defined(y1) && (Defined(x2) || Defined(y2))) || !(Defined(x1) && Defined(y1) && Defined(x2) && Defined(y2)), "ZoomBox: when using Mode 1, you must define x1,y1, x2 and/or y2")
	Assert(Align<9 || Align>-9, "ZoomBox: Align [" + String(Align) + "] should be between -9 and 9.")
	
	#Do Some Magic
	Eval (CalcBox(c, 1, width, height, TargetAR, SourceAR, zoomFactor, panX, panY, Align, x1, y1, x2, y2, SourcePAR, SourceDAR, TargetPAR, TargetDAR))

	BoxAR = Float(x2-x1)/Float(y2-y1)
	#Check for any unreasonable inputs before resize opperation
	Assert(x1<x2, "ZoomBox: x1[" + String(x1) + "] point larger then x2 Point[" + String(x2) + "]")
	Assert(y1<y2, "ZoomBox: y1[" + String(y1) + "] point larger then y2 Point[" + String(y2) + "]")
	

	ZoomBoxIt(c, width, height, ResizeMethod, x1, y1, x2, y2, color)
}

Function ZoomBoxIt(clip c, int width, int height, string ResizeMethod, float x1, float y1, float x2, float y2, int color)
{
	#Pad clip so resizer interpolates from border when zooming out.
	#Conditional Borders... only add if it's going to be used. Border size is size of input frame. Prevents "streaking" when zooming out alot.
	borderLeft   = x1 < 0 ? c.width():0
	borderTop    = y1 < 0 ? c.height():0
	borderRight  = x2 > c.width() ? c.width():0
	borderBottom = y2 > c.height() ? c.height():0
	c = c.AddBorders(borderLeft,borderTop,borderRight,borderBottom,color)
	
	#Do it! Yes there are only 2 lines that directly act upon the clip.
	Eval(ResizeMethod + "(c, " + String(Round(width)) + ", " + String(Round(height)) + ", src_left=" + String(x1+borderLeft) + ", src_top=" + String(y1+borderTop) + ", src_width=" + String(x2-x1) + ", src_height=" + String(y2-y1) + ")")	
}

Function CalcBox(clip c, int mode, int width, int height, float TargetAR, float SourceAR, float zoomFactor, float panX, float panY, float Align, float "x1", float "y1", float "x2", float "y2", float "SourcePAR", float "SourceDAR", float "TargetPAR", float "TargetDAR")
{
	#PAR/DAR Calculations
	SourceDAR = Defined(SourcePAR) ?
		\ SourcePAR==0 ? SourceAR : SourcePAR*SourceAR
	\ : Defined(SourceDAR) ? 
		\ SourceDAR==0 ? SourceAR : Float(SourceDAR)
	\ : SourceAR
	TargetDAR =  Defined(TargetPAR) ?
		\ TargetPAR==0 ? TargetAR : TargetPAR*TargetAR
	\ : Defined(TargetDAR) ? 
		\ TargetDAR==0 ? TargetAR : Float(TargetDAR)
	\ : TargetAR
	
	#Calc ModAR
	ModAR = SourceDAR*TargetAR/TargetDAR
	
	
	#If Align=5 or -5 then center clip. -5: Add borders. 5: Crop. "Mode 2"
	#Display Aspect Ratio = Final Output Ratio. No Change, Show All Pixels
	#Display Aspect Ratio > Final Output Ratio. Add Height or Crop Width 
	#Display Aspect Ratio < Final Output Ratio. Add Width or Crop Height 
	EvalString = 
	\   Align<>0 && ModAR==TargetAR ?
	\ "x1=0
	   x2=c.width()
	   y1=0
	   y2=c.height()"
	
	
	\ : (Align==-5 || Align==-4 || Align==-6) && ModAR>TargetAR ?
	\ "y1=0 - ((height*ModAR-width)/2.0)*(c.height()/Float(width))
	   y2=c.height() + ((height*ModAR-width)/2.0)*(c.height()/Float(width))
	   x1=0" + "
	   x2=c.width()"
	\ : (Align==5 || Align==2 || Align==8) && ModAR>TargetAR ?
	\ "x1=0 + ((height-width/ModAR)/2.0)*(c.width()/Float(height))
	   x2=c.width() - ((height-width/ModAR)/2.0)*(c.width()/Float(height))
	   y1=0
	   y2=c.height()" 
	\ : (Align==-5 || Align==-2 || Align==-8)  && ModAR<TargetAR ?
	\ "x1=0 - ((width/ModAR-height)/2.0)*(c.width()/Float(height))
	   x2=c.width() + ((width/ModAR-height)/2.0)*(c.width()/Float(height))
	   y1=0
	   y2=c.height()"
	\ : (Align==5 || Align==4 || Align==6)  && ModAR<TargetAR  ?
	\ "y1=0 + ((width-height*ModAR)/2.0)*(c.height()/Float(width))
	   y2=c.height() - ((width-height*ModAR)/2.0)*(c.height()/Float(width))
	   x1=0
	   x2=c.width()"
	
	
	\ : (Align==-1 || Align==-2 || Align==-3) && ModAR>TargetAR ?
	\ "y1=0
	   y2=c.height() + ((height*ModAR-width)/1.0)*(c.height()/Float(width))
	   x1=0
	   x2=c.width()"
	\ : (Align==-1 || Align==-4 || Align==-7)  && ModAR<TargetAR ?
	\ "x1=0
	   x2=c.width() + ((width/ModAR-height)/1.0)*(c.width()/Float(height))
	   y1=0
	   y2=c.height()"
	\ : (Align==-9 || Align==-8 || Align==-7) && ModAR>TargetAR ?
	\ "y1=0 - ((height*ModAR-width)/1.0)*(c.height()/Float(width))
	   y2=c.height()
	   x1=0
	   x2=c.width()"
	\ : (Align==-9 || Align==-6 || Align==-3)  && ModAR<TargetAR ?
	\ "x1=0 - ((width/ModAR-height)/1.0)*(c.width()/Float(height))
	   x2=c.width()
	   y1=0
	   y2=c.height()"
	
	
	\ : (Align==2 || Align==1 || Align==3) && ModAR<TargetAR  ?
	\ "y1=0
	   y2=c.height() - ((width-height*ModAR)/1.0)*(c.height()/Float(width))
	   x1=0
	   x2=c.width()" 
	\ : (Align==8 || Align==7 || Align==9) && ModAR<TargetAR  ?
	\ "y1=0 + ((width-height*ModAR)/1.0)*(c.height()/Float(width))
	   y2=c.height()
	   x1=0
	   x2=c.width()" 
	\ : (Align==4 || Align==1 || Align==7) && ModAR>TargetAR ?
	\ "x1=0
	   x2=c.width() - ((height-width/ModAR)/1.0)*(c.width()/Float(height))
	   y1=0
	   y2=c.height()" 
	\ : (Align==6 || Align==3 || Align==9) && ModAR>TargetAR ?
	\ "x1=0 + ((height-width/ModAR)/1.0)*(c.width()/Float(height))
	   x2=c.width()
	   y1=0
	   y2=c.height()"
	
	
	\ : ""
	Defined(x1) || Defined(y1) || Defined(x2) || Defined(y2) ? nop() : Eval(EvalString)

	#For non Align Input "Mode 1"
	x1tmp = Default(x1, 0)
	y1tmp = Default(y1, 0)
	x2tmp = Default(x2, c.width())
	y2tmp = Default(y2, c.height())
	
	#Take Crop Like Input
	x2tmp = x2tmp<=x1tmp && x2tmp<0 ? c.width() + x2tmp : x2tmp
	y2tmp = y2tmp<=y1tmp && y2tmp<0 ? c.height() + y2tmp : y2tmp
	
	#Set Optional parameters "Mode 1"
	test = 0
	test = Defined(x1) ? test+1 : test+0
	test = Defined(x2) ? test+1 : test+0
	test = Defined(y1) ? test+1 : test+0
	test = Defined(y2) ? test+1 : test+0
	Assert(test>=3, "ZoomBox/KenBurnsEffect: At least 3 out of 4 x1, y1, x2, y2 points must be defined; or do not set any")
	
	y2t = !Defined(y2) && Defined(y1) && Defined(x1) && Defined(x2) ? y1tmp + ((x2tmp-x1tmp)/TargetAR)/(SourceAR/ModAR) : y2tmp
	x2t = !Defined(x2) && Defined(x1) && Defined(y1) && Defined(y2) ? x1tmp + ((y2tmp-y1tmp)*TargetAR)*(SourceAR/ModAR) : x2tmp
	y1t = !Defined(y1) && Defined(y2) && Defined(x1) && Defined(x2) ? y2tmp - ((x2tmp-x1tmp)/TargetAR)/(SourceAR/ModAR) : y1tmp
	x1t = !Defined(x1) && Defined(x2) && Defined(y1) && Defined(y2) ? x2tmp - ((y2tmp-y1tmp)*TargetAR)*(SourceAR/ModAR) : x1tmp
	
	#Calc Pan Factor
	x1 = x1t-panX
	y1 = y1t-panY
	x2 = x2t-panX
	y2 = y2t-panY
	
	#Calc Zoom Factor
	CenterX = (x2-x1)/2.0
	CenterY = (y2-y1)/2.0
	CenterY = (Align<0 && ModAR>TargetAR)? CenterY*(TargetAR/ModAR): (Align>0 && ModAR<TargetAR)? CenterY*(TargetAR/ModAR): CenterY 
	CenterX = (Align>0 && ModAR>TargetAR)? CenterX/(TargetAR/ModAR): (Align<0 && ModAR<TargetAR)? CenterX/(TargetAR/ModAR): CenterX
	
	Align = abs(Align)
	x1 = (Align==0 || Align==5 || Align==2 || Align==8) && zoomFactor<>1 ? CenterX-((CenterX-x1)/(zoomFactor)) : (Align==3 || Align==6 || Align==9) && zoomFactor<>1 ? CenterX*2.0-(CenterX*2.0-x1)/zoomFactor : x1
	y1 = (Align==0 || Align==5 || Align==4 || Align==6) && zoomFactor<>1 ? CenterY-((CenterY-y1)/(zoomFactor)) : (Align==7 || Align==8 || Align==9) && zoomFactor<>1 ? CenterY*2.0-(CenterY*2.0-y1)/zoomFactor : y1
	x2 = (Align==0 || Align==5 || Align==2 || Align==8) && zoomFactor<>1 ? CenterX+((x2-CenterX)/(zoomFactor)) : (Align==7 || Align==4 || Align==1) && zoomFactor<>1 ? 1.0/zoomFactor*CenterX+(x2-CenterX)/zoomFactor : x2
	y2 = (Align==0 || Align==5 || Align==4 || Align==6) && zoomFactor<>1 ? CenterY+((y2-CenterY)/(zoomFactor)) : (Align==3 || Align==2 || Align==1) && zoomFactor<>1 ? 1.0/zoomFactor*CenterY+(y2-CenterY)/zoomFactor : y2
	
	
	startString = "startX1=" + String(x1) + "
	startY1=" + String(y1) + "
	startX2=" + String(x2) + "
	startY2=" + String(y2) + ""
	
	endString = "endX1=" + String(x1) + "
	endY1=" + String(y1) + "
	endX2=" + String(x2) + "
	endY2=" + String(y2) + ""
	
	boxString = "x1=" + String(x1) + "
	y1=" + String(y1) + "
	x2=" + String(x2) + "
	y2=" + String(y2) + ""
	
	Return mode==1 ? boxString : mode==2 ? startString : mode==3 ? endString : ""
}


Function SplineCalc(clip c, int mode, int startFrame, float startF, int endFrame, float endF)
{
	splineString = mode==1 ?
	\ "spline(n, "
	\ + String(startFrame-1) + "," + String(startF) + ", "
	\ + String(startFrame) + "," + String(startF) + ", "
	\ + String(endFrame) + "," + String(endF) + ", "
	\ + String(endFrame+1) + "," + String(endF) + ", true)"
	
	\ : mode==2 ? "spline(n, "
	\ + String(startFrame) + "," + String(startF) + ", "
	\ + String(startFrame+(endFrame-startFrame)/3.0) + "," + String(startF) + ", "
	\ + String(endFrame-(endFrame-startFrame)/3.0) + "," + String(endF) + ", "
	\ + String(endFrame) + "," + String(endF) + ", true)"
	
	\ : mode==3 ? "spline(n, "
	\ + String(startFrame) + "," + String(startF) + ", "
	\ + String(startFrame+(endFrame-startFrame)/3.0) + "," + String(endF) + ", "
	\ + String(endFrame-(endFrame-startFrame)/3.0) + "," + String(startF) + ", "
	\ + String(endFrame) + "," + String(endF) + ", true)"
	
	\ : mode==4 ? "spline(n, "
	\ + String(startFrame) + "," + String(startF) + ", "
	\ + String((endFrame-startFrame)/2.0) + "," + String(startF) + ", "
	\ + String(endFrame) + "," + String(endF) + ", true)"
	
	\ : mode==5 ? "spline(n, "
	\ + String(startFrame) + "," + String(startF) + ", "
	\ + String((endFrame-startFrame)/2.0) + "," + String(endF) + ", "
	\ + String(endFrame) + "," + String(endF) + ", true)"
	
	\ : "spline(n, "
	\ + String(startFrame) + "," + String(startF) + ", "
	\ + String(endFrame) + "," + String(endF) + ", true)"
	Return splineString
}