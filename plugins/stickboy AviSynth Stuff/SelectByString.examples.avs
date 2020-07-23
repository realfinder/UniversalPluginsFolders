# LoadPlugin("SelectByString.dll")

bars = ColorBars(320, 240).Trim(0, 9)

bars = SelectByStringEval("i",
\                         "g", "bars.Greyscale()",
\                         "i", "bars.Levels(0, 1.0, 255, 255, 0)") # invert

msg = MessageClip(SelectByString("a",
\                                "a", "foo",
\                                "b", "bar",
\                                "c", "baz",
\                                "d", "quux",
\                                else="not found"),
\                 width=bars.Width())

SelectByStringEval("baz",
\                  "foo", "x = 0
                           y = 1
                           z = 2",
\                  "bar", "x = 3
                           y = 4
                           z = 5",
\                  "baz", "x = 6
                           y = 7
                           z = 8")
msg2 = MessageClip(String(x) + String(y) + String(z), width=bars.Width())

StackVertical(bars, msg, msg2)
