#Requires AutoHotkey v2.0
mainGui  := Gui('+AlwaysOnTop', 'SLD Rank Timer'), mainGui.SetFont('s10')
xTxt  := mainGui.Add('Text', 'w400 h15', '@x is available')
xdTxt := mainGui.Add('Text', 'w400 h15', '@xd is available')
xd2Txt := mainGui.Add('Text', 'w400 h15', '@xd2 is available')
resetButton := mainGui.Add('Button', 'w100 h20', 'Reset')
resetButton.OnEvent("Click", ResetClick)
pauseButton := mainGui.Add('Button', 'w100 h20 xp120 yp0', 'Pause')
pauseButton.OnEvent("Click", TogglePause)
optionsButton := mainGui.Add('Button', 'w100 h20 xp120 yp0', 'Options')
optionsButton.OnEvent("Click", OptionsMenu)
mainGui.OnEvent("Close", CloseApp)
mainGui.Show('w400 h120 x1200 y150')

ih := InputHook("L5 E M V" , '{Enter}', '@xd{Enter}, @x{Enter}, @xd2{Enter}')

GAME_SPEED := 700 ; fastest game speed
IS_PAUSED := false
BEEP_DURATION := 1000
ALWAYS_RESET_TIMER := 0

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

OptionsMenu(btn, info) {
    global mainGui
    options := Gui('+AlwaysOnTop')
    options.Opt("+Owner" mainGui.Hwnd)
    options.Show('w500 h500 x1100 y300')
    mainGui.Opt("+Disabled")

    beepText := options.Add("Text", "", "Sound alert duration (in milliseconds)")
    beepDuration := options.Add("Edit", "Limit4 Number w80", String(BEEP_DURATION))
    beepDuration.OnEvent("Change", UpdateSoundDuration)

    alwaysResetTimer := options.Add("CheckBox" , "Checked" ALWAYS_RESET_TIMER, "Reset timer with command")
    alwaysResetTimer.OnEvent("Click", ToggleResetTimer)

    options.OnEvent("Close", CloseOptions)
}

CloseOptions(info) {
    global mainGui
    mainGui.Opt("-Disabled")
}

UpdateSoundDuration(btn, info) {
    global BEEP_DURATION

    if btn.Text != "" {
        BEEP_DURATION := Integer(btn.Text)
    }
}

ToggleResetTimer(btn, info) {
    global ALWAYS_RESET_TIMER

    ALWAYS_RESET_TIMER := btn.Value
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
    global cooldowns, cd_map, timers, GAME_SPEED, ALWAYS_RESET_TIMER
    Loop {
        ih.Start() ; Start capturing input
        ih.Wait()
        input := false

        if InStr(ih.Input, "@xd2") {
            input := "xd2"
        } else if InStr(ih.Input, "@xd") {
            input := "xd"
        } else if InStr(ih.Input, "@x") {
            input := "x"
        }

        if input {
            ; don't reset timer if already started and ALWAYS_RESET_TIMER is off
            if !(ALWAYS_RESET_TIMER) && cd_map[input] < cooldowns[input] {
                return
            }

            ResetCD(input)
            SetTimer(timers[input], GAME_SPEED)
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
    global cd_map, boxes, IS_PAUSED, beepDuration
    if !(IS_PAUSED) {
        cd_map[cmd] := cd_map[cmd] - 1
    }
    if cd_map[cmd] > 0 {
        boxes[cmd].Text := '@' . cmd . ' is on cooldown: ' . cd_map[cmd] . ' seconds remain'
    } else {
        ResetCD(cmd)
        SoundBeep(800, BEEP_DURATION)
    }
}
