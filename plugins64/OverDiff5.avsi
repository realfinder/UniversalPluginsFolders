function OverDiff5 (clip clip1,clip clip2,int "mode",int "top",int "bottom",int "left",int "right",int "smask",int "lmask",
            \ clip "c1",clip "c2",int "margin",bool "show") {
    mode=default(mode,0)
    top=default(top,0)
    bottom=default(bottom,0)
    left=default(left,0)
    right=default(right,0)
    smask=default(smask,40)
    lmask=default(lmask,20)
    margin=default(margin,0)
    show=default(show,false)
    c1=default(c1,clip1.crop(left,top,-right,-bottom).blur(0,1))
    c2=default(c2,clip2.crop(left,top,-right,-bottom).blur(0,1))

    check_diff=mt_lutxy(c1,c2,"x y - abs",chroma="process").mt_binarize(5).mt_inpand.mt_inpand.mt_inpand
    over_mask=BlankClip(clip1,color=$ffffff).Letterbox(top,bottom,left,right).mt_binarize()
    masked_1=mt_merge(clip1,clip2,over_mask,luma=true)
    show_mask=Overlay(BlankClip(clip1),check_diff).Grayscale()
    show_merge=merge(clip1,clip2)

    clip_0=masked_1
    clip_0=(show) ? merge(show_merge,over_mask) : clip_0
    clip_1=ConditionalFilter(check_diff,clip1,masked_1,"AverageLuma","<","1.0",show=show)
    clip_1_show=ConditionalFilter(check_diff,show_merge,show_merge,"AverageLuma","<","1.0",show=show)
    clip_1=(show) ? StackVertical(merge(clip_1_show,over_mask),show_mask) : clip_1

    c1=clip1.blur(0,1).Letterbox(top,bottom,left,right)
    c2=clip2.blur(0,1).Letterbox(top,bottom,left,right)
    small=mt_lutxy(c1,c2,"x y - abs",chroma="process").letterbox(0,0,2,2).mt_binarize(smask)
    small_u=mt_lutxy(c1.UToY,c2.UToY,"x y - abs",chroma="process")
    small_v=mt_lutxy(c1.VToY,c2.VToY,"x y - abs",chroma="process")
    small_uv=mt_logic(small_u,small_v,mode="or").PointResize(c1.width,c1.height).letterbox(0,0,2,2).mt_binarize(smask)
    small=(mode>=3) ? mt_logic(small,small_uv,mode="or") : small
    small_e=mt_lutxy(c1,c2,"x y - abs",chroma="process").letterbox(2,2,2,2).mt_edge
    small_e=(mode==4) ? small_e.mt_inpand : small_e
    small=mt_logic(small_e,small,mode="or")
    small=(margin==0) ? small : mt_logic(small,mt_logic(small.Loop(0,0,margin-1),small.Loop(margin+1,0,0),mode="or"),mode="or")
    small=(mode>=4) ? small : small.mt_inpand

    big=mt_lutxy(c1,c2,"x y - abs 1.5 ^",chroma="process")
    big_u=mt_lutxy(c1.UToY,c2.UToY,"x y - abs 1.5 ^",chroma="process")
    big_v=mt_lutxy(c1.VToY,c2.VToY,"x y - abs 1.5 ^",chroma="process")
    big_uv=mt_logic(big_u,big_v,mode="or").PointResize(c1.width,c1.height)
    big=(mode>3) ? mt_logic(big,big_uv,mode="or") : big
    big=big.mt_binarize(lmask)

    diff_mask=mt_hysteresis(small,big).mt_expand.mt_expand.mt_expand.mt_expand.mt_expand.mt_expand.mt_expand
    masked_2=mt_merge(clip1,clip2,diff_mask,luma=true)
    clip_2=ConditionalFilter(check_diff,clip1,masked_2,"averageluma","=","0",show=show)
    clip_2_show=ConditionalFilter(check_diff,show_merge,show_merge,"averageluma","=","0",show=show)
    clip_2=(show) ? StackVertical(merge(clip_2_show,diff_mask.Grayscale()),show_mask) : clip_2
    return select(mode,clip_0,clip_1,clip_2,clip_2,clip_2)
}