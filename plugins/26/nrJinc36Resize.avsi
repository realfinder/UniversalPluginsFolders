Function nrJinc36Resize(clip input, int "target_width", int "target_height", float "src_left", float "src_top", float "src_width", float "src_height"){
  
  Assert( input.IsPlanar(), "nrJinc36Resize: only planar color spaces are supported!" )
  
  target_width  = Default( target_width,   width(input) )
  target_height = Default( target_height, height(input) )
  src_left      = Default( src_left,                  0 )
  src_top       = Default( src_top,                   0 )
  src_width     = Default( src_width,                 0 )
  src_height    = Default( src_height,                0 )
  
  return input.Jinc36Resize(target_width, target_height, src_left, src_top, src_width, src_height)
  \           .Repair(input.GaussResize(target_width, target_height, src_left, src_top, src_width, src_height, p=100), 1)
  
}