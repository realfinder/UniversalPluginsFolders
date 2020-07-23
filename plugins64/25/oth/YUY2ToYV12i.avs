function YUY2ToYV12i(clip c) {
  f = c.AssumeTFF().SeparateFields()
  top = f.SelectEven()
  bot = f.SelectOdd()
  topU = top.UToY().BilinearResize(c.width/2, c.height/4, 0, -0.25)
  botU = bot.UToY().BilinearResize(c.width/2, c.height/4, 0, 0.25)
  U = Interleave(topU, botU).ConvertToYV12()
  topV = top.VToY().BilinearResize(c.width/2, c.height/4, 0, -0.25)
  botV = bot.VToY().BilinearResize(c.width/2, c.height/4, 0, 0.25)
  V = Interleave(topV, botV).ConvertToYV12()
  YToUV(U, V, f.ConvertToYV12()).Weave()
}