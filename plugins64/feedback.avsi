function FeedbackInput(clip input, int "id")
{
LoadPlugin(AviSynthPlugins64Dir + "26/Feedback.dll")
        DotKillS(input, iterations)
}

function FeedbackOutput(clip input, int "id")
{
LoadPlugin(AviSynthPlugins64Dir + "26/Feedback.dll")
        DotKillS(input, iterations)
}