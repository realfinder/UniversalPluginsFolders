#SmoothDeblock+required functions http://forum.doom9.org/showthread.php?t=111526&page=1



# rb-array.avsi -- functions for simulating arrays & loops in Avisynth 2.xx
#
# Last modified: 2006-02-05
#
# Written by Richard Berg and assigned to the public domain.
#


# Dim
#
# 	Create a collection of global variables that can be manipulated similar to an array.  You can re-Dim
#   an existing array, but the contents will be cleared.  The type of the "initValue" parameter determines the type
#	of the array.  All Avisynth types are supported.
#
# PARAMETERS:
#			"arr" 		:	Name of the array variable.  Pass this variable name to Deref and Set.
#			"size"		:	Size of the array; 0-based, like C/C++.  Dim("foo", 10) creates foo0-foo9.
#			"initValue"	:	Each element is initialized to this value.  Its type determines the array type.  It uses For
#							internally, so initValue can be parametrized by 'i'.
#
# USAGE: see example.avs
#
function Dim(string arr, int size, val initValue)
{
	# create "base" string variable whose value is its name.  every Eval in internal array functions 
	# needs this to build the element's name
	Eval("global " + arr + "=" + chr(34) + arr + chr(34))
	
	# store size so that Length() is O(1)
	Eval("global " + arr + "Length = " + string(size))
	
	# create each element
	global DimThunkVal = initValue   # thunk requires this in case it's a clip
	for(0, "<="+string(size), "+1", arr + ".set(i, " + thunk(initValue, "DimThunkVal") + ")")
}


# DeRef
#
#	Gives you programmatic access to the "arrays" created by Dim
#
# USAGE: foo.deref(2+2)
#				...is semantically equivalent* to foo[2+2] in C/C++
#				...is syntactically equivalent to foo4 in Avisynth
#
# 				*exception: the output of deref is NOT an lvalue.  If you need to assign something to 
#							an array element, use Set.
#
function DeRef(string arr, int index)
{
	Eval(arr + string(index))
}


# Set
#
#	Allows you to programmatically assign values to the "arrays" created by Dim
#
# USAGE: foo.set(i, i*2)
#				...is semantically equivalent to foo[i] = i*2; in C/C++
#				...is syntactically equivalent to fooI = i*2 in Avisynth
#
function Set(string arr, int index, val val)
{
	Eval("global " + arr + string(index) + "=" + thunk(val))
}


# Thunk
#
#	Makes a generic (untyped) parameter suitable for building Eval strings.  
#
# PARAMETERS:
#		"clipName"	:	In order to assign clips to arrays with Eval, the rvalue has to be another Eval
#						on a clip variable.  By default, this variable is the parameter "val," as used
#						in functions like Set.  However, if you are building an Eval string for use with
#						For, you'll need to set a global variable that can be accessed inside the loop.  So
#						as to not pollute the global namespace, you can create a unique variable name; pass
#						it as 'clipName' to make Thunk work correctly.
#						
#
function Thunk(val val, string "clipName")
{
	clipName = Default(clipName, "val")

	# string -> escape it
	# clip -> double-thunk it
	# everything else -> stringify it
	return val.IsString()
		\ ? chr(34) + val + chr(34)		
		\ : val.IsClip()
			\ ? "Eval(" + chr(34) + clipName + chr(34) + ")"
			\ : string(val)
}


# Length
#
#	Returns the length of an "array" created by Dim
#
function Length(string arr)
{	
	try {
		return Eval(arr + "Length")
	}
	catch (err_msg)	{
		Throw("Length: the array " + arr + " was not created by Dim or is corrupt")
	}	
}


# Length2
#
#	Returns the length of an "array" that was not created by Dim, or has had elements manipulated directly.  O(n) search.
#	
# PARAMETERS:
#		"startIndex"	:	Start searching at this index.  Default = 0.  Note: elements lower than startIndex are
#							not counted in the length calculation.
#
function Length2(string arr, int "startIndex")
{
	startIndex = Default(startIndex, 0)
	
	# store size in Dim-style global so we don't have to do this again
	Eval("global " + arr + "Length = " + string(Length2Loop(arr, startIndex)))
	return arr.length
}

function Length2Loop(string arr, int index)
{
	try {
		# note: using deref won't work - after the callstack unwinds, index will be lost
		Eval(arr + string(index))
		return Length2Loop(arr, index + 1)
	}
	catch (err_msg) {
		return index
	}
}


# Fill
#
#	Fill an array with values entered as a comma-delimited string literal. 
#	(thanks to James "stickboy" Lin for the idea)
#	
#
# USAGE: array.Fill("3, -50, 124")
#	
# PARAMETERS:
#		"index" 	:	Start writing values at this index.  Default is 0.
#		"string"	:	If true, fills the array with strings instead of parsing into values.  Default is false.
#
function Fill(string arr, string values, int "index", bool "string")
{
	index = Default(index, 0)
	string = Default(string, false)
	
	offset = FindStr(values, ",")
	# FindStr returns 0 if not found
	return (offset == 0)
		\ ? NOP
		\ : Eval("""
				element = LeftStr(values, offset - 1)
				element = string ? element : Value(element)
				arr.Set(index, element)
				arr.Fill(MidStr(values, offset + 1), index + 1)
			""")			
}


# For
#
# 	A simple for-loop construct for Avisynth 2.xx
#
# USAGE: for(1, "<=3", "+1", "global x = x*2" )
#				...is semantically equivalent to for(int i=1, i<=3, i=i+1) { x = x*2 } in C/C++
#
# Notes:
#	- 	with For, the loop variable is always 'i', and the first parameter (its initial value) is always an int.  If you 
#		want to use a custom loop variable (so you can nest loops, for instance, or have a floating-point counter) then use For2.
#	-	any script variables you want manipulate inside the loop must be globals
#	-	corollary: you cannot use the implicit 'last' variable.  if you want to apply a filter inside the loop,
#		you must use assignment syntax.  Example: for(0, "<=2", "+1", "global clip = clip.FFT3DFilter(sigma=2.5, plane=i)" )
#
function For(int i, string cond, string iter, string block)
{
	return Eval("i" + cond)
		\ ? Eval("""
				Eval(block)
				For(Eval("i" + iter), cond, iter, block)
			""")
		\ : NOP
}


# For2
#
# 	A more generalized for-loop construct for Avisynth 2.xx
#
# USAGE: for("j=1", "j<=3", "j=j+1", "global x = x*2")
#				...is semantically equivalent to for(int j=1, j<=3, j=j+1) { x = x*2 } in C/C++
#
# Notes: 
#	-	For's guidelines about manipulating globals apply to For2 as well.  In addition, the loop variable must 
#		be a global (this is handled for you -- if this hack isn't sufficiently general, use For2Loop directly).
#
function For2(string init, string cond, string iter, string block)
{
	For2Loop("global " + init, cond, "global " + iter, block)
}

function For2Loop(string init, string cond, string iter, string block)
{
	Eval(init)
	return Eval(cond)
		\ ? Eval("""
					Eval(block)
					For2Loop(iter, cond, iter, block)
				""")
		\ : NOP
}

# For3
#
#	Same as For, but implemented using For2.  Mostly a proof of concept, but there's a practical difference: the 
#	loop variable here is global, so nesting For3's probably does weird things.
#
function For3(int i, string cond, string iter, string block)
{
	For2("i=" + string(i), "i" + cond, "i=i" + iter, block)
}


# While
#
#	A simple while-loop construct for Avisynth 2.xx
#
# USAGE: while(b, "DoSomething()")
#				...is semantically equivalent to while(b) { DoSomething() } in C/C++
#
# Notes:
#	-	If you put it into an infinite loop, the host app will crash after several seconds.  An easy way to do this
#		is to forget to use 'global' when manipulating variables that affect 'cond' inside the loop.
#	- 	I honestly don't think this is a very useful function.  Most of the time you want while()-like semantics, you
#		really want to operate on frames (not clips or other variables), in which case ConditionalFilter is the far 
#		better choice.
#
function While(string cond, string block)
{
	For2Loop("", cond, "", block)
}


#http://forum.doom9.org/showthread.php?t=111526 redfordxx 23rd May 2006, 21:14 

function Matrix (clip clp, int "uv")
{
uv     = default(uv,3)       

unit=blankclip(clp,width=4,height=4,pixel_type="YV12")
row=stackhorizontal( 	unit.mt_lut(y=0,u=2,v=2),
	\		unit.mt_lut(y=-1,u=2,v=2),
	\		unit.mt_lut(y=-2,u=2,v=2),
	\		unit.mt_lut(y=-3,u=2,v=2),
	\		unit.mt_lut(y=-4,u=2,v=2),
	\		unit.mt_lut(y=-5,u=2,v=2),
	\		unit.mt_lut(y=-6,u=2,v=2),
	\		unit.mt_lut(y=-7,u=2,v=2))
square=stackvertical( 	row.mt_lut("x 0 +",y=3,u=2,v=2),
	\		row.mt_lut("x 8 +",y=3,u=2,v=2),
	\		row.mt_lut("x 16 +",y=3,u=2,v=2),
	\		row.mt_lut("x 24 +",y=3,u=2,v=2),
	\		row.mt_lut("x 32 +",y=3,u=2,v=2),
	\		row.mt_lut("x 40 +",y=3,u=2,v=2),
	\		row.mt_lut("x 48 +",y=3,u=2,v=2),
	\		row.mt_lut("x 56 +",y=3,u=2,v=2))
block=square#.mt_lut("x 4 *",y=3,u=2,v=2)
block4=stackvertical(stackhorizontal(block,block),stackhorizontal(block,block)).pointresize(16,16)
block4 = (uv!=3) 	? block4.mt_lut(y=3,u=uv,v=uv)
	\		: YtoUV(block4.crop(0,0,8,8),block4.crop(0,0,8,8),block4)
return(block4.trim(1,1))
}




function PtrnFormat(clip clp, clip form)
{
fh=form.height
fw=form.width
clp=StackHorizontal(clp,clp,clp,clp,clp,clp,clp,clp,clp,clp,clp)
clp=StackVertical(clp,clp,clp,clp,clp,clp,clp,clp,clp)
clp=(fw > 160) ? StackHorizontal(clp,clp,clp,clp) : clp
clp=(fh > 128) ? StackVertical(clp,clp,clp,clp) : clp
clp=(fw > 640) ? StackHorizontal(clp,clp,clp) : clp
clp=(fh > 512) ? StackVertical(clp,clp,clp) : clp
clp=clp.crop(0,0,fw,fh)

return(clp.loop(framecount(form)))
}




function PtrnVertical(clip clp, int "uv", int "v0", int "v1", int "v2", int "v3", int "v4", int "v5", int "v6", int "v7")
{
v1     = default(v1,255-v0)       
v2     = default(v2,v1)       
v3     = default(v3,v2)       
v4     = default(v4,v3)       
v5     = default(v5,v2)       
v6     = default(v6,v1)       
v7     = default(v7,v0)       

mtrx=Matrix(clp,uv)
ptrn=mt_lutxy(mtrx,mtrx,"x 8 % 0 == "+String(v0)+" "+String(v1)+" ?",y=3,u=uv,v=uv)
ptrn=mt_lutxy(mtrx,ptrn,"x 8 % 2 == "+String(v2)+" y ?",y=3,u=uv,v=uv)
ptrn=mt_lutxy(mtrx,ptrn,"x 8 % 3 == "+String(v3)+" y ?",y=3,u=uv,v=uv)
ptrn=mt_lutxy(mtrx,ptrn,"x 8 % 4 == "+String(v4)+" y ?",y=3,u=uv,v=uv)
ptrn=mt_lutxy(mtrx,ptrn,"x 8 % 5 == "+String(v5)+" y ?",y=3,u=uv,v=uv)
ptrn=mt_lutxy(mtrx,ptrn,"x 8 % 6 == "+String(v6)+" y ?",y=3,u=uv,v=uv)
ptrn=mt_lutxy(mtrx,ptrn,"x 8 % 7 == "+String(v7)+" y ?",y=3,u=uv,v=uv)

return(ptrn.PtrnFormat(clp))
}




function PtrnHorizontal(clip clp, int "uv", int "v0", int "v1", int "v2", int "v3", int "v4", int "v5", int "v6", int "v7")
{
v1     = default(v1,255-v0)       
v2     = default(v2,v1)       
v3     = default(v3,v2)       
v4     = default(v4,v3)       
v5     = default(v5,v2)       
v6     = default(v6,v1)       
v7     = default(v7,v0)       

mtrx=Matrix(clp,uv)
ptrn=mt_lutxy(mtrx,mtrx,"x 4 - 8 / 8 % 0 == "+String(v0)+" "+String(v1)+" ?",y=3,u=uv,v=uv)
ptrn=mt_lutxy(mtrx,ptrn,"x 4 - 8 / 8 % 2 == "+String(v2)+" y ?",y=3,u=uv,v=uv)
ptrn=mt_lutxy(mtrx,ptrn,"x 4 - 8 / 8 % 3 == "+String(v3)+" y ?",y=3,u=uv,v=uv)
ptrn=mt_lutxy(mtrx,ptrn,"x 4 - 8 / 8 % 4 == "+String(v4)+" y ?",y=3,u=uv,v=uv)
ptrn=mt_lutxy(mtrx,ptrn,"x 4 - 8 / 8 % 5 == "+String(v5)+" y ?",y=3,u=uv,v=uv)
ptrn=mt_lutxy(mtrx,ptrn,"x 4 - 8 / 8 % 6 == "+String(v6)+" y ?",y=3,u=uv,v=uv)
ptrn=mt_lutxy(mtrx,ptrn,"x 4 - 8 / 8 % 7 == "+String(v7)+" y ?",y=3,u=uv,v=uv)

return(ptrn.PtrnFormat(clp))
}



function PtrnBlock(clip clp, int "uv", int "v0", int "v1", int "v2", int "v3")
{
v1     = default(v1,255-v0)       
v2     = default(v2,v1)       
v3     = default(v3,v2)       

mtrx=Matrix(clp,uv)
ptrn=mt_lutxy(mtrx,mtrx,"x 4 - 8 / 8 % 1 >= x 4 - 8 / 8 % 6 <= & x 8 % 1 >= x 8 % 6 <= & & "+String(v1)+" "+String(v0)+" ?",y=3,u=uv,v=uv)
ptrn=mt_lutxy(mtrx,ptrn,"x 4 - 8 / 8 % 2 >= x 4 - 8 / 8 % 5 <= & x 8 % 2 >= x 8 % 5 <= & & "+String(v2)+" y ?",y=3,u=uv,v=uv)
ptrn=mt_lutxy(mtrx,ptrn,"x 4 - 8 / 8 % 3 >= x 4 - 8 / 8 % 4 <= & x 8 % 3 >= x 8 % 4 <= & & "+String(v3)+" y ?",y=3,u=uv,v=uv)

return(ptrn.PtrnFormat(clp))
}




function PtrnChess(clip clp, int "uv", int "v0", int "v1", int "v2", int "v3")
{
v1     = default(v1,255-v0)       
v2     = default(v2,v0)       
v3     = default(v3,v1)       

mtrx=Matrix(clp,uv)
ptrn=mt_lutxy(mtrx,mtrx,"x 4 - 8 / 2 % 0 == x 2 % 0 == & "+String(v0)+" "+String(v1)+" ?",y=3,u=uv,v=uv)
ptrn=mt_lutxy(mtrx,ptrn,"x 4 - 8 / 2 % 1 == x 2 % 1 == & "+String(v2)+" y ?",y=3,u=uv,v=uv)
ptrn=mt_lutxy(mtrx,ptrn,"x 4 - 8 / 2 % 1 == x 2 % 0 == & "+String(v3)+" y ?",y=3,u=uv,v=uv)

return(ptrn.PtrnFormat(clp))
}




function PtrnSawH(clip clp, int "uv", string "shift", int "v0", int "v1", int "v2", int "v3", int "v4", int "v5", int "v6", int "v7")
{
v1     = default(v1,255-v0)       
v2     = default(v2,v1)       
v3     = default(v3,v2)       
v4     = default(v4,v3)       
v5     = default(v5,255-v4)       
v6     = default(v6,v5)       
v7     = default(v7,v6)       

mtrx=Matrix(clp,uv)
ptrn=mt_lutxy(mtrx,mtrx,"x 4 - 8 / 8 % 0 == x 2 % "+shift+" 2 %  == & x 4 + 8 / 8 % 0 == x 1 + 2 % "+shift+" 2 % == & | "+String(v0)+" "+String(v1)+" ?",y=3,u=uv,v=uv)
ptrn=mt_lutxy(mtrx,ptrn,"x 4 - 8 / 8 % 2 == x 2 % "+shift+" 2 %  == & x 4 + 8 / 8 % 2 == x 1 + 2 % "+shift+" 2 % == & | "+String(v2)+" y ?",y=3,u=uv,v=uv)
ptrn=mt_lutxy(mtrx,ptrn,"x 4 - 8 / 8 % 3 == x 2 % "+shift+" 2 %  == & x 4 + 8 / 8 % 3 == x 1 + 2 % "+shift+" 2 % == & | "+String(v3)+" y ?",y=3,u=uv,v=uv)
ptrn=mt_lutxy(mtrx,ptrn,"x 4 - 8 / 8 % 4 == x 2 % "+shift+" 2 %  == & x 4 + 8 / 8 % 4 == x 1 + 2 % "+shift+" 2 % == & | "+String(v4)+" y ?",y=3,u=uv,v=uv)
ptrn=mt_lutxy(mtrx,ptrn,"x 4 - 8 / 8 % 5 == x 2 % "+shift+" 2 %  == & x 4 + 8 / 8 % 5 == x 1 + 2 % "+shift+" 2 % == & | "+String(v5)+" y ?",y=3,u=uv,v=uv)
ptrn=mt_lutxy(mtrx,ptrn,"x 4 - 8 / 8 % 6 == x 2 % "+shift+" 2 %  == & x 4 + 8 / 8 % 6 == x 1 + 2 % "+shift+" 2 % == & | "+String(v6)+" y ?",y=3,u=uv,v=uv)
ptrn=mt_lutxy(mtrx,ptrn,"x 4 - 8 / 8 % 7 == x 2 % "+shift+" 2 %  == & x 4 + 8 / 8 % 7 == x 1 + 2 % "+shift+" 2 % == & | "+String(v7)+" y ?",y=3,u=uv,v=uv)

return(ptrn.PtrnFormat(clp))
}



function PtrnSawV(clip clp, int "uv", string "shift", int "v0", int "v1", int "v2", int "v3", int "v4", int "v5", int "v6", int "v7")
{
v1     = default(v1,255-v0)       
v2     = default(v2,v1)       
v3     = default(v3,v2)       
v4     = default(v4,v3)       
v5     = default(v5,255-v4)       
v6     = default(v6,v5)       
v7     = default(v7,v6)       

mtrx=Matrix(clp,uv)
ptrn=mt_lutxy(mtrx,mtrx,"x 4 - 8 / 2 % "+shift+" 2 % == x 8 % 0 == & x 4 + 8 / 2 % "+shift+" 2 % == x 1 + 8 % 0 == & | "+String(v0)+" "+String(v1)+" ?",y=3,u=uv,v=uv)
ptrn=mt_lutxy(mtrx,ptrn,"x 4 - 8 / 2 % "+shift+" 2 % == x 8 % 2 == & x 4 + 8 / 2 % "+shift+" 2 % == x 1 + 8 % 2 == & | "+String(v2)+" y ?",y=3,u=uv,v=uv)
ptrn=mt_lutxy(mtrx,ptrn,"x 4 - 8 / 2 % "+shift+" 2 % == x 8 % 3 == & x 4 + 8 / 2 % "+shift+" 2 % == x 1 + 8 % 3 == & | "+String(v3)+" y ?",y=3,u=uv,v=uv)
ptrn=mt_lutxy(mtrx,ptrn,"x 4 - 8 / 2 % "+shift+" 2 % == x 8 % 4 == & x 4 + 8 / 2 % "+shift+" 2 % == x 1 + 8 % 4 == & | "+String(v4)+" y ?",y=3,u=uv,v=uv)
ptrn=mt_lutxy(mtrx,ptrn,"x 4 - 8 / 2 % "+shift+" 2 % == x 8 % 5 == & x 4 + 8 / 2 % "+shift+" 2 % == x 1 + 8 % 5 == & | "+String(v5)+" y ?",y=3,u=uv,v=uv)
ptrn=mt_lutxy(mtrx,ptrn,"x 4 - 8 / 2 % "+shift+" 2 % == x 8 % 6 == & x 4 + 8 / 2 % "+shift+" 2 % == x 1 + 8 % 6 == & | "+String(v6)+" y ?",y=3,u=uv,v=uv)
ptrn=mt_lutxy(mtrx,ptrn,"x 4 - 8 / 2 % "+shift+" 2 % == x 8 % 7 == & x 4 + 8 / 2 % "+shift+" 2 % == x 1 + 8 % 7 == & | "+String(v7)+" y ?",y=3,u=uv,v=uv)

return(ptrn.PtrnFormat(clp))
}

function AverageBlock8(clip orig)
{
o1=orig.mt_convolution("0 0 0 0 0 0 0 1 1 1 1 1 1 1 1","0 0 0 0 0 0 0 1 1  
1 1 1 1 1 1",y=3,u=3,v=3)
o1=o1.pointresize(o1.width/8,o1.height/8)
o1=o1.pointresize(o1.width*8,o1.height*8)
return(o1)
}


function VerticalLinearBlock(clip orig)
{
p1=PtrnHorizontal(orig,3,255,219,182,146,109,73,36,0)
top1=orig.PointResize(orig.width,orig.height/8)
top2=top1.PointResize(orig.width,orig.height)
shift1=orig.mt_convolution("1","0 0 0 0 0 0 0 0 0 0 0 0 0 0 1",y=3,u=3,v=3)
bottom1=shift1.PointResize(orig.width,orig.height/8)
bottom2=bottom1.PointResize(orig.width,orig.height)
mt_merge(bottom2,top2,p1,y=3,u=3,v=3)
}


function HorizontalLinearBlock(clip orig)
{
p1=PtrnVertical(orig,3,255,219,182,146,109,73,36,0)
top1=orig.PointResize(orig.width/8,orig.height)
top2=top1.PointResize(orig.width,orig.height)
shift1=orig.mt_convolution("0 0 0 0 0 0 0 0 0 0 0 0 0 0 1","1",y=3,u=3,v=3)
bottom1=shift1.PointResize(orig.width/8,orig.height)
bottom2=bottom1.PointResize(orig.width,orig.height)
mt_merge(bottom2,top2,p1,y=3,u=3,v=3)
}

###############################################
# SmoothDeblock 0.3 by Redford
#
# 
# issues and todo's:
# find best averaging weight matrices for combining DCT shifts (=minimize artefacts at high quants and increase sharpness)
# find best smoothing of the adaptation mask clip or better, adaptationmask shouldnot be block oriented, but only detail oriented
# 
# tuning and speed up
#
###############################################

function ShiftDCTBack(clip orig,int density, clip wmc, float wms, string dct_type, int i, int j, int DCTorig, int "quant")
{
l=orig.crop(0,0,Int(8/density)*i+16,-0).FlipHorizontal()
r=orig.crop(orig.Width-Int(8/density)*i-16,0,-0,-0).FlipHorizontal()
cMain=(i==0) ? orig : StackHorizontal(l,orig,r)
t=cMain.crop(0,0,0,Int(8/density)*j+16).FlipVertical()
b=cMain.crop(0,orig.height-Int(8/density)*j-16,0,-0).FlipVertical()
cMain=(j==0) ? cMain : StackVertical(t,cMain,b)
cMain=(i+j==0) ? orig : MergeChroma(cMain,cMain.AddBorders(Int(8/density)*i,Int(8/density)*j,0,0).Crop(0,0,cMain.Width,cMain.Height))
cMain=(i==0) ? cMain : cMain.crop(16,0,orig.Width+16,0)
cMain=(j==0) ? cMain : cMain.crop(0,16,0,orig.Height+16)
cMain=((i+j==0)&&(DCTorig==0)) ? orig : (dct_type=="DCTFilterD") ? cMain.DCTFilterD(quant) : cMain.DCTFilter(DctParams7,DctParams6,DctParams5,DctParams4,DctParams3,DctParams2,DctParams1,DctParams0)
cFlot=mt_lutxy(cMain,wmc,"x y * 255 %",y=3,u=3,v=3)
cMain=mt_lutxy(cMain,wmc,"x y * x y * 255 % - 255 /",y=3,u=3,v=3)
cFlot=(i+j==0) ? cFlot : MergeChroma(cFlot,cFlot.AddBorders(0,0,Int(8/density)*i,Int(8/density)*j).Crop(Int(8/density)*i,Int(8/density)*j,cFlot.Width,cFlot.Height))
cMain=(i+j==0) ? cMain : MergeChroma(cMain,cMain.AddBorders(0,0,Int(8/density)*i,Int(8/density)*j).Crop(Int(8/density)*i,Int(8/density)*j,cMain.Width,cMain.Height))
shiftClip.Set(i*density+j+Int(Pow(density,2)),(i+j==0) ? cFlot : cFlot.crop(Int(8/density)*i,Int(8/density)*j,orig.Width(),orig.height))
shiftClip.Set(i*density+j,                    (i+j==0) ? cMain : cMain.crop(Int(8/density)*i,Int(8/density)*j,orig.Width(),orig.height))
global avgI = avgI+", shiftClip"+String(i*density+j)+", 255.0/"+String(wms)
global avgF = (i+j==0) ? avgF : avgF+", shiftClip"+String(i*density+j+Int(Pow(density,2)))+", "+String(1/Pow(density,2))
}

function SmoothDeblockLayer(clip orig,float quant,int density, clip wmc, float wms, string "dct_type",int "DCTorig")
{
global gDCTtype=default(dct_type,"DCTFilter")    #fixed now
global gDensity=density  #number of DCT per 8 pix 
global gOrig=orig
global rep=wms*Pow(density,2)
global q=Int(quant)
global matrix1=wmc
global avgI="clipAverageFloat, "+String(1/wms)
global avgF="shiftClip"+String(Int(Pow(density,2)))+", "+String(1/Pow(density,2))
global DCTO=default(DCTorig,0)

Dim("DctParams",8,0)
Dim("shiftClip",Int(Pow(density,2))*2,Blackness())
For2("i=7","i>="+String(quant),"i=i-1",
\"""
    DctParams.Set(i,1)
""")
For2("i=0", "i<gDensity", "i=i+1",
\"""
    For2("j=0", "j<gDensity", "j=j+1",
    \"
ShiftDCTBack(gOrig,gDensity,matrix1,rep,gDCTtype,i,j,DCTO,q)    
    ")
""")
Eval("clipAverageFloat=Average("+avgF+")")
Eval("Average("+avgI+")")
#Subtitle(avgI)
}




function QuantDiff(clip orig,float "quant",string "dct_type")
{
dct_type = default(dct_type,"DCTFilter")    #fixed now
quant    =default(quant,4)

Dim("DctParams",8,0)
For2("i=7","i>="+String(quant),"i=i-1",
\"""
    DctParams.Set(i,1)
""")
#a=AverageBlock8(orig)
a=orig.DCTFilter(1,0,0,0,0,0,0,0)
n=mt_makediff(orig,a,y=3,u=3,v=3)
d=n.DCTFilter(1,1-DctParams6,1-DctParams5,1-DctParams4,1-DctParams3,1-DctParams2,1-DctParams1,1-DctParams0)
d
}




function AdaptionMask(clip orig,int "pregain",int "pregainoffset",int "gain",string "adaption_blursmall",string "adaption_blurbig")
{
pregainoffset   =default(pregainoffset,-2)
pregain    =default(pregain,100)
gain    =default(gain,100)
adaption_blursmall  =default(adaption_blursmall,"1")
#adaption_blurbig    =default(adaption_blurbig,"1 1 2 2 2 1 1")
adaption_blurbig    =default(adaption_blurbig,"1")

o1=orig.mt_lut("x 128 - abs x 128 == 0 "+string(pregainoffset)+" ? + "+string(pregain)+" *",y=3,u=3,v=3)
o1=o1.mt_convolution("0 0 0 0 0 0 0 1 1 1 1 1 1 1 1","0 0 0 0 0 0 0 1 1 1 1 1 1 1 1",y=3,u=3,v=3).AddBorders(0,0,(32 - (orig.width % 32)) % 32,(32 - (orig.height % 32)) % 32)
o1=o1.pointresize(o1.width/8,o1.height/8)
o1=(adaption_blursmall=="1") ? o1 : \
   (adaption_blursmall=="expand") ? o1.mt_expand(y=3,u=3,v=3) : \
   (adaption_blursmall=="inpand") ? o1.mt_inpand(y=3,u=3,v=3) : \
   (adaption_blursmall=="inflate") ? o1.mt_inflate(y=3,u=3,v=3) : \
   (adaption_blursmall=="deflate") ? o1.mt_deflate(y=3,u=3,v=3) : \
  o1.mt_convolution(adaption_blursmall,adaption_blursmall,y=3,u=3,v=3)
o1=o1.pointresize(o1.width*8,o1.height*8).Crop(0,0,orig.width,orig.height)
o1=(adaption_blurbig=="1") ? o1 : o1.mt_convolution(adaption_blurbig,adaption_blurbig,y=3,u=3,v=3)
o1=o1.mt_lut("x "+string(gain)+" *",y=3,u=3,v=3)
return(o1)
}



function AdaptionMaskDiff(clip orig, clip deb,float "quant", int "pregain", int "pregainoffset", int "gain", int "thresh", string "adaption_blur", int "borders", int "expands" ,string "dct_type")
{
pregainoffset   =default(pregainoffset,-3)
pregain    =default(pregain,100)
borders   =default(borders,0)
expands    =default(expands,1)
gain    =default(gain,8)
thresh    =default(thresh,2)
adaption_blur    =default(adaption_blur,"1 2 1")
dct_type =default(dct_type,"DCTFilter")    #fixed now
quant    =default(quant,4)

Dim("DctParams",8,0)
For2("i=7","i>="+String(quant),"i=i-1",
\"""
    DctParams.Set(i,1)
""")
#a=AverageBlock8(orig)
a=orig.DCTFilter(1,0,0,0,0,0,0,0)
n=mt_makediff(orig,a,y=3,u=3,v=3)
d=n.DCTFilter(1,1-DctParams6,1-DctParams5,1-DctParams4,1-DctParams3,1-DctParams2,1-DctParams1,1-DctParams0)

o1=d.mt_lut("x 128 - abs x 128 == 0 "+string(pregainoffset)+" ? + "+string(pregain)+" *",y=3,u=3,v=3)
o1=o1.DCTFilter(1,0,0,0,0,0,0,0)
o1=o1.mt_lut("x "+string(pregain/5)+" *",y=3,u=3,v=3)

diff=mt_makediff(deb,orig,y=3,u=3,v=3)
diff2=mt_lutxy(o1,diff,"y 128 - x * 255 / abs "+string(thresh)+" -",y=3,u=3,v=3) 
p1=diff2.PtrnBlock(3,borders,255,255,255)
diff3=mt_lutxy(diff2,p1,"x y * 255 / "+string(gain)+" *",y=3,u=3,v=3)
diff4=diff3.mt_expand(y=3,u=3,v=3)
(adaption_blur=="1") ? diff4 : diff4.mt_convolution(adaption_blur,adaption_blur,y=3,u=3,v=3)
mt_lut("x "+string(gain)+" *",y=3,u=3,v=3)
(expands>0) ? mt_expand(y=3,u=3,v=3) : last
(expands>1) ? mt_expand(y=3,u=3,v=3) : last
(expands>2) ? mt_expand(y=3,u=3,v=3) : last
(expands>3) ? mt_expand(y=3,u=3,v=3) : last
(expands>4) ? mt_expand(y=3,u=3,v=3) : last
}





function WeightMatrixClip(clip orig, string "name",int "level")
{
level=default(level,0)
clp=orig.Crop(0,0,16,16).Trim(1,1)
name=default(name,"04center255x2")

mx1 =  (name=="04all78")||(name=="04center255x2")||(name=="16center255") ? clp : clp.Matrix(3).PtrnFormat(clp)
mx  =  (name=="04center255border0smooth_1") ? clp.PtrnBlock(3,0,50,200,255) : \
   (name=="16center255border0smooth_1") ? clp.PtrnBlock(3,0,70,185,255) : \
   (name=="16center255border0smooth_2") ? clp.PtrnBlock(3,100,150,220,255) : clp
#middle1
mx  =   (name=="04all78")||(name=="04center255x2")||(name=="16center255") ? mx : mt_lutxy(mx,mx1,"y 12 == y 11 == y 25 == y 30 == y 33 == y 38 == y 51 == y 52 == | | | | | | | " + ( \
(name=="04center255border0smooth_1") ? "55"  : \
(name=="16center255border0smooth_1") ? "115" : \
(name=="16center255border0smooth_2") ? "180" : \
  "x") + " x ?",y=3,u=3,v=3)
#diag0
#diag1
mx  =   (name=="04all78")||(name=="04center255x2")||(name=="16center255") ? mx : mt_lutxy(mx,mx1,"y 9 == y 14 == y 54 == y 49 == | | | " + ( \
(name=="04center255border0smooth_1") ? "25" : \
(name=="16center255border0smooth_1") ? "20" : \
(name=="16center255border0smooth_2") ? "130" : \
  "x") + " x ?",y=3,u=3,v=3)
#diag2  
mx  =   (name=="04all78")||(name=="04center255x2")||(name=="16center255") ? mx : mt_lutxy(mx,mx1,"y 18 == y 21 == y 42 == y 45 == | | | " + ( \
(name=="04center255border0smooth_1") ? "130" : \
(name=="16center255border0smooth_1") ? "140" : \
(name=="16center255border0smooth_2") ? "200" : \
  "x") + " x ?",y=3,u=3,v=3)

(name=="16center255")   ? (clp.PtrnBlock(3,0,0,0,255)) : \
(name=="04center255x2") ? (clp.PtrnBlock(3,0,0,255,255)): \
(name=="04all78") ? (clp.PtrnBlock(3,150,150,212,212)): \
   mx
#mt_lut(String(level)+" 255 "+String(level)+" - 255 / x * +",y=3,u=3,v=3)
PtrnFormat(orig)
}

function WeightMatrixSum(string "name",int "level")
{
level=default(level,0)
l=(name=="16center255")    ? (255.0/16) : \
(name=="04center255x2")  ? (255.0/4): \
(name=="04center255border0smooth_1") ? (255.0/4): \
(name=="16center255border0smooth_1") ? (1155.0/16): \
(name=="16center255border0smooth_2") ? (2385.0/16): \
(name=="04all78")  ? (662.0/4): \
     (255.0/4)
#return((255.0-level)/255.0*l+level)
l
}



function BorderMask(clip orig, int "bth1", int "bth2", int "bshare", int "eth1", int "eth2", int "eshare", float "buvmod", float "euvmod")
{
bth1=default(bth1,0)
bth2=default(bth2,2)
bshare=default(bshare,200)
eth1=default(eth1,30)
eth2=default(eth2,50)
eshare=default(eshare,0)  #0=real edge protection off
buvmod=default(buvmod,2.0)
euvmod=default(euvmod,2.4)

ph=orig.PtrnHorizontal(3,0,1,2,3,4,5,6,7)
pv=orig.PtrnVertical(3,0,1,2,3,4,5,6,7) 
h1a=orig.mt_lutxy(ph,"y 0 == y 7 == | x 128 ?",y=3,u=3,v=3)
v1a=orig.mt_lutxy(pv,"y 0 == y 7 == | x 128 ?",y=3,u=3,v=3)
h1b=orig.mt_lutxy(ph,"y 1 == y 6 == | x 128 ?",y=3,u=3,v=3)
v1b=orig.mt_lutxy(pv,"y 1 == y 6 == | x 128 ?",y=3,u=3,v=3)
h2a=h1a.mt_convolution(horizontal="1",vertical="1 -1 1",total=1,y=3,u=3,v=3)
v2a=v1a.mt_convolution(horizontal="1 -1 1",vertical="1",total=1,y=3,u=3,v=3)
h2b=h1b.mt_convolution(horizontal="1",vertical="1 -1 1 -1 1",total=1,y=3,u=3,v=3)
v2b=v1b.mt_convolution(horizontal="1 -1 1 -1 1",vertical="1",total=1,y=3,u=3,v=3)
v2=mt_lutxy(v2a,v2b,"x 128 - y 128 - 3 / - abs x 128 - abs > x x y 128 - 3 / - ?",y=3,u=3,v=3)
h2=mt_lutxy(h2a,h2b,"x 128 - y 128 - 3 / - abs x 128 - abs > x x y 128 - 3 / - ?",y=3,u=3,v=3)
v3b=v2.mt_lutxy(pv,"y 0 == y 7 == | x 128 ? 128 - abs 5 * 1.1 * ",y=3,u=3,v=3).mt_convolution(horizontal="1",vertical="1 1 1",y=3,u=3,v=3)
h3b=h2.mt_lutxy(ph,"y 0 == y 7 == | x 128 ? 128 - abs 5 * 1.1 * ",y=3,u=3,v=3).mt_convolution(horizontal="1 1 1",vertical="1",y=3,u=3,v=3)
v3e0=v2a.mt_convolution(horizontal="1",vertical="1 1 1 1 1 1 1 1 1",y=3,u=2,v=2).mt_convolution(horizontal="1",vertical="1 1 1 1 1 1 1",y=2,u=3,v=3)
h3e0=h2a.mt_convolution(horizontal="1 1 1 1 1 1 1 1 1",vertical="1",y=3,u=2,v=2).mt_convolution(horizontal="1 1 1 1 1 1 1",vertical="1",y=2,u=3,v=3)
v3e=(eshare==0) ? orig : v3e0.mt_lutxy(pv,yexpr="y 0 == y 7 == | x 128 ? 128 - abs "+String(eth1)+" - "+String(eth2)+" "+String(eth1)+" - / 255 *", \
					 uexpr="y 0 == y 7 == | x 128 ? 128 - abs "+String(eth1/euvmod)+" - "+String(eth2/euvmod)+" "+String(eth1/euvmod)+" - / 255 *", \
					 vexpr="y 0 == y 7 == | x 128 ? 128 - abs "+String(eth1/euvmod)+" - "+String(eth2/euvmod)+" "+String(eth1/euvmod)+" - / 255 *",y=3,u=3,v=3)
h3e=(eshare==0) ? orig : h3e0.mt_lutxy(ph,yexpr="y 0 == y 7 == | x 128 ? 128 - abs "+String(eth1)+" - "+String(eth2)+" "+String(eth1)+" - / 255 *", \
					 uexpr="y 0 == y 7 == | x 128 ? 128 - abs "+String(eth1/euvmod)+" - "+String(eth2/euvmod)+" "+String(eth1/euvmod)+" - / 255 *", \
					 vexpr="y 0 == y 7 == | x 128 ? 128 - abs "+String(eth1/euvmod)+" - "+String(eth2/euvmod)+" "+String(eth1/euvmod)+" - / 255 *",y=3,u=3,v=3)
v4e=(eshare==0) ? orig : v3e.HorizontalLinearBlock
h4e=(eshare==0) ? orig : h3e.VerticalLinearBlock
e1=(eshare==0) ? orig : mt_lutxy(v4e,h4e,"x y > x y ?",y=3,u=3,v=3)
e2=(eshare==0) ? orig : e1.mt_lut("255 x - "+String(eshare)+" * 255 / "+String(eshare)+" - 255 +",y=3,u=3,v=3)
v4b=(eshare==0) ? v3b : v3b.mt_lutxy(v3e,"x y 1 + /",y=3,u=3,v=3)
h4b=(eshare==0) ? h3b : h3b.mt_lutxy(h3e,"x y 1 + /",y=3,u=3,v=3)
v5b=v4b.HorizontalLinearBlock
h5b=h4b.VerticalLinearBlock
b1=mt_lutxy(v5b,h5b,yexpr="x y > x y ? 5 / "+String(bth1)+" - "+String(bth2)+" "+String(bth1)+" - / 255 *", \
			        uexpr="x y > x y ? 5 / "+String(bth1/buvmod)+" - "+String(bth2/buvmod)+" "+String(bth1/buvmod)+" - / 255 *", \
			        vexpr="x y > x y ? 5 / "+String(bth1/buvmod)+" - "+String(bth2/buvmod)+" "+String(bth1/buvmod)+" - / 255 *",y=3,u=3,v=3)
b2=b1.mt_convolution(horizontal="1 1 1 1 1",vertical="1 1 1 1 1",y=3,u=3,v=3)
b3=b2.mt_lut("x "+String(bshare)+" * 255 / "+String(bshare)+" - 255 +",y=3,u=3,v=3)
(eshare==0) ? b3 : mt_lutxy(e2,b3,"x y < x y ?",y=3,u=3,v=3)
}
function SmoothDeblock1(clip orig, int "passes", int "density", int "inclOrig", string "wieghtMX",string "dct_type",int "pregain",int "pregainoffset",int "gain",string "adaption_blursmall",string "adaption_blurbig")
{
passes=3#fixed for now
inclOrig=default(inclOrig,1)
density=default(density,2)
pregainoffset=default(pregainoffset,0)
pregain=default(pregain,10)
gain=default(gain,10)
b1=default(adaption_blursmall,"1")
b2=default(adaption_blurbig,"1 1 2 2 2 1 1")
wieghtMX=default(wieghtMX,"04center255border0smooth_1")
dct_type=default(dct_type,"DCTFilter")

mx2=orig.AddBorders(16,16,0,0).WeightMatrixClip(wieghtMX)
mxs=WeightMatrixSum(wieghtMX)





sdl8=orig.LanczosResize(orig.width/2,orig.height/2)
sdl8=((sdl8.Width % 32)==0) ? sdl8 : StackHorizontal(sdl8,sdl8.crop(sdl8.Width-32+(sdl8.Width % 32),0,-0,-0).FlipHorizontal())
sdl8=((sdl8.height % 32)==0) ? sdl8 : StackVertical(sdl8,sdl8.crop(0,sdl8.height-32+(sdl8.height % 32),-0,-0).FlipVertical())
sdl8=sdl8.SmoothDeblockLayer(5,density,mx2,mxs,"DCTFilter",DCTorig=1)
sdl8=sdl8.GaussResize(sdl8.width*2,sdl8.height*2,p=20).crop(0,0,orig.width,orig.height)
#sdl8=sdl8.mt_convolution("1 2 1","1 2 1",y=3,u=3,v=3)
sdl5=orig.SmoothDeblockLayer(5,density,mx2,mxs,"DCTFilter")
sdl3=orig.SmoothDeblockLayer(3,density,mx2,mxs,"DCTFilter")
qd8=orig.QuantDiff(6)
qd5=orig.QuantDiff(5)
qdo=orig.QuantDiff(inclOrig)
am8=qd8.AdaptionMask(pregain,pregainoffset,gain,b1,b2)
am5=qd5.AdaptionMask(pregain,pregainoffset,gain,b1,b2)
amo=qdo.AdaptionMask(pregain,pregainoffset,gain,b1,b2)

deblocked=mt_merge(sdl8,sdl5,am8,y=3,u=3,v=3) 
deblocked=mt_merge(deblocked,sdl3,am5,y=3,u=3,v=3) 
deblocked=(inclOrig==0) ? deblocked : mt_merge(deblocked,orig,amo,y=3,u=3,v=3) 
return(deblocked)
}



function SmoothDeblock2(clip orig, int "passes", int "density", int "inclOrig", string "wieghtMX",string "dct_type",int "pregain",int "pregainoffset",int "gain", int "thresh", string "adaption_blur")
{
passes=3#fixed for now
inclOrig=default(inclOrig,2)
density=default(density,2)
#pregainoffset=default(pregainoffset,-2)
#pregain=default(pregain,100)
#gain=default(gain,30)
#thresh=default(thresh,1)
#b2=default(adaption_blurbig,"1 1 1")
wieghtMX=default(wieghtMX,(density==4) ? "16center255border0smooth_1" : "04center255border0smooth_1")
dct_type=default(dct_type,"DCTFilter")

mx2=orig.AddBorders(16,16,0,0).WeightMatrixClip(wieghtMX)
mxs=WeightMatrixSum(wieghtMX)

sdl8=orig.LanczosResize(orig.width/2,orig.height/2)
sdl8=((sdl8.Width % 32)==0) ? sdl8 : StackHorizontal(sdl8,sdl8.crop(sdl8.Width-32+(sdl8.Width % 32),0,-0,-0).FlipHorizontal())
sdl8=((sdl8.height % 32)==0) ? sdl8 : StackVertical(sdl8,sdl8.crop(0,sdl8.height-32+(sdl8.height % 32),-0,-0).FlipVertical())
sdl8=sdl8.SmoothDeblockLayer(5,density,mx2,mxs,"DCTFilter",DCTorig=1)
sdl8=sdl8.GaussResize(sdl8.width*2,sdl8.height*2,p=20).crop(0,0,orig.width,orig.height)
#sdl8=sdl8.mt_convolution("1 2 1","1 2 1",y=3,u=3,v=3)
sdl5=orig.SmoothDeblockLayer(5,density,mx2,mxs,"DCTFilter")
sdl3=orig.SmoothDeblockLayer(3,density,mx2,mxs,"DCTFilter")
am8=orig.AdaptionMaskDiff(sdl8,6,pregain,pregainoffset,gain,thresh,adaption_blur,expands=5)
am5=orig.AdaptionMaskDiff(sdl5,5,pregain,pregainoffset,gain,thresh,adaption_blur,expands=2)
amo=orig.AdaptionMaskDiff(sdl3,inclOrig,pregain,pregainoffset,gain,thresh,adaption_blur,expands=1)

deblocked=sdl8
deblocked=mt_merge(deblocked,sdl5,am8,y=3,u=3,v=3) 
deblocked=mt_merge(deblocked,sdl3,am5,y=3,u=3,v=3) 
deblocked=(inclOrig==0) ? deblocked : mt_merge(deblocked,orig,amo,y=3,u=3,v=3) 
return(deblocked)
}



function SmoothDeblock3(clip orig, int "passes", int "density", int "inclOrig", string "wieghtMX",string "dct_type",int "pregain",int "pregainoffset",int "gain", int "thresh", string "adaption_blur", int "bth1", int "bth2", int "bshare", int "eth1", int "eth2", int "eshare", float "buvmod", float "euvmod")
{
passes=3#fixed for now
inclOrig=default(inclOrig,2)
density=default(density,2)
wieghtMX=default(wieghtMX,(density==4) ? "16center255border0smooth_1" : "04center255border0smooth_1")
dct_type=default(dct_type,"DCTFilter")

mx2=orig.AddBorders(16,16,0,0).WeightMatrixClip(wieghtMX)
mxs=WeightMatrixSum(wieghtMX)
bdm=orig.BorderMask(bth1, bth2, bshare, eth1, eth2, eshare)

sdl8=orig.LanczosResize(orig.width/2,orig.height/2)
sdl8=((sdl8.Width % 32)==0) ? sdl8 : StackHorizontal(sdl8,sdl8.crop(sdl8.Width-32+(sdl8.Width % 32),0,-0,-0).FlipHorizontal())
sdl8=((sdl8.height % 32)==0) ? sdl8 : StackVertical(sdl8,sdl8.crop(0,sdl8.height-32+(sdl8.height % 32),-0,-0).FlipVertical())
sdl8=sdl8.SmoothDeblockLayer(5,density,mx2,mxs,"DCTFilter",DCTorig=1)
sdl8=sdl8.GaussResize(sdl8.width*2,sdl8.height*2,p=20).crop(0,0,orig.width,orig.height)
#sdl8=sdl8.mt_convolution("1 2 1","1 2 1",y=3,u=3,v=3)
sdl5=orig.SmoothDeblockLayer(5,density,mx2,mxs,"DCTFilter")
sdl3=orig.SmoothDeblockLayer(3,density,mx2,mxs,"DCTFilter")
am8=orig.AdaptionMaskDiff(sdl8,6,pregain,pregainoffset,gain,thresh,adaption_blur,expands=5).mt_lutxy(bdm,"255 255 x - y * 255 / -",y=3,u=3,v=3)#   255-((255-x)*y)/255 = x+255-y-x*(255-y)/255
am5=orig.AdaptionMaskDiff(sdl5,5,pregain,pregainoffset,gain,thresh,adaption_blur,expands=2).mt_lutxy(bdm,"255 255 x - y * 255 / -",y=3,u=3,v=3)
amo=orig.AdaptionMaskDiff(sdl3,inclOrig,pregain,pregainoffset,gain,thresh,adaption_blur,expands=1).mt_lutxy(bdm,"255 255 x - y * 255 / -",y=3,u=3,v=3)

deblocked=sdl8
deblocked=mt_merge(deblocked,sdl5,am8,y=3,u=3,v=3) 
deblocked=mt_merge(deblocked,sdl3,am5,y=3,u=3,v=3) 
deblocked=(inclOrig==0) ? deblocked : mt_merge(deblocked,orig,amo,y=3,u=3,v=3) 
return(deblocked)
}



function SmoothDeblock4(clip orig, int "passes", int "density", int "inclOrig", string "wieghtMX",string "dct_type",int "pregain",int "pregainoffset",int "gain",string "adaption_blursmall",string "adaption_blurbig", int "bth1", int "bth2", int "bshare", int "eth1", int "eth2", int "eshare", float "buvmod", float "euvmod")
{
passes=3#fixed for now
inclOrig=default(inclOrig,1)
density=default(density,2)
pregainoffset=default(pregainoffset,0)
pregain=default(pregain,10)
gain=default(gain,10)
b1=default(adaption_blursmall,"1")
b2=default(adaption_blurbig,"1 1 2 2 2 1 1")
wieghtMX=default(wieghtMX,"04center255border0smooth_1")
dct_type=default(dct_type,"DCTFilter")

mx2=orig.AddBorders(16,16,0,0).WeightMatrixClip(wieghtMX)
mxs=WeightMatrixSum(wieghtMX)
bdm=orig.BorderMask(bth1, bth2, bshare, eth1, eth2, eshare)



sdl8=orig.LanczosResize(orig.width/2,orig.height/2)
sdl8=((sdl8.Width % 32)==0) ? sdl8 : StackHorizontal(sdl8,sdl8.crop(sdl8.Width-32+(sdl8.Width % 32),0,-0,-0).FlipHorizontal())
sdl8=((sdl8.height % 32)==0) ? sdl8 : StackVertical(sdl8,sdl8.crop(0,sdl8.height-32+(sdl8.height % 32),-0,-0).FlipVertical())
sdl8=sdl8.SmoothDeblockLayer(5,density,mx2,mxs,"DCTFilter",DCTorig=1)
sdl8=sdl8.GaussResize(sdl8.width*2,sdl8.height*2,p=20).crop(0,0,orig.width,orig.height)
#sdl8=sdl8.mt_convolution("1 2 1","1 2 1",y=3,u=3,v=3)
sdl5=orig.SmoothDeblockLayer(5,density,mx2,mxs,"DCTFilter")
sdl3=orig.SmoothDeblockLayer(3,density,mx2,mxs,"DCTFilter")
qd8=orig.QuantDiff(6)
qd5=orig.QuantDiff(5)
qdo=orig.QuantDiff(inclOrig)
am8=qd8.AdaptionMask(pregain,pregainoffset,gain,b1,b2).mt_lutxy(bdm,"255 255 x - y * 255 / -",y=3,u=3,v=3)
am5=qd5.AdaptionMask(pregain,pregainoffset,gain,b1,b2).mt_lutxy(bdm,"255 255 x - y * 255 / -",y=3,u=3,v=3)
amo=qdo.AdaptionMask(pregain,pregainoffset,gain,b1,b2).mt_lutxy(bdm,"255 255 x - y * 255 / -",y=3,u=3,v=3)

deblocked=mt_merge(sdl8,sdl5,am8,y=3,u=3,v=3) 
deblocked=mt_merge(deblocked,sdl3,am5,y=3,u=3,v=3) 
deblocked=(inclOrig==0) ? deblocked : mt_merge(deblocked,orig,amo,y=3,u=3,v=3) 
return(deblocked)
}