function YV12ToYUY2imod(clip c) {
  f = c.AssumeTFF().SeparateFields().SelectEvery(4, 0, 3)
  top = f.SelectEven()
  bot = f.SelectOdd()
  topU = top.UToY().BilinearResize(c.width/2, c.height/2, 0, 0.125)
  botU = bot.UToY().BilinearResize(c.width/2, c.height/2, 0, -0.125)
  U = Interleave(topU, botU).ConvertToYUY2()
  topV = top.VToY().BilinearResize(c.width/2, c.height/2, 0, 0.125)
  botV = bot.VToY().BilinearResize(c.width/2, c.height/2, 0, -0.125)
  V = Interleave(topV, botV).ConvertToYUY2()
  YToUV(U, V, f.ConvertToYUY2()).Weave() #crashes on v2.60
}

