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

optiButton := mainGui.Add('Button', 'xp-120 yp30 w100 h20', 'Opti')
optiButton.OnEvent("Click", OptimizeClick)

mainGui.OnEvent("Close", CloseApp)
mainGui.Show('w400 h150 x1200 y150')

ih := InputHook("L5 E M V" , '{Enter}', '@xd{Enter}, @x{Enter}, @xd2{Enter}')

GAME_SPEED := 700 ; fastest game speed
IS_PAUSED := false
BEEP_DURATION := 1000
ALWAYS_RESET_TIMER := 0
OPTI_HOTKEY := "F6"
OPTI_LAG := 0 ; off default
OPTI_BG := 1 ; on default
OPTI_MODEL := 0 ; off default
SETUP_BANK := 1 ; on default

Hotkey OPTI_HOTKEY, GoOptimize ; Register default hotkey (F6)

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
    options.Show('w500 h500 x1100 y340')
    mainGui.Opt("+Disabled")

    beepText := options.Add("Text", "", "Sound alert duration (in milliseconds)")
    beepDuration := options.Add("Edit", "Limit4 Number w80", String(BEEP_DURATION))
    beepDuration.OnEvent("Change", UpdateSoundDuration)

    alwaysResetTimer := options.Add("CheckBox", "Checked" ALWAYS_RESET_TIMER, "Reset timer with command")
    alwaysResetTimer.OnEvent("Click", ToggleResetTimer)

    optiGroup := options.Add("GroupBox", "w340 h200 r6 yp50", "Opti")
    optiText := options.Add("Text", "yp20 xp10", "Assign hotkey:")
    optiHotkey := options.Add("Hotkey", "yp-2 xp75", OPTI_HOTKEY)
    optiHotkey.OnEvent("Change", ChangeOptiHotkey)

    enableBG := options.Add("CheckBox", "yp25 xp-75 Checked" OPTI_BG, "Enable BG")
    enableBG.OnEvent("Click", ToggleBG)

    enableLag := options.Add("CheckBox", "Checked" OPTI_LAG, "Enable Lag")
    enableLag.OnEvent("Click", ToggleLag)

    enableModel := options.Add("CheckBox", "Checked" OPTI_MODEL, "Enable Model (Toggles off if Opti is run again)")
    enableModel.OnEvent("Click", ToggleModel)

    enableBank := options.Add("CheckBox", "Checked" SETUP_BANK, "Bank Auto Deposit")
    enableBank.OnEvent("Click", SetupBank)

    options.OnEvent("Close", CloseOptions)
}

SetupBank(btn, info) {
    global SETUP_BANK

    SETUP_BANK := btn.Value
}

ChangeOptiHotkey(btn, info) {
    global OPTI_HOTKEY

    Hotkey OPTI_HOTKEY, GoOptimize, "Off"
    OPTI_HOTKEY := btn.Value
    Hotkey OPTI_HOTKEY, GoOptimize, "On"
}

ToggleBG(btn, info) {
    global OPTI_BG

    OPTI_BG := btn.Value
}

ToggleLag(btn, info) {
    global OPTI_LAG

    OPTI_LAG := btn.Value
}

ToggleModel(btn, info) {
    global OPTI_MODEL

    OPTI_MODEL := btn.Value
}

GoOptimize(hotkey) {
    WinGetPos &X, &Y, &W, &H, "StarCraft II"
    ; MsgBox "SC2 pos: " X "," Y " size: " W "x" H
    ; UI Scales by height only

    optionsX := 0.1 * H
    optionsY := 0.15 * H

    optiX := 0.289 * H
    optiY := 0.62 * H

    modelX := 0.289 * H
    modelY := 0.575 * H

    bgX := (OPTI_BG ? 0.1 : 0.15) * H
    bgY := 0.4 * H

    lagX := (OPTI_LAG ? 0.15 : 0.1) * H
    lagY := 0.55 * H

    SetControlDelay -1
    ControlSend "{Esc}",, "StarCraft II"
    ControlClick , "StarCraft II",,,, "x" optionsX "y" optionsY

    Sleep 200 ; Delay is necessary
    ControlClick , "StarCraft II",,,, "NA x" optiX "y" optiY

    Sleep 100
    ControlClick , "StarCraft II",,,, "NA x" bgX "y" bgY

    Sleep 100
    ControlClick , "StarCraft II",,,, "NA x" lagX "y" lagY

    if OPTI_MODEL {
        ControlClick , "StarCraft II",,,, "NA x" modelX "y" modelY
    }

    Sleep 100
    ControlSend "{Esc}",, "StarCraft II"

    if SETUP_BANK {
        bankX := 0.07 * H
        bankY := 0.15 * H
        autoDepositX := 0.195 * H
        autoDepositY := 0.321 * H

        Sleep 100
        ControlClick , "StarCraft II",,,, "NA x" bankX "y" bankY

        Sleep 100
        ControlSend "{Ctrl down}",, "StarCraft II"
        Sleep 20
        ControlClick , "StarCraft II",,,, "NA x" autoDepositX "y" autoDepositY
        Sleep 20
        ControlSend "{Ctrl up}",, "StarCraft II"

        Sleep 250
        ControlSend "{Esc}",, "StarCraft II"
    }
}

OptimizeClick(btn, info) {
    GoOptimize("")
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
