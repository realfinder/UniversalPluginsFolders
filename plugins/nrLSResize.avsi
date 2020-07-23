###################################################################################################
### Non-ringing Lanczos/Spline Resize                                                           ###
### Algorithm is here: http://forum.doom9.org/showthread.php?t=145358                           ###
### Requires Repair: http://home.arcor.de/kassandro/prerelease/RemoveGrain-1.0.rar              ###
### nrSplineResize, nrSpline100Resize and nrSpline144Resize                                     ###
###   requires SplineResize if taps=1 or taps>4: http://forum.doom9.org/showthread.php?t=147117 ###
### Written by Didée, scripted by 06_taro (astrataro@gmail.com)                                 ###
###################################################################################################

Function nrLanczosResize(clip input, int "target_width", int "target_height", float "src_left", float "src_top", float "src_width", float "src_height", int "taps"){

  Assert( input.IsYV12(), "nrLanczosResize: only YV12 is supported, use SeparateResize instead!" )

  target_width  = Default( target_width,   width(input) )
  target_height = Default( target_height, height(input) )
  src_left      = Default( src_left,                  0 )
  src_top       = Default( src_top,                   0 )
  src_width     = Default( src_width,                 0 )
  src_height    = Default( src_height,                0 )
  taps          = Default( taps,                      3 )

  Assert( taps>=1 && taps<=100,    """nrLanczosResize: "taps" ranges from 1 to 100!""" )

  return input.LanczosResize(target_width, target_height, src_left, src_top, src_width, src_height, taps)
  \           .Repair(input.GaussResize(target_width, target_height, src_left, src_top, src_width, src_height, p=100), 1)

}

Function nrLanczos4Resize(clip input, int "target_width", int "target_height", float "src_left", float "src_top", float "src_width", float "src_height"){

  Assert( input.IsYV12(), "nrLanczos4Resize: only YV12 is supported, use SeparateResize instead!" )

  target_width  = Default( target_width,   width(input) )
  target_height = Default( target_height, height(input) )
  src_left      = Default( src_left,                  0 )
  src_top       = Default( src_top,                   0 )
  src_width     = Default( src_width,                 0 )
  src_height    = Default( src_height,                0 )

  return input.Lanczos4Resize(target_width, target_height, src_left, src_top, src_width, src_height)
  \           .Repair(input.GaussResize(target_width, target_height, src_left, src_top, src_width, src_height, p=100), 1)

}

Function nrSpline16Resize(clip input, int "target_width", int "target_height", float "src_left", float "src_top", float "src_width", float "src_height"){

  Assert( input.IsYV12(), "nrSpline16Resize: only YV12 is supported, use SeparateResize instead!" )

  target_width  = Default( target_width,   width(input) )
  target_height = Default( target_height, height(input) )
  src_left      = Default( src_left,                  0 )
  src_top       = Default( src_top,                   0 )
  src_width     = Default( src_width,                 0 )
  src_height    = Default( src_height,                0 )

  return input.Spline16Resize(target_width, target_height, src_left, src_top, src_width, src_height)
  \           .Repair(input.GaussResize(target_width, target_height, src_left, src_top, src_width, src_height, p=100), 1)

}

Function nrSpline36Resize(clip input, int "target_width", int "target_height", float "src_left", float "src_top", float "src_width", float "src_height"){

  Assert( input.IsYV12(), "nrSpline36Resize: only YV12 is supported, use SeparateResize instead!" )

  target_width  = Default( target_width,   width(input) )
  target_height = Default( target_height, height(input) )
  src_left      = Default( src_left,                  0 )
  src_top       = Default( src_top,                   0 )
  src_width     = Default( src_width,                 0 )
  src_height    = Default( src_height,                0 )

  return input.Spline36Resize(target_width, target_height, src_left, src_top, src_width, src_height)
  \           .Repair(input.GaussResize(target_width, target_height, src_left, src_top, src_width, src_height, p=100), 1)

}

Function nrSpline64Resize(clip input, int "target_width", int "target_height", float "src_left", float "src_top", float "src_width", float "src_height"){

  Assert( input.IsYV12(), "nrSpline64Resize: only YV12 is supported, use SeparateResize instead!" )

  target_width  = Default( target_width,   width(input) )
  target_height = Default( target_height, height(input) )
  src_left      = Default( src_left,                  0 )
  src_top       = Default( src_top,                   0 )
  src_width     = Default( src_width,                 0 )
  src_height    = Default( src_height,                0 )

  return input.Spline64Resize(target_width, target_height, src_left, src_top, src_width, src_height)
  \           .Repair(input.GaussResize(target_width, target_height, src_left, src_top, src_width, src_height, p=100), 1)

}

Function nrSpline100Resize(clip input, int "target_width", int "target_height", float "src_left", float "src_top", float "src_width", float "src_height"){

  Assert( input.IsYV12(), "nrSpline100Resize: only YV12 is supported, use SeparateResize instead!" )

  target_width  = Default( target_width,   width(input) )
  target_height = Default( target_height, height(input) )
  src_left      = Default( src_left,                  0 )
  src_top       = Default( src_top,                   0 )
  src_width     = Default( src_width,                 0 )
  src_height    = Default( src_height,                0 )

  return input.Spline100Resize(target_width, target_height, src_left, src_top, src_width, src_height)
  \           .Repair(input.GaussResize(target_width, target_height, src_left, src_top, src_width, src_height, p=100), 1)

}

Function nrSpline144Resize(clip input, int "target_width", int "target_height", float "src_left", float "src_top", float "src_width", float "src_height"){

  Assert( input.IsYV12(), "nrSpline144Resize: only YV12 is supported, use SeparateResize instead!" )

  target_width  = Default( target_width,   width(input) )
  target_height = Default( target_height, height(input) )
  src_left      = Default( src_left,                  0 )
  src_top       = Default( src_top,                   0 )
  src_width     = Default( src_width,                 0 )
  src_height    = Default( src_height,                0 )

  return input.Spline144Resize(target_width, target_height, src_left, src_top, src_width, src_height)
  \           .Repair(input.GaussResize(target_width, target_height, src_left, src_top, src_width, src_height, p=100), 1)

}

Function nrSplineResize(clip input, int "target_width", int "target_height", float "src_left", float "src_top", float "src_width", float "src_height", int "taps"){

  Assert( input.IsYV12(), "nrSplineResize: only YV12 is supported, use SeparateResize instead!" )

  target_width  = Default( target_width,   width(input) )
  target_height = Default( target_height, height(input) )
  src_left      = Default( src_left,                  0 )
  src_top       = Default( src_top,                   0 )
  src_width     = Default( src_width,                 0 )
  src_height    = Default( src_height,                0 )
  taps          = Default( taps,                      4 )

  Assert( taps>=1 && taps<=100,    """nrSplineResize: "taps" ranges from 1 to 100!""" )

  return input.SplineResize(target_width, target_height, taps, src_left, src_top, src_width, src_height)
  \           .Repair(input.GaussResize(target_width, target_height, src_left, src_top, src_width, src_height, p=100), 1)

}
