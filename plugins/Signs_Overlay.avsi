###  Overlay functions for RGBA videos and images with optional mattes
##
## Written by pichu, v0.4b
## Requires AVISynth 2.56+
## Put this into your avisynth plugins directory
## Preliminary: aviSign( clip c string "filename" [, bool "rescale" = false , string "alpha_file" , string "colorspace" ] ) - this will open the overlay video for all sign( ) and reset the frame number, until another aviSign( ) is declared.
## Preliminary: imgSign( clip c string "filename" [, bool "rescale"  = false , string "alpha_file" , "colorspace" ] ) - this will open the overlay image for all sign( ) and reset the frame number, until another aviSign( ) is declared.
##       Usage: sign( clip c , int "start_frame" = 0 , int "end_frame" = 0 ,  , int "offset" = 0 , string "mode" = "Blend" , int "x" = 0 , int "y" = 0 )
#   Parameters:            c           is the current clip getting overlayed (required)
#                          filename    is the filename of the RGBA overlay avi. (required)
#                          start_frame is the starting frame of the overlay. (default = 0)
#                          end_frame   is the ending frame of the overlay. (default = 0)
#                          offset      is the number of frames to offset from current. (default = 0)
#                          mode        is the blending mode of the current overlay segment. (default = "blend")
#                                Note:    When mode="splice", the current clip will be spliced instead of overlayed.
#                          x, y        are the coordinates offset (default = 0,0)
#                          colorspace  is the colorspace conversion.  It can be: RGB, RGB24, RGB32, YUY2, or YV12.

#   Conditions:   If start_frame = 0, it will compute using the number of frames in the overlay to the end_frame. 
#                 If end_frame = 0,   it will compute using the number of frames in the overlay to the start_frame. 
#                 If start_frame and end_frame are both 0, then the beginning of the video will get overlayed.
#                     Note: this code can't allow you to overlay the clip on frame 0 with only one frame.
# Examples:
#
# import( "Signs_Overlay.avsi" )
# sign( 1111 , 2222 ) +\
# sign( 4444 , 5555 )
# 
# The above example will generate the entire video sequence for clips at those frames. (synonymous to trim)
# Now, you just need to add in aviSign( ... ) and remove +\ to get the final overlays :)
#
# import( "Signs_Overlay.avsi" )
# aviSign( "Sign1.avi" ).sign( 1234 )   # Allow you to overlay Sign1.avi at frame #1234 and ends at wherever the overlay ends.
# aviSign( "Sign_all.avi" )
# sign( 1111 , 2222 )
# sign( 4444 , 5555 ) # The next sign, starting at frame 4444 and end at frame 5555 will get overlayed



global SIGN_OVERLAY = ""
global SIGN_FRAME = 0

function sign( clip c , int "start_frame" , int "end_frame" , int "offset" , string "mode" , int "x" , int "y" )
{
	offset = Default( offset , 0 )
	mode = Default( mode , "Blend" )
	end_frame = Default( end_frame , 0 )
	x = Default( x , 0 )
	y = Default( y , 0 )
	start_frame = Default( start_frame , 0 )
	overlay_frame = SIGN_FRAME
	assert( defined( c ) , "You must have a working video clip to be overlayed" )
	end_frame = SIGN_OVERLAY.isclip ? ( ( end_frame > 0 ) ? end_frame : start_frame + SIGN_OVERLAY.framecount - 1 - SIGN_FRAME ) : end_frame
	start_frame = SIGN_OVERLAY.isclip ? ( ( start_frame >= 0 ) ? start_frame : end_frame - SIGN_OVERLAY.framecount + 1 + SIGN_FRAME ) : start_frame
	assert( start_frame <= end_frame , "Starting Frame (" + string( start_frame ) + ") must be smaller than or equal to Ending Frame (" + string( end_frame ) + ")!" )
	assert( ( start_frame >= 0 ) && ( end_frame >= 0 ) , "Starting (" + string( start_frame ) + ") and Ending Frame (" + string( end_frame ) + ") must not be smaller than 0" )
	assert( end_frame < c.framecount , "The number of frames being overlayed must not be bigger than the number of frames in the clip you're overlaying on (end frame = " + String( end_frame ) + ")" )
	o = SIGN_OVERLAY.isclip() ? SIGN_OVERLAY.assumefps( c ).trim( overlay_frame + offset , overlay_frame + end_frame - start_frame ) : ""
	global SIGN_FRAME = SIGN_FRAME + end_frame - start_frame + 1
	start_frame = start_frame + offset
	sign_overlays = lcase( mode ) == "splice" ? o : ( SIGN_OVERLAY.isclip() ? c.trim( start_frame , end_frame ).overlay( o , x , y , o.showalpha , mode=mode ) : "" )
	return \
		SIGN_OVERLAY.isclip() ? \
		   ( start_frame > 0 ? \
			( end_frame < c.framecount( ) - 1 ? \
			c.trim( 0 , -start_frame ) ++ sign_overlays ++ c.trim( end_frame + 1 , 0 ) : \
			c.trim( 0 , -start_frame ) ++ sign_overlays ) : \
			( end_frame < c.framecount( ) - 1 ? \
			sign_overlays ++ c.trim( end_frame + 1 , 0 ) : \
			sign_overlays ) \
		   ) : c.trim( start_frame , end_frame )
}

function aviSign( clip c , string "filename" , bool "rescale" , string "alpha_file" , string "colorspace" )
{
	rescale = Default( rescale , false )
	colorspace = Default( colorspace , "" )
	colorspace = UCase( colorspace )
	alpha_file = Default( alpha_file , "" )
	v = avisource( filename ).converttorgb32
	global SIGN_FRAME = 0
	global SIGN_OVERLAY = rescale ? ( ( alpha_file != "" ) ? mergeargb( avisource( alpha_file ) , v.showred , v.showgreen , v.showblue ) : v ).assumefps( c ).lanczos4resize( c.width , c.height ) : ( ( alpha_file != "" ) ? mergeargb( avisource( alpha_file ) , v.showred , v.showgreen , v.showblue ) : v ).assumefps( c )
	global SIGN_OVERLAY = colorspace == "YV12" ? SIGN_OVERLAY.converttoyv12( ) : ( colorspace == "YUY2" ? SIGN_OVERLAY.converttoyuy2( ) : ( colorspace == "RGB" ? SIGN_OVERLAY.converttorgb( ) : ( colorspace == "RGB24" ? SIGN_OVERLAY.converttorgb24( ) : ( colorspace == "RGB32" ? SIGN_OVERLAY.converttorgb32( ) : SIGN_OVERLAY ) ) ) ) 
	return c 
}

function imgSign( clip c , string "filename" , bool "rescale" , string "alpha_file" , string "colorspace" )
{
	rescale = Default( rescale , false )
	colorspace = Default( colorspace , "" )
	colorspace = UCase( colorspace )
	alpha_file = Default( alpha_file , "" )
	v = imagesource( file=filename , start=0 , end=c.framecount - 1 , use_devil = true , pixel_type="RGB32" ).converttorgb32
	global SIGN_FRAME = 0
	global SIGN_OVERLAY = rescale ? ( ( alpha_file != "" ) ? mergeargb( imagesource( file=alpha_file , start=0 , end=c.framecount - 1 , use_devil = true ) , v.showred , v.showgreen , v.showblue ) : v ).lanczos4resize( c.width , c.height ) : ( ( alpha_file != "" ) ? mergeargb( imagesource( file=alpha_file , start=0 , end=c.framecount - 1 , use_devil = true ) , v.showred , v.showgreen , v.showblue ) : v )
	global SIGN_OVERLAY = colorspace == "YV12" ? SIGN_OVERLAY.converttoyv12( ) : ( colorspace == "YUY2" ? SIGN_OVERLAY.converttoyuy2( ) : ( colorspace == "RGB" ? SIGN_OVERLAY.converttorgb( ) : ( colorspace == "RGB24" ? SIGN_OVERLAY.converttorgb24( ) : ( colorspace == "RGB32" ? SIGN_OVERLAY.converttorgb32( ) : SIGN_OVERLAY ) ) ) ) 
	return c 
}
