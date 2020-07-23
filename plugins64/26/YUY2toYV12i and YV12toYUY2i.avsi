# interlaced YV12<->YUY2 fixed Conversions functions for avs 2.6

function YUY2ToYV12i_26(clip c, bool "bic") {
Assert(Isyuy2(c), "YUY2ToYV12i_26: input clip must be yuy2")
  bic    = default(bic, true)
  sourcford = c.getparity() ? 1 : 0
  f = c.SeparateFields()
  top = sourcford == 1 ? f.SelectEven() : f.SelectOdd()
  bot = sourcford == 1 ? f.SelectOdd() : f.SelectEven()
  topUV = bic ? Interleave(top.UToY8(), top.VToY8()).BicubicResize(c.width/2, c.height/4, src_top=-0.25) : \
Interleave(top.UToY8(), top.VToY8()).BilinearResize(c.width/2, c.height/4, src_top=-0.25)
  botUV = bic ? Interleave(bot.UToY8(), bot.VToY8()).BicubicResize(c.width/2, c.height/4, src_top=0.25) : \
Interleave(bot.UToY8(), bot.VToY8()).BilinearResize(c.width/2, c.height/4, src_top=0.25)
  U = sourcford == 1 ? Interleave(topUV.SelectEven(), botUV.SelectEven()) : Interleave(botUV.SelectEven(), topUV.SelectEven())
  V = sourcford == 1 ? Interleave(topUV.SelectOdd(), botUV.SelectOdd()) : Interleave(botUV.SelectOdd(), topUV.SelectOdd())
  YToUV(U, V, f.ConvertToY8()).Weave()
}


function YV12ToYUY2i_26(clip c, bool "bic") {
Assert(Isyv12(c), "YV12ToYUY2i_26: input clip must be yv12")
  bic    = default(bic, true)
  sourcford = c.getparity() ? 1 : 0
  f = c.SeparateFields()
  top = sourcford == 1 ? f.SelectEven() : f.SelectOdd()
  bot = sourcford == 1 ? f.SelectOdd() : f.SelectEven()
  topUV = bic ? Interleave(top.UToY8(), top.VToY8()).BicubicResize(c.width/2, c.height/2, src_top=0.125) : \
Interleave(top.UToY8(), top.VToY8()).BilinearResize(c.width/2, c.height/2, src_top=0.125) 
  botUV = bic ? Interleave(bot.UToY8(), bot.VToY8()).BicubicResize(c.width/2, c.height/2, src_top=-0.125) : \
Interleave(bot.UToY8(), bot.VToY8()).BilinearResize(c.width/2, c.height/2, src_top=-0.125)
  U = sourcford == 1 ? Interleave(topUV.SelectEven(), botUV.SelectEven()) : Interleave(botUV.SelectEven(), topUV.SelectEven())
  V = sourcford == 1 ? Interleave(topUV.SelectOdd(), botUV.SelectOdd()) : Interleave(botUV.SelectOdd(), topUV.SelectOdd())
  YToUV(U, V, f).ConvertToYUY2().Weave()
}

