function insertsignYV(clip mainclip, clip overlayclip, int startframe, int "endframe") {
endframe = default(endframe,startframe+overlayclip.framecount()-1)
endframe = (endframe == 0) ? startframe+overlayclip.framecount()-1 : endframe
endframe = (endframe >= mainclip.framecount()-1) ? mainclip.framecount()-1 : endframe

begin = (startframe == 1) ? mainclip.trim(0,-1) : mainclip.trim(0,startframe-1)
middle = mainclip.trim(startframe,endframe)
end = (endframe == mainclip.framecount()-1) ? blankclip(mainclip,length=0) : mainclip.trim(endframe+1,0)

middleoverlay = Overlay(middle, overlayclip,opacity=1)

final = (startframe == 0) ? middleoverlay ++ end : begin ++ middleoverlay ++ end
return final
}