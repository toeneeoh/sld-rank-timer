#Requires AutoHotkey v2.0
gui1  := Gui('+AlwaysOnTop', 'SLD Rank Timer'), gui1.SetFont('s10')
xTxt  := gui1.Add('Text', 'w400 h15', '@x is available')
xdTxt := gui1.Add('Text', 'w400 h15', '@xd is available')
xd2Txt := gui1.Add('Text', 'w400 h15', '@xd2 is available')
resetButton := gui1.Add('Button', 'w100 h20', 'Reset')
resetButton.OnEvent("Click", ResetClick)
pauseButton := gui1.Add('Button', 'w100 h20 xp120 yp0', 'Pause')
pauseButton.OnEvent("Click", TogglePause)
gui1.OnEvent("Close", CloseApp)
gui1.Show('w400 h120 x1200 y150')

ih := InputHook("L5 E M V" , '{Enter}', '@xd{Enter}, @x{Enter}, @xd2{Enter}')

GAME_SPEED := 700 ; fastest game speed
IS_PAUSED := false

; base cooldowns
cooldowns := Map()
cooldowns["xd2"]  := 1800
cooldowns["xd"]   := 1800
cooldowns["x"]    := 900

; text boxes
boxes := Map()
boxes["xd2"]      := xd2Txt
boxes["xd"]       := xdTxt
boxes["x"]        := xTxt

; timers
timers := Map()
timers["xd2"]     := Tick.Bind("xd2")
timers["xd"]      := Tick.Bind("xd")
timers["x"]       := Tick.Bind("x")

cd_map := Map()
cd_map["xd2"]     := 1800
cd_map["xd"]      := 1800
cd_map["x"]       := 900

SetTimer(DetectKeyInputs, 100)

CloseApp(info) {
    ExitApp
}

TogglePause(btn, info) {
    global IS_PAUSED
    IS_PAUSED := !IS_PAUSED
    pauseButton.Text := IS_PAUSED ? 'Unpause' : 'Pause'
}

ResetClick(btn, info) {
    ResetCD("x")
    ResetCD("xd")
    ResetCD("xd2")
}

DetectKeyInputs() {
    global cooldowns, timers, GAME_SPEED
    Loop {
        ih.Start() ; Start capturing input
        ih.Wait()
        input := false

        if InStr(ih.Input, "@xd2") {
            if cd_map["xd2"] == cooldowns["xd2"] {
                input := "xd2"
            }
        } else if InStr(ih.Input, "@xd") {
            if cd_map["xd"] == cooldowns["xd"] {
                input := "xd"
            }
        } else if InStr(ih.Input, "@x") {
            if cd_map["x"] == cooldowns["x"] {
                input := "x"
            }
        }

        if input {
            SetTimer(timers[input], GAME_SPEED, 1000000) ; arbitrary priority (?)
        }
    }
}

ResetCD(cmd) {
    global cd_map, cooldowns, boxes, timers
    cd_map[cmd] := cooldowns[cmd]
    boxes[cmd].Text := '@' . cmd . ' is available'
    SetTimer(timers[cmd], 0)
}

Tick(cmd) {
    global cd_map, boxes, IS_PAUSED
    if !(IS_PAUSED) {
        cd_map[cmd] := cd_map[cmd] - 1
    }
    if cd_map[cmd] > 0 {
        boxes[cmd].Text := '@' . cmd . ' is on cooldown: ' . cd_map[cmd] . ' seconds remain'
    } else {
        ResetCD(cmd)
    }
}
