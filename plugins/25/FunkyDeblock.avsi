function gauss (clip c,int "radius") {

radius=default(radius,1)

radius=radius*4
c.bilinearresize(4*(c.width/radius),4*(c.height/radius)).bicubicresize(c.width,c.height,1,0)

}

function funkydeblock (clip c,int "quant",int "th",int "radius", bool "deblock",bool "depump"){

quant=default(quant,4)
th=default(th,3)
radius=default(radius,4)
deblock=default(deblock,true)
depump=default(depump,true)

blurd = c.gauss(4)

highpass=subtract(blurd,c)
deblocked=(deblock==true) ? highpass.blindpp(quant=floor(quant),cpu=4) : highpass

nopump=subtract(blurd,deblocked)
pump=subtract(blurd.temporalsoften(radius,th,th,2*th,2),deblocked)

(depump==true) ? pump : nopump

}