###########################################################################################################
### Fast SeparateResize as madVR                                                                        ###
### Requires Repair if nr=true: http://home.arcor.de/kassandro/prerelease/RemoveGrain-1.0.rar           ###
### madSpline requires SplineResize if taps=1 or taps>4: http://forum.doom9.org/showthread.php?t=147117 ###
### Scripted by 06_taro (astrataro@gmail.com)                                                           ###
###########################################################################################################

Function madSpline(clip input, int "target_width", int "target_height", float "src_left", float "src_top", float "src_width", float "src_height", int "taps", int "soft", bool "nr"){

  target_width  = Default( target_width,   width(input) )
  target_height = Default( target_height, height(input) )
  src_left      = Default( src_left,                  0 )
  src_top       = Default( src_top,                   0 )
  src_width     = Default( src_width,                 0 )
  src_height    = Default( src_height,                0 )
  taps          = Default( taps,                      4 )
  soft          = Default( soft,                    100 )
  nr            = Default( nr,                     true )

  Assert( taps>=1 && taps<=100, """madSpline: "taps" ranges from 2 to 4!"""                      )
  Assert( input.IsYV12,         "madSpline: cannot handle non-YV12, use SeparateResize instead!" )

  b             = soft / 100.0
  c             = 1.0 - b

  taps >=2 && taps <=4 ? Eval( "input.Spline"+String( taps*taps*4 )+"Resize("
  \                            +String(target_width)+", "+String(target_height)
  \                            +", src_left="+String(src_left)+", src_top="+String(src_top)
  \                            +", src_width="+String(src_width)+", src_height="+String(src_height)+")" )
  \                    : input.SplineResize( target_width, target_height,
  \                                          src_left=src_left, src_top=src_top, src_width=src_width, src_height=src_height, taps=taps )

  nr ? Repair( input.GaussResize( target_width, target_height, src_left, src_top, src_width, src_height, p=100 ), 1) : nop()

  return MergeChroma( input.BicubicResize( target_width, target_height,
  \                                        src_left=src_left, src_top=src_top, src_width=src_width, src_height=src_height,
  \                                        b=b, c=c ) )

}

Function madLanczos(clip input, int "target_width", int "target_height", float "src_left", float "src_top", float "src_width", float "src_height", int "taps", int "soft", bool "nr"){

  target_width  = Default( target_width,   width(input) )
  target_height = Default( target_height, height(input) )
  src_left      = Default( src_left,                  0 )
  src_top       = Default( src_top,                   0 )
  src_width     = Default( src_width,                 0 )
  src_height    = Default( src_height,                0 )
  taps          = Default( taps,                      4 )
  soft          = Default( soft,                    100 )
  nr            = Default( nr,                     true )

  b             = soft / 100.0
  c             = 1.0 - b

  Assert( taps>=1 && taps<=100, """madLanczos: "taps" ranges from 2 to 4!"""                      )
  Assert( input.IsYV12,         "madLanczos: cannot handle non-YV12, use SeparateResize instead!" )

  return nr ? MergeChroma( input.LanczosResize( target_width, target_height,
  \                                             src_left=src_left, src_top=src_top, src_width=src_width, src_height=src_height, taps=taps )
  \                             .Repair( input.GaussResize( target_width, target_height, src_left, src_top, src_width, src_height, p=100 ), 1),
  \                        input.BicubicResize( target_width, target_height,
  \                                             src_left=src_left, src_top=src_top, src_width=src_width, src_height=src_height, b=b, c=c ) )
  \         : MergeChroma( input.LanczosResize( target_width, target_height,
  \                                             src_left=src_left, src_top=src_top, src_width=src_width, src_height=src_height, taps=taps ),
  \                        input.BicubicResize( target_width, target_height,
  \                                             src_left=src_left, src_top=src_top, src_width=src_width, src_height=src_height, b=b, c=c ) )

}
