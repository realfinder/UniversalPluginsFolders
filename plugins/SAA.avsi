# _______________________________________________________
#
# SAA | Simple Antialiasing
# _______________________________________________________
#					
# Simplicity by Soulhunter... \m\ ^_^ /m/
# _______________________________________________________
#
#
# Requirements:
#
# SangNom.dll
# 100GHz CPU
#
#

Function SAA(Clip Clp,Int"SS",Bool"CP")
{

OX = Clp.Width
OY = Clp.Height
SS = Default(SS,2)
CP = Default(CP,True)


Clp = Clp.IsYV12() ? Clp : Clp.ConvertToYV12()

Clp.PointResize(OX*SS,OY*SS).SangNom().TurnRight()
\  .SangNom().TurnLeft().BilinearResize(OX,OY)

CP ? Last : MergeChroma(Clp)

Return(Last)

}