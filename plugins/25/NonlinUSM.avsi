function NonlinUSM(clip o, float "z", float "pow", float "str", float "rad", float "ldmp")
{
z   = default(z,   6.0)  # zero point
pow = default(pow, 1.6)  # power
str = default(str, 1.0)  # strength
rad = default(rad, 9.0)  # radius for "gauss"
ldmp= default(ldmp, 0.001) # damping for verysmall differences

g = o.bicubicresize(round(o.width()/rad/4)*4,round(o.height()/rad/4)*4).bicubicresize(o.width(),o.height(),1,0)

mt_lutxy(o,g,"x x y - abs "+string(z)+" / 1 "+string(pow)+" / ^ "+string(z)+" * "+string(str)+
 \                        " * x y - 2 ^ x y - 2 ^ "+string(ldmp)+" + / * x y - x y - abs 0.001 + / * +",U=2,V=2)

#interleave(o,last) # just for visualisation, you don't want the function to do this

return(last)
}