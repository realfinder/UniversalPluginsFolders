# Dupped() by Corran.  Feel free to modify as you see fit. 
# Attribution not required.
#
# This filter requires a YUV source. Use converttoyv12 if needed
# before calling dupped()
#
## Parameters
# thresh = Used to determine when to delare a frame as new
# Use stats=true to help determine the best value for your source
# Lower number = more sensitive. (Default=16)
#
# panthresh=1.7 This is used to determine when to consider a frame
# part of a low motion scene. (Default=1.65)
#
# stats = Enable/disable display of stats. (Default=false | Not shown)
# (Last = last frame, this = this frame, next = next frame)
#
# showme = Enable/disable display of video that most stats are
# derived from. (Default=false | Not shown)
#
## Notes
# Do not use with SetMTMode(). This function requires the frames to be
# accessed sequentially. Instead, use MT() to mulit-thread on a per-filter basis.
#
# Example:
# dupped(thresh=20,panthresh=1.7,stats=true,showme=true) 

#Function to return the requested frame
function getFrame(clip c, int frameNum)
{
    default(c, last)
    finalframe = c.frameCount-1
    
    Assert(frameNum >= 0, "GetFrame(): FrameNumber supplied is less than 0.")
    Assert(frameNum < finalframe, "GetFrame(): FrameNumber supplied is larger than video's framecount.")
    
    c = trim(frameNum,frameNum)
    return c
}

function dupped(clip c, int "thresh", float "panThresh", bool "stats", bool "showme")
{
    default(c, last)
    global dupThresh = default(thresh, 16)
    global panThresh = default(panThresh, 1.65)
    global dupStats = default(stats, false)
    showme = default(showme, false)
    a = c
    c = scriptclip(last,"""
        c = last
    
        finalframe = c.framecount-1
        prev_frame = current_frame != 0 ? current_frame-1 : 0
        next_frame = current_frame != finalframe ? current_frame+1 : finalframe
            
        #Get Y related stats as needed
        prevCurrentYMinMax = subtract(getframe(prev_frame),c).YPlaneMinMaxDifference
        currentNextYMinMax = prevCurrentYMinMax < dupThresh ? subtract(c,getframe(next_frame)).YPlaneMinMaxDifference : 256
        prevNextYMinMax = currentNextYMinMax < dupThresh ? subtract(getframe(prev_frame),getframe(next_frame)).YPlaneMinMaxDifference : 0
    
        #calculate dynamic pan threshold.   Set to 256 if looking for a pan is pointless
        neighborAvgMinMax = (prevCurrentYMinMax + currentNextYMinMax) / 2
        dynPanThresh = prevNextYMinMax != 0 ? Abs(neighborAvgMinMax * panthresh) : 256

        #determine if the current frame is new
        newframe = prevCurrentYMinMax >= dupThresh || prevNextYMinMax >= dynPanThresh ? true : false
        lastNewFrame = newframe ? current_frame : lastNewFrame
    
        c = getFrame(lastNewFrame)
        c = dupStats ? c.subtitle("prevframe: "+string(prev_frame)+"  currentframe: "+string(current_frame)+"  nextframe: "+string(next_frame)) : c
        c = dupStats ? c.subtitle("Last new frame: "+string(lastNewFrame)+" Newframe: "+string(newframe),y=15) : c
        c = dupStats ? c.subtitle("prevCurrentYMinMax: "+string(prevCurrentYMinMax)+" (Threshold:"+string(dupThresh)+")",y=45) : c
        c = dupStats && currentNextYMinMax != 256 ? c.subtitle("currentNextYMinMax: "+string(currentNextYMinMax),y=60) : c
        c = dupStats && prevNextYMinMax >= dynPanThresh ? c.subtitle("prevNextYMinMax: "+string(prevNextYMinMax),y=90) : c
        c = dupStats && prevNextYMinMax >= dynPanThresh ? c.subtitle("Pan Threshold: "+string(dynPanThresh)+" ("+string(neighborAvgMinMax)+" * "+string(panThresh)+")",y=105) : c
        c = dupStats && prevNextYMinMax >= dynPanThresh ? c.subtitle("Slow pan detected",y=120) : c

        return c
    """)
    c = showme ? stackvertical(c,subtract(a.duplicateframe(0),a)) : c
    
    return c
}