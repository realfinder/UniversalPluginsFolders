# Border processing fix for GrandFun by MugFunky and Alain2
# Edit by Soulhunter: Changed strength from int -> float

Function GradFunkMirror( clip c, float "strength" )
{
strength = default( strength, 1.2 )
w = c.width()
h = c.height()
vflip = c.FlipVertical()
hflip = c.FlipHorizontal()

stackhorizontal( hflip.crop( w-16, 0, 16, h ).addborders( 0, 16, 0, 16 ),
\ stackvertical( vflip.crop( 0, h-16, w, 16 ), c, vflip.crop( 0, 0, w, 16 ) ),
\ hflip.crop( 0, 0, 16, h ).addborders( 0, 16, 0, 16 ) )
gradfun2db( strength )
crop( 16, 16, -16, -16 )

Return last
}