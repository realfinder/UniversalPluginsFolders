##########################################################################################
# AviSynth+ Add ~60fps to TIVTC VFR by Comb-Detection & Native Timecode Modifier
##########################################################################################

# by r.f with some help of google neural network
# Requires RT_Stats plugin and AviSynth+

# 1.01

function TIVTC_VFR_Add60fps(clip clip30, clip "clip60", string "tivtc_tcs", string "final_tcs", string "combed_log", int "pass", int "threshold")
{
    thresh     = Default(threshold, 10) # Comb detection sensitivity
    combed_log = Default(combed_log, "combed.txt")
    final_tcs  = Default(final_tcs, "final_timecodes.txt")
    
    if (pass == 1) 
    {
        # --------------------------------------------------------------------------------
        # PASS 1: Detect combed frames ONLY outside override lines
        # --------------------------------------------------------------------------------
        assert(Exist(tivtc_tcs), "TIVTC_VFR: TIVTC timecode file required for Pass 1 filtering!")
        
        tc_raw_string = RT_ReadTxtFromFile(tivtc_tcs, Lines=0, Start=0)
        condition = "last.IsCombedTIVTC(cthresh=thresh) && IsFrameIn30fpsZone(current_frame, tc_raw_string)"
        
        return clip30.WriteFileIf(combed_log, condition, "current_frame", append=false, args="thresh, tc_raw_string")
    }
    else if (pass == 2)
    {
        # --------------------------------------------------------------------------------
        # PASS 2: Reconstruct Timeline, Inject 60fps Clips, and Generate Final Timecodes
        # --------------------------------------------------------------------------------
        assert(Exist(combed_log), "TIVTC_VFR: Combed log file not found! Run Pass 1 first.")
        assert(Exist(tivtc_tcs), "TIVTC_VFR: TIVTC timecode file not found!")
        assert(Defined(clip60), "TIVTC_VFR: 'clip60' must be provided in Pass 2!")
        assert(round(framerate(clip60))==60, "TIVTC_VFR: clip60 need to be ~60 fps")
        
        tc_raw = RT_ReadTxtFromFile(tivtc_tcs, Lines=0, Start=0)
        log_raw = RT_ReadTxtFromFile(combed_log, Lines=0, Start=0)
        total_log_lines = RT_TxtQueryLines(log_raw)
        
        # Write Timecode V1 Header
        assume_line = RT_TxtGetLine(tc_raw, Line=1)
        assume_fps = Value(MidStr(assume_line, RT_FindStr(assume_line, "assume", sig=false) + 6))
        RT_WriteFile(final_tcs, "# timecode format v1\nAssume %f\n", assume_fps, Append=false)
        
        # If no combed frames were detected, just copy original timecodes and return clip30
        if (total_log_lines == 0 || log_raw == "") {
            RT_WriteFile(final_tcs, "%s", tc_raw, Append=false)
            return clip30
        }
        
        # Parse the combed log into continuous ranges string
        vfr_combed_trims = GenerateTrimStringFromLog(combed_log)
        
        final_clip = BlankClip(clip30, length=0)
        
        seg_start = 0
        seg_type  = IsFrameInsideParsedString(0, vfr_combed_trims)
        current_out_frame = 0  # Strict sequential timeline counter to block overlaps
        
        for (f = 1, clip30.FrameCount - 1) {
            curr_type = IsFrameInsideParsedString(f, vfr_combed_trims)
            
            if (curr_type != seg_type) {
                seg_end = f - 1
                
                # Process segment and write its timeline directly in linear order
                final_clip = ProcessSegmentLinear(final_clip, clip30, clip60, seg_start, seg_end, seg_type, tivtc_tcs, final_tcs, current_out_frame)
                
                # Update the baseline offset marker dynamically using physical framecount
                current_out_frame = final_clip.FrameCount
                
                seg_start = f
                seg_type = curr_type
            }
        }
        
        # Process last segment block
        seg_end = clip30.FrameCount - 1
        final_clip = ProcessSegmentLinear(final_clip, clip30, clip60, seg_start, seg_end, seg_type, tivtc_tcs, final_tcs, current_out_frame)
        
        return final_clip
    }
    else {
        Assert(false, "TIVTC_VFR: Parameter 'pass' must be either 1 or 2.")
    }
}


##########################################################################################
# Helper Functions
##########################################################################################

# --- Smart Helper Function evaluated at Runtime inside memory (From Pass 1) ---
function IsFrameIn30fpsZone(int f, string tc_raw) {
    total_lines = RT_TxtQueryLines(tc_raw)
    is_outside_overrides = true
    for (line_idx = 2, total_lines - 1) {
        line_str = RT_TxtGetLine(tc_raw, Line=line_idx)
        if (line_str != "" && RT_FindStr(line_str, "#", sig=false) == 0 && RT_FindStr(line_str, "vfr", sig=false) == 0) {
            c1 = RT_FindStr(line_str, ",", sig=false, pos=1)
            c2 = RT_FindStr(line_str, ",", sig=false, pos=c1+1)
            if (c1 > 0 && c2 > 0) {
                r_start = Int(Value(MidStr(line_str, 1, c1 - 1)))
                r_end   = Int(Value(MidStr(line_str, c1 + 1, c2 - (c1 + 1))))
                if (f >= r_start && f <= r_end) { is_outside_overrides = false }
            }
        }
    }
    return is_outside_overrides
}

# --- Linear Pass 2 Helper: Processes segments and outputs absolute sequential timecodes ---
function ProcessSegmentLinear(clip final_clip, clip c30, clip c60, int start, int end, int type, string tivtc_tcs, string final_tcs, int out_start) {
    if (type == 1) {
        # Calculate start and end millisecond markers from the source VFR file
        start_ms = GetTimeMsFromVFRFrame(start, tivtc_tcs)
        end_ms   = GetTimeMsFromVFRFrame(end, tivtc_tcs)
        
        c60_fps  = c60.FrameRate()
        start_60 = Round((start_ms / 1000.0) * c60_fps)
        end_60   = Round((end_ms / 1000.0) * c60_fps) + 1
        
        chunk = c60.Trim(start_60, end_60)
        chunk = chunk.AssumeFPS(c30.FrameRate())
        
        out_end = out_start + chunk.FrameCount - 1
        
        # Write the 60fps block using the sequential out tracking pointers
        RT_WriteFile(final_tcs, "%d,%d,59.940060\n", out_start, out_end, Append=true)
        final_clip = final_clip + chunk
    }
    else {
        chunk = c30.Trim(start, end)
        out_end = out_start + chunk.FrameCount - 1
        
        # Map existing 24fps properties inside this section using real-time linear calculations
        TransferOriginalOverridesLinear(start, end, tivtc_tcs, final_tcs, out_start)
        
        final_clip = final_clip + chunk
    }
    return final_clip
}

# --- Helper: Extracts original overrides within a range and writes them linearly ---
function TransferOriginalOverridesLinear(int start, int end, string tivtc_tcs, string final_tcs, int out_start) {
    tc_raw = RT_ReadTxtFromFile(tivtc_tcs, Lines=0, Start=0)
    total_lines = RT_TxtQueryLines(tc_raw)
    
    for (line_idx = 2, total_lines - 1) {
        line_str = RT_TxtGetLine(tc_raw, Line=line_idx)
        if (line_str != "" && RT_FindStr(line_str, "#", sig=false) == 0 && RT_FindStr(line_str, "vfr", sig=false) == 0) {
            c1 = RT_FindStr(line_str, ",", sig=false, pos=1)
            c2 = RT_FindStr(line_str, ",", sig=false, pos=c1+1)
            
            if (c1 > 0 && c2 > 0) {
                orig_start = Int(Value(MidStr(line_str, 1, c1 - 1)))
                orig_end   = Int(Value(MidStr(line_str, c1 + 1, c2 - (c1 + 1))))
                orig_fps   = Value(MidStr(line_str, c2 + 1))
                
                # Check if the original 24fps block overlaps with the current segment
                if (orig_start <= end && orig_end >= start) {
                    overlap_start = (orig_start < start) ? start : orig_start
                    overlap_end   = (orig_end > end) ? end : orig_end
                    
                    # Convert to new linear coordinates based on the output clip context
                    new_start = out_start + (overlap_start - start)
                    new_end   = out_start + (overlap_end - start)
                    
                    if (new_start <= new_end) {
                        RT_WriteFile(final_tcs, "%d,%d,%f\n", new_start, new_end, orig_fps, Append=true)
                    }
                }
            }
        }
    }
}

# --- Reconstructs consecutive ranges from Pass 1 Log File ---
function GenerateTrimStringFromLog(string log_file) {
    file_string = RT_ReadTxtFromFile(log_file, Lines=0, Start=0)
    total_lines = RT_TxtQueryLines(file_string)
    
    trim_str = ""
    start_frame = Int(Value(RT_TxtGetLine(file_string, Line=0)))
    prev_frame = start_frame
    
    for (i = 1, total_lines - 1) {
        curr_frame = Int(Value(RT_TxtGetLine(file_string, Line=i)))
        if (curr_frame != prev_frame + 1) {
            range_str = "Trim(" + String(start_frame) + ", " + String(prev_frame) + ")"
            trim_str = (trim_str == "") ? range_str : trim_str + " + " + range_str
            start_frame = curr_frame
        }
        prev_frame = curr_frame
    }
    range_str = "Trim(" + String(start_frame) + ", " + String(prev_frame) + ")"
    trim_str = (trim_str == "") ? range_str : trim_str + " + " + range_str
    return trim_str
}

# --- Helper Function: Replaces array search by parsing the range string directly ---
function IsFrameInsideParsedString(int f, string trim_str) {
    inside = 0
    search_pos = 1
    while (search_pos > 0) {
        start_idx = RT_FindStr(trim_str, "Trim(", sig=false, pos=search_pos)
        if (start_idx > 0) {
            comma_idx = RT_FindStr(trim_str, ",", sig=false, pos=start_idx)
            close_idx = RT_FindStr(trim_str, ")", sig=false, pos=comma_idx)
            
            vfr_start = Int(Value(MidStr(trim_str, start_idx + 5, comma_idx - (start_idx + 5))))
            vfr_end   = Int(Value(MidStr(trim_str, comma_idx + 1, close_idx - (comma_idx + 1))))
            
            if (f >= vfr_start && f <= vfr_end) {
                inside = 1
                search_pos = 0 # Break loop early
            } else {
                search_pos = close_idx + 1
            }
        } else { search_pos = 0 }
    }
    return inside
}

# --- Helper Function: Calculates absolute time (ms) for a specific frame in VFR ---
function GetTimeMsFromVFRFrame(int target_frame, string tivtc_tcs) {
    tc_raw = RT_ReadTxtFromFile(tivtc_tcs, Lines=0, Start=0)
    total_lines = RT_TxtQueryLines(tc_raw)
    
    # Read the default base FPS from the "Assume" line (Line 1)
    assume_line = RT_TxtGetLine(tc_raw, Line=1)
    base_fps = Value(MidStr(assume_line, RT_FindStr(assume_line, "assume", sig=false) + 6))
    
    current_frame = 0
    accumulated_time = 0.0 # in seconds
    
    # Parse through the VFR overrides to calculate time linearly
    for (line_idx = 2, total_lines - 1) {
        line_str = RT_TxtGetLine(tc_raw, Line=line_idx)
        if (line_str != "" && RT_FindStr(line_str, "#", sig=false) == 0 && RT_FindStr(line_str, "vfr", sig=false) == 0) {
            c1 = RT_FindStr(line_str, ",", sig=false, pos=1)
            c2 = RT_FindStr(line_str, ",", sig=false, pos=c1+1)
            
            if (c1 > 0 && c2 > 0) {
                r_start = Int(Value(MidStr(line_str, 1, c1 - 1)))
                r_end   = Int(Value(MidStr(line_str, c1 + 1, c2 - (c1 + 1))))
                r_fps   = Value(MidStr(line_str, c2 + 1))
                
                # Add time for standard frames before this override block
                if (target_frame <= r_start) {
                    frames_diff = target_frame - current_frame
                    accumulated_time = accumulated_time + (frames_diff / base_fps)
                    current_frame = target_frame
                    break
                }
                
                # Add time for standard zone up to the start of this block
                frames_before = r_start - current_frame
                accumulated_time = accumulated_time + (frames_before / base_fps)
                current_frame = r_start
                
                # Check if target frame falls inside this specific override block
                if (target_frame <= r_end) {
                    frames_inside = target_frame - current_frame
                    accumulated_time = accumulated_time + (frames_inside / r_fps)
                    current_frame = target_frame
                    break
                }
                
                # Target frame is further down; add the full block time
                block_frames = (r_end - r_start) + 1
                accumulated_time = accumulated_time + (block_frames / r_fps)
                current_frame = r_end + 1
            }
        }
    }
    
    # If target frame is past all logged override lines, calculate using base FPS
    if (target_frame > current_frame) {
        frames_left = target_frame - current_frame
        accumulated_time = accumulated_time + (frames_left / base_fps)
    }
    
    return Round(accumulated_time * 1000.0) # Return time in milliseconds
}
