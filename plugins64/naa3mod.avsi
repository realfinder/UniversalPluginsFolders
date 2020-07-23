    FUNCTION naa3mod(Clip Clp,Bool "CP")
    {
    OX = Clp.Width()
    OY = Clp.Height()
    CP = Default(CP,True)
    Clp = Clp.IsYV12() ? Clp : Clp.ConvertToYV12()
    Clpnn1 = Clp.nnedi3(1, dh=true,U=CP,V=CP).nnedi3(0,U=CP,V=CP)
    Clpy1 = Clpnn1.Spline36Resize(OX,OY,0,-0.5,OX,OY*2)
    Clps1 = CP ? Clpy1.MergeChroma(Clpnn1.Spline36Resize(OX,OY,0,-1,OX,OY*2)) : Clpy1.MergeChroma(Clp)
    Clpnn2 = Clps1.turnright().nnedi3(1, dh=true,U=CP,V=CP).nnedi3(0,U=CP,V=CP)
    Clpy2 = Clpnn2.Spline36Resize(OY,OX,0,-0.5,OY,OX*2)
    CP ? Clpy2.MergeChroma(Clpnn2.Spline36Resize(OY,OX,0,-1,OY,OX*2)).turnleft() : Clpy2.turnleft().MergeChroma(Clp)
    Return(Last)
    }
