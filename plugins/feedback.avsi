function FeedbackInput(clip input, int "id")
{
LoadPlugin(AviSynthPluginsDir + "26/Feedback.dll")
        DotKillS(input, iterations)
}

function FeedbackOutput(clip input, int "id")
{
LoadPlugin(AviSynthPluginsDir + "26/Feedback.dll")
        DotKillS(input, iterations)
}