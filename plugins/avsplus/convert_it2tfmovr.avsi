# Convert IT() log entries to TFM() overrides format cleanly
# Accepts a source clip, reads its bounds, and clips extra out-of-range frames
# Dependencies: AviSynth+ Native Loops and RT_Stats
# original .bat code by Ikotas, this function by r.f with some help of google neural network
# 1.01

function ConvertIT2TFMOvr(clip c, string inputFile, string "outputFile")
{
    outStr = Default(outputFile, LeftStr(inputFile, FindStr(inputFile, ".") - 1) + "_it.tfmovr")
    
    Assert(Exist(inputFile), "ConvertIT2TFMOvr: Input file not found: " + inputFile)
    
    # Get the maximum valid frame index allowed for this video clip
    maxValidFrame = FrameCount(c) - 1
    
    # Initialize and clear the final destination override mapping file safely
    RT_WriteFile(outStr, "%s", "", append=false)
    
    # Read the full dataset into memory safely as a single text block
    fileData = RT_ReadTxtFromFile(inputFile)
    totalLines = RT_TxtQueryLines(fileData)
    
    # Native AviSynth+ compile-time loop implementation
    for (idx = 0, totalLines - 1) 
    {
        currentLine = RT_TxtGetLine(fileData, idx)
        
        # Standardize carriage returns and drop irregular tabulations inside memory
        currentLine = RT_StrReplace(currentLine, Chr(13), "")
        currentLine = RT_StrReplace(currentLine, Chr(10), "")
        currentLine = RT_StrReplace(currentLine, Chr(9), " ")
        
        # Clean and merge variable whitespace padding structures lineally
        cleanedLine = RT_StrReplace(currentLine, "      ", " ")
        cleanedLine = RT_StrReplace(cleanedLine, "     ", " ")
        cleanedLine = RT_StrReplace(cleanedLine, "    ", " ")
        cleanedLine = RT_StrReplace(cleanedLine, "   ", " ")
        cleanedLine = RT_StrReplace(cleanedLine, "  ", " ")
        cleanedLine = (LeftStr(cleanedLine, 1) == " ") ? MidStr(cleanedLine, 2) : cleanedLine
        
        spacePos = FindStr(cleanedLine, " ")
        hasValidTokens = (spacePos > 1) && (StrLen(cleanedLine) > spacePos)
        
        if (hasValidTokens) 
        {
            baseStr = LeftStr(cleanedLine, spacePos - 1)
            rawPat  = MidStr(cleanedLine, spacePos + 1)
            
            # Isolate the exact 5-character string pattern block layout cleanly
            patternBlock = LeftStr(rawPat, 5)
            baseFrame = Int(Value(baseStr))
            
            # Unroll the 5 frame offsets lineally inside the active compile block loop
            for (offset = 0, 4) 
            {
                frameIndex = baseFrame + offset
                
                # Check if the current calculated frame index falls within the clip range bounds
                # If the frame index is valid, it proceeds to evaluate and print it
                if (frameIndex <= maxValidFrame) 
                {
                    charState = MidStr(patternBlock, offset + 1, 1)
                    
                    # Precise case-insensitive flag validation mapping pass
                    isP = (charState == "p") || (charState == "P")
                    finalFlag = isP ? "p" : "c"
                    
                    # Append standard integer frame records directly to the file stream
                    RT_WriteFile(outStr, "%d %s", frameIndex, finalFlag, append=true)
                }
            }
        }
    }
    
    # Return the source clip completely untouched to maintain pipleline structure
    return c
}
