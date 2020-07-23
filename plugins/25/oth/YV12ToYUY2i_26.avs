function YV12ToYUY2i_26(clip c) {
  f = c.AssumeTFF().SeparateFields()
  top = f.SelectEven()
  bot = f.SelectOdd()
  topU = top.UToY8().BilinearResize(c.width/2, c.height/2, 0, 0.125)
  botU = bot.UToY8().BilinearResize(c.width/2, c.height/2, 0, -0.125)
  U = Interleave(topU, botU).ConvertToYV16()
  topV = top.VToY8().BilinearResize(c.width/2, c.height/2, 0, 0.125)
  botV = bot.VToY8().BilinearResize(c.width/2, c.height/2, 0, -0.125)
  V = Interleave(topV, botV).ConvertToYV16()
  YToUV(U, V, f.ConvertToYV16()).ConvertToYUY2().Weave()
}



