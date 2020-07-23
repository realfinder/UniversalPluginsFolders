####################################################################################
# ConvertHybridToXXX() This allows format conversions for DVDs that contain a      #
#                       mix of both Progressive and Interlaced encoded frames      #
####################################################################################


function ConvertHybridtoYUY2(clip a){

b=converttoYUY2(a,interlaced=false)
c=converttoYUY2(a,interlaced=true)
conditionalfilter(a,b,c,"IsCombedTIVTC()","equals","false")
}

function ConvertHybridtoRGB32(clip a){

b=converttoRGB32(a,interlaced=false)
c=converttoRGB32(a,interlaced=true)
conditionalfilter(a,b,c,"IsCombedTIVTC()","equals","false")
}

function ConvertHybridtoRGB24(clip a){

b=converttoRGB24(a,interlaced=false)
c=converttoRGB24(a,interlaced=true)
conditionalfilter(a,b,c,"IsCombedTIVTC()","equals","false")

}

##############################################################
#    Allows you to Check the Field Order of your Source.     #
# Use frame advance in virtualdub to check for smooth motion #
##############################################################

function CheckFieldOrder(clip c) {
sourcevideo=c
TFF=sourcevideo.AssumeTFF().SeparateFields().subtitle("Top Field First, if motion is smooth use order=1")
BFF=sourcevideo.AssumeBFF().SeparateFields().subtitle("Bottom Field First, if motion is smooth use order=0")
StackVertical(TFF,BFF)
}

###########################################
# ADTelecine 23.976, 24 or 25fps to 29.97 #
###########################################

function ADTelecine(clip a, int "order") {

order = Default(order, 1)

a = a.ChangeFPS(60)
a = (order==1) ? a.AssumeTFF() : a
a.SeparateFields().SelectEvery(4,0,3).Weave()
}


############################################################################################
# ADSwapFieldOrder         Changes TFF to BFF and vice versa by adding and removing a line #
# ADSwapHybridFieldOrder   Same but for Hybrid clips                                       #
############################################################################################

function ADSwapFieldOrder(clip c) {

isYV12(c) ? converttoYUY2(c,interlaced=true).crop(0,1,-0,-0).addborders(0,0,0,1).converttoYV12() : crop(c,0,1,-0,-0).addborders(0,0,0,1)
}

function ADSwapHybridFieldOrder(clip new) {

a=ConvertHybridtoYUY2(new)
isYV12(new) ? stackvertical(a.crop(0,1,-0,-0),a.crop(0,Height(a)-1,-0,-0)).converttoYV12() : stackvertical(new.crop(0,1,-0,-0),new.crop(0,Height(new)-1,-0,-0))

}

###############################################################################################
# ADBlackBumper(start,end,frames)   Adds a certain amount of seconds to the start or end      #
#                                   of the video. If frames=true uses frames not seconds      #
###############################################################################################

function ADBlackBumper(clip c, int "start",int "endy",bool "frames") {

frames = Default(frames, false)
start = (frames==false) ? Default(start, 5) : Default(start, 150)
endy = (frames==false) ? Default(endy, 5) : Default(endy, 150)
fps=Round(framerate(c))

startpadding = (frames==false) ? Blankclip(c,length=(fps*start)): Blankclip(c,length=(start)) 
endpadding = (frames==false) ? Blankclip(c,length=(fps*endy)) : Blankclip(c,length=(endy)) 

startpadding+c+endpadding
}

##################################################################
# BeforeAfter by Absolute Destiny and Corran                     #
#   e.g.                                                         #
# beforeafter(clip, placement, filters)  or                      #
#                                                                #
# beforeafterline(clip, placement,filters) for a lined split     #
#                                                                #
# 1 for vertical splitscreen, 0 for horizontal splitscreen       #
#                                                                #
# Does not work on filters that use strings like deen("a3d",1)   #
##################################################################

function beforeafter(clip a, int "placement", string "filters"){

placement = default(placement, 1)

Assert((float(width(a))/16)==round(width(a)/16), "Source image width must be a multiple of 16")

b=Eval("a."+filters)
c = (placement==1) ? stackhorizontal(a.crop(0,0,-((ceil(float(width(a))/32))*16),0).subtitle("before"),b.crop(((floor(float(width(a))/32))*16),0,0,0).subtitle("after")) :Stackvertical(a.crop(0,0,0,-height(a)/2).subtitle("Before"),b.crop(0,height(a)/2,0,0).subtitle("After"))

return c
}

function beforeafterline(clip a, int "placement", string "filters"){ 
  
 placement = default(placement, 1) 
  
 Assert((float(width(a))/16)==round(width(a)/16), "Source image width must be a multiple of 16") 
  
 b=Eval("a."+filters) 
 c = (placement==1) ? stackhorizontal(a.crop(0,0,-((ceil(float(width(a))/32))*16),0).subtitle("before"),b.crop(((floor(float(width(a))/32))*16),0,0,0).subtitle("after")) :Stackvertical(a.crop(0,0,0,-height(a)/2).subtitle("Before"),b.crop(0,height(a)/2,0,0).subtitle("After")) 
 line = (placement!=1) ? blankclip(a,color=$FFFFFF).crop(0,0,(width(a)),4) : blankclip(a,color=$FFFFFF).crop(0,0,4,(height(a))) 
 d = (placement==1) ? overlay(c,line,x=width(a)-((ceil(float(width(a))/32))*16)-2) : overlay(c,line,y=height(a)-((floor(float(height(a))/32))*16)-2) 
  
 return d 
 } 

##################################################################
# zWarpSharp by Zarxrax                                          #
#   aWarpSharp contains a bug in which green junk will appear    #
#   on the sides of the video. This function simply works around #
#   the problem by adding borders, doing the warpsharp, and then #
#   cropping the boarders back off. It is used just as           #
#   aWarpSharp is normally used                                  #
##################################################################

function zWarpSharp(clip a, float "depth", int "blurlevel", float "thresh", int "cm"){
  depth = Default(depth, 16)
  blurlevel = Default(blurlevel, 2)
  thresh = Default(thresh, 0.5)
  cm = Default(cm, 2)
  a = a.AddBorders(8,8,8,8)
  a = a.FillMargins(8,8,8,8)
  a = a.aWarpSharp(depth,blurlevel,thresh,cm)
  a = a.Crop(8,8,-8,-8)
  return a
}