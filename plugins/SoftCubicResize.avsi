#######################################################
### SoftCubic Resize from madVR                     ###
### Scripted by 06_taro (astrataro@gmail.com)       ###
#######################################################

Function SoftCubicResize(clip input, int "target_width", int "target_height", float "src_left", float "src_top", float "src_width", float "src_height", int "soft"){
  
  target_width  = Default( target_width,   width(input) )
  target_height = Default( target_height, height(input) )
  src_left      = Default( src_left,                  0 )
  src_top       = Default( src_top,                   0 )
  src_width     = Default( src_width,                 0 )
  src_height    = Default( src_height,                0 )
  soft          = Default( soft,                    100 )
  
  b = soft / 100.0
  c = 1.0 - b
  
  return input.BicubicResize(target_width, target_height, src_left=src_left, src_top=src_top, src_width=src_width, src_height=src_height, b=b, c=c)
  
}
