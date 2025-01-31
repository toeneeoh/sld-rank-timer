﻿#Requires AutoHotkey v2.0

; globals
GAME_NAME := "StarCraft II"
GAME_SPEED := 700 ; fastest game speed
TIMER_PAUSED := false
AUTO_PAUSED := true
BEEP_DURATION := 1000
RESET_TIMER := 0
BIND_SHRINE := 1     ; on
BIND_HIDDEN := 1     ; on
OPTI_HOTKEY := "F6"
OPTI_LAG    := 0     ; off
OPTI_BG     := 1     ; on
OPTI_MODEL  := 0     ; off
OPTI_DATA   := 0     ; off
SETUP_BANK  := 1     ; on
SETUP_RT    := 1     ; on
SETUP_ZOOM  := 5     ; 90 default
AUTO_SHRINE := 0     ; off
SHRINE_FREQ := 2200
HORSE_RACE  := 0     ; off
RUNE_PULL   := 0     ; off
RUNE_OPTION := 1     ; sell default
FORCE_TAB   := 0     ; off

; gui setup
mainGui  := Gui('+AlwaysOnTop', 'SLD Rank Timer'), mainGui.SetFont('s10')

xTxt  := mainGui.Add('Text', 'w400 h15', '@x is available')
xdTxt := mainGui.Add('Text', 'w400 h15', '@xd is available')
xd2Txt := mainGui.Add('Text', 'w400 h15', '@xd2 is available')

resetButton := mainGui.Add('Button', 'w100 h20', 'Reset')
resetButton.OnEvent("Click", ResetClick)

pauseButton := mainGui.Add('Button', 'w100 h20 xp120 yp0', 'Pause')
pauseButton.OnEvent("Click", SetGlobal.Bind("TIMER_PAUSED"))

optionsButton := mainGui.Add('Button', 'w100 h20 xp120 yp0', 'Options')
optionsButton.OnEvent("Click", OptionsMenu)

optiButton := mainGui.Add('Button', 'xp-120 yp30 w100 h20', 'Opti')
optiButton.OnEvent("Click", OptimizeClick)

autoButton := mainGui.Add('Button', 'xp-120 yp0 w100 h20', 'Auto: OFF')
autoButton.OnEvent("Click", SetGlobal.Bind("AUTO_PAUSED"))

mainGui.OnEvent("Close", CloseApp)
mainGui.Show('w400 h150 x1200 y150')

ih := InputHook("L5 E M V" , '{Enter}', '@xd{Enter}, @x{Enter}, @xd2{Enter}')

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
Import()
SetControlDelay -1

CloseApp(info) {
    ExitApp
}

OptionsMenu(btn, info) {
    global mainGui
    options := Gui('+AlwaysOnTop')
    options.Opt("+Owner" mainGui.Hwnd)
    options.Show('w500 h700 x1100 y340')
    mainGui.Opt("+Disabled")

    timerGroup := options.Add("GroupBox", "w370 h300 r4", "Timer")
    beepText := options.Add("Text", "xp10 yp20", "Sound alert duration (in milliseconds)")
    beepDuration := options.Add("Edit", "Limit4 Number w80", String(BEEP_DURATION))
    beepDuration.OnEvent("Change", SetGlobal.Bind("BEEP_DURATION"))

    alwaysResetTimer := options.Add("CheckBox", "Checked" RESET_TIMER, "Reset timer with command")
    alwaysResetTimer.OnEvent("Click", SetGlobal.Bind("RESET_TIMER"))

    optiGroup := options.Add("GroupBox", "w370 h300 r11 xp-10 yp35", "Opti")
    optiText := options.Add("Text", "yp20 xp10", "Assign hotkey:")
    optiHotkey := options.Add("Hotkey", "yp-2 xp75", OPTI_HOTKEY)
    optiHotkey.OnEvent("Change", ChangeOptiHotkey)

    bindShrine := options.Add("CheckBox", "yp25 xp-75 Checked" BIND_SHRINE, "Bind shrine to CTRL group 1")
    bindShrine.OnEvent("Click", SetGlobal.Bind("BIND_SHRINE"))

    bindHidden := options.Add("CheckBox", "Checked" BIND_HIDDEN, "Bind hidden beacon to CTRL group 2")
    bindHidden.OnEvent("Click", SetGlobal.Bind("BIND_HIDDEN"))

    enableBG := options.Add("CheckBox", "Checked" OPTI_BG, "Enable BG")
    enableBG.OnEvent("Click", SetGlobal.Bind("OPTI_BG"))

    enableLag := options.Add("CheckBox", "Checked" OPTI_LAG, "Enable Lag")
    enableLag.OnEvent("Click", SetGlobal.Bind("OPTI_LAG"))

    enableModel := options.Add("CheckBox", "Checked" OPTI_MODEL, "Enable Model (Toggles off if Opti is run again)")
    enableModel.OnEvent("Click", SetGlobal.Bind("OPTI_MODEL"))

    enableData := options.Add("CheckBox", "Checked" OPTI_DATA, "Enable @Data")
    enableData.OnEvent("Click", SetGlobal.Bind("OPTI_DATA"))

    enableBank := options.Add("CheckBox", "Checked" SETUP_BANK, "Bank Auto Deposit")
    enableBank.OnEvent("Click", SetGlobal.Bind("SETUP_BANK"))

    enableRT := options.Add("CheckBox", "Checked" SETUP_RT, "Set @rt to 1")
    enableRT.OnEvent("Click", SetGlobal.Bind("SETUP_RT"))

    zoomText := options.Add("Text", "", "Camera zoom")
    setZoom := options.Add("DropDownList", "w50 yp-3 xp70 Choose" SETUP_ZOOM, ["50", "60", "70", "80", "90", "100"])
    setZoom.OnEvent("Change", SetGlobal.Bind("SETUP_ZOOM"))

    autoGroup := options.Add("GroupBox", "w370 h300 r6 xp-80 yp35", "Auto")

    enableShrine := options.Add("CheckBox", "xp10 yp20 Checked" AUTO_SHRINE, "Auto Shrine (1200) Frequency (ms):")
    enableShrine.OnEvent("Click", SetGlobal.Bind("AUTO_SHRINE"))

    shrineDuration := options.Add("Edit", "Limit5 Number w50 yp-3 xp190", String(SHRINE_FREQ))
    shrineDuration.OnEvent("Change", SetGlobal.Bind("SHRINE_FREQ"))
    shrineText := options.Add("Text", "yp3 xp60", "(Bound to CTRL+1)")

    enableHorseRace := options.Add("CheckBox", "xp-250 yp20 Checked" HORSE_RACE, "Auto Horse Race")
    enableHorseRace.OnEvent("Click", SetGlobal.Bind("HORSE_RACE"))

    enableRune := options.Add("CheckBox", "Checked" RUNE_PULL, "Auto Rune Pull")
    enableRune.OnEvent("Click", SetGlobal.Bind("RUNE_PULL"))

    runeOption := options.Add("DropDownList", "w60 yp-3 xp110 Choose" RUNE_OPTION, ["Sell", "UPG 1", "UPG 2", "UPG 3", "UPG 4", "UPG 5"])
    runeOption.OnEvent("Change", SetGlobal.Bind("RUNE_OPTION"))

    enableForceTab := options.Add("CheckBox", "xp-110 yp23 Checked" FORCE_TAB, "Force Window Tab-in")
    enableForceTab.OnEvent("Click", SetGlobal.Bind("FORCE_TAB"))

    importButton := options.Add('Button', 'w100 h20 yp100', 'Import Settings')
    importButton.OnEvent("Click", ImportSettings)

    exportButton := options.Add('Button', 'w100 h20 xp120 yp0', 'Export Settings')
    exportButton.OnEvent("Click", ExportSettings)

    options.OnEvent("Close", CloseOptions)
}

Import() {
    global
    BEEP_DURATION := IniRead("config", "Timer", "BEEP_DURATION", 1000)
    RESET_TIMER := IniRead("config", "Timer", "RESET_TIMER", 0)

    OPTI_HOTKEY := IniRead("config", "Opti", "OPTI_HOTKEY", "F6")
    OPTI_BG := IniRead("config", "Opti", "OPTI_BG", 1)
    OPTI_LAG := IniRead("config", "Opti", "OPTI_LAG", 0)
    OPTI_MODEL := IniRead("config", "Opti", "OPTI_MODEL", 0)
    OPTI_DATA := IniRead("config", "Opti", "OPTI_DATA", 0)
    BIND_SHRINE := IniRead("config", "Opti", "BIND_SHRINE", 1)
    BIND_HIDDEN := IniRead("config", "Opti", "BIND_HIDDEN", 1)
    SETUP_BANK := IniRead("config", "Opti", "SETUP_BANK", 1)
    SETUP_RT := IniRead("config", "Opti", "SETUP_RT", 1)
    SETUP_ZOOM := IniRead("config", "Opti", "SETUP_ZOOM", 5)

    AUTO_SHRINE := IniRead("config", "Auto", "AUTO_SHRINE", 0)
    SHRINE_FREQ := IniRead("config", "Auto", "SHRINE_FREQ", 2200)
    HORSE_RACE := IniRead("config", "Auto", "HORSE_RACE", 0)
    RUNE_PULL := IniRead("config", "Auto", "RUNE_PULL", 0)
    RUNE_OPTION := IniRead("config", "Auto", "RUNE_OPTION", 1)
    FORCE_TAB := IniRead("config", "Auto", "FORCE_TAB", 0)
}

ImportSettings(btn, info) {
    Import
    WinClose
}

ExportSettings(btn, info) {
    IniWrite(BEEP_DURATION, "config", "Timer", "BEEP_DURATION")
    IniWrite(RESET_TIMER, "config", "Timer", "RESET_TIMER")

    IniWrite(OPTI_HOTKEY, "config", "Opti", "OPTI_HOTKEY")
    IniWrite(OPTI_BG, "config", "Opti", "OPTI_BG")
    IniWrite(OPTI_LAG, "config", "Opti", "OPTI_LAG")
    IniWrite(OPTI_MODEL, "config", "Opti", "OPTI_MODEL")
    IniWrite(OPTI_DATA, "config", "Opti", "OPTI_DATA")
    IniWrite(BIND_SHRINE, "config", "Opti", "BIND_SHRINE")
    IniWrite(BIND_HIDDEN, "config", "Opti", "BIND_HIDDEN")
    IniWrite(SETUP_BANK, "config", "Opti", "SETUP_BANK")
    IniWrite(SETUP_RT, "config", "Opti", "SETUP_RT")
    IniWrite(SETUP_ZOOM, "config", "Opti", "SETUP_ZOOM")

    IniWrite(AUTO_SHRINE, "config", "Auto", "AUTO_SHRINE")
    IniWrite(SHRINE_FREQ, "config", "Auto", "SHRINE_FREQ")
    IniWrite(HORSE_RACE, "config", "Auto", "HORSE_RACE")
    IniWrite(RUNE_PULL, "config", "Auto", "RUNE_PULL")
    IniWrite(RUNE_OPTION, "config", "Auto", "RUNE_OPTION")
    IniWrite(FORCE_TAB, "config", "Auto", "FORCE_TAB")
}

SetGlobal(globalVar, btn, info) {
    global
    %globalVar% := !%globalVar%

    if btn == pauseButton {
        btn.Text := %globalVar% ? 'Unpause' : 'Pause'
    } else if btn == autoButton {
        btn.Text := %globalVar% ? 'Auto: OFF' : 'Auto: ON'

        SetTimer(AutoShrine, AUTO_PAUSED ? 0 : SHRINE_FREQ)
        SetTimer(HorseRace, AUTO_PAUSED ? 0 : 10000)
        SetTimer(RunePull, AUTO_PAUSED ? 0 : 100000)
    } else {
        %globalVar% := btn.Value
    }
}

HorseRace() {
    global

    if HORSE_RACE {
        WinGetPos &X, &Y, &W, &H, GAME_NAME

        if WinExist(GAME_NAME) && FORCE_TAB
            WinActivate

        horseX := 1.265 * H
        horseY := 0.564 * H

        ControlClick , GAME_NAME,,,, "NA x" horseX "y" horseY
    }
}

AutoShrine() {
    global

    if AUTO_SHRINE {
        if WinExist(GAME_NAME) && FORCE_TAB
            WinActivate

        ControlSend "{Ctrl down}0{Ctrl up}",, GAME_NAME ; Store control group of selected units

        WinGetPos &X, &Y, &W, &H, GAME_NAME

        groupOneX := 0.494 * H
        groupOneY := 0.745 * H

        shrine1200X := 1.523 * H
        shrine1200Y := 0.904 * H

        ControlClick , GAME_NAME,,,, "x" groupOneX "y" groupOneY ; Click shrine
        Sleep 10
        ControlClick , GAME_NAME,,,, "x" shrine1200X "y" shrine1200Y ; Click spell
        ControlSend "0",, GAME_NAME ; Reselect control group
    }
}

RunePull() {
    global

    if RUNE_PULL {
        WinGetPos &X, &Y, &W, &H, GAME_NAME

        if WinExist(GAME_NAME) && FORCE_TAB
            WinActivate

        runeX := 1.01 * H
        runeY := 0.317 * H

        claimX := 1.01 * H
        claimY := 0.39 * H

        sellX := 0.817 * H
        sellY := 0.325 * H

        upgX := 0.75 * H
        upgY := 0.328 * H

        slotX := 0.988 * H
        slotY := (0.195 + (0.07 * (RUNE_OPTION - 2))) * H

        ControlClick , GAME_NAME,,,, "NA x" runeX "y" runeY
        Sleep 6000 ; wait for pull
        ControlClick , GAME_NAME,,,, "NA x" claimX "y" claimY
        Sleep 250

        if RUNE_OPTION == 1 { ; sell
            ControlClick , GAME_NAME,,,, "NA x" sellX "y" sellY
        } else {
            ControlClick , GAME_NAME,,,, "NA x" upgX "y" upgY
            Sleep 1000
            ControlClick , GAME_NAME,,,, "NA x" slotX "y" slotY
        }
    }
}

ChangeOptiHotkey(btn, info) {
    global OPTI_HOTKEY

    Hotkey OPTI_HOTKEY, GoOptimize, "Off"
    OPTI_HOTKEY := btn.Value
    Hotkey OPTI_HOTKEY, GoOptimize, "On"
}

GoOptimize(hotkey) {
    global GAME_NAME
    WinGetPos &X, &Y, &W, &H, GAME_NAME
    ; UI Scales by height only

    optionsX := 0.1 * H
    optionsY := 0.15 * H

    optiX := 0.291 * H
    optiY := 0.618 * H

    modelX := 0.289 * H
    modelY := 0.575 * H

    bgX := (OPTI_BG ? 0.1 : 0.15) * H
    bgY := 0.4 * H

    lagX := (OPTI_LAG ? 0.15 : 0.1) * H
    lagY := 0.55 * H

    ; start
    ControlSend "{Esc}",, GAME_NAME

    if BIND_SHRINE {
        ControlSend "{F1}",, GAME_NAME
        ControlSend "{Ctrl down}1{Ctrl up}",, GAME_NAME
        Sleep 150
    }

    if BIND_HIDDEN {
        hiddenX := 0.932 * H
        hiddenY := 0.144 * H
        ControlClick , GAME_NAME,,,, "x" hiddenX "y" hiddenY
        Sleep 500
        ControlSend "{Ctrl down}2{Ctrl up}",, GAME_NAME
    }

    Sleep 150
    ; open options
    ControlClick , GAME_NAME,,,, "x" optionsX "y" optionsY

    Sleep 150 ; Delay is necessary (?)
    ControlClick , GAME_NAME,,,, "NA x" optiX "y" optiY

    Sleep 150
    ControlClick , GAME_NAME,,,, "NA x" bgX "y" bgY

    Sleep 150
    ControlClick , GAME_NAME,,,, "NA x" lagX "y" lagY

    if OPTI_MODEL {
        Sleep 150
        ControlClick , GAME_NAME,,,, "NA x" modelX "y" modelY
    }

    if OPTI_DATA {
        ControlSend "{Enter}",, GAME_NAME
        ControlSendText "@data",, GAME_NAME
        ControlSend "{Enter}",, GAME_NAME
    }

    Sleep 150
    ControlSend "{Esc}",, GAME_NAME

    if SETUP_BANK {
        bankX := 0.07 * H
        bankY := 0.15 * H
        autoDepositX := 0.195 * H
        autoDepositY := 0.321 * H

        Sleep 150
        ControlClick , GAME_NAME,,,, "NA x" bankX "y" bankY

        Sleep 150
        ControlSend "{Ctrl down}",, GAME_NAME
        ControlClick , GAME_NAME,,,, "NA x" autoDepositX "y" autoDepositY
        ControlSend "{Ctrl up}",, GAME_NAME

        Sleep 150
        ControlSend "{Esc}",, GAME_NAME
    }

    if SETUP_RT {
        Loop 2 {
            ControlSend "{Enter}",, GAME_NAME
            ControlSendText "@rt-",, GAME_NAME
            ControlSend "{Enter}",, GAME_NAME
        }
    }

    if SETUP_ZOOM != 0 {
        ControlSend "{Enter}",, GAME_NAME
        ControlSendText "-s " (SETUP_ZOOM * 10 + 40),, GAME_NAME
        ControlSend "{Enter}",, GAME_NAME
    }
}

OptimizeClick(btn, info) {
    GoOptimize("")
}

CloseOptions(info) {
    global mainGui
    mainGui.Opt("-Disabled")
}

ResetClick(btn, info) {
    ResetCD("x")
    ResetCD("xd")
    ResetCD("xd2")
}

DetectKeyInputs() {
    global
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
            ; don't reset timer if already started and RESET_TIMER is off
            if !(RESET_TIMER) && cd_map[input] < cooldowns[input] {
                return
            }

            ResetCD(input)
            SetTimer(timers[input], GAME_SPEED)
        }
    }
}

ResetCD(cmd) {
    global
    cd_map[cmd] := cooldowns[cmd]
    boxes[cmd].Text := '@' . cmd . ' is available'
    SetTimer(timers[cmd], 0)
}

Tick(cmd) {
    global
    if !TIMER_PAUSED {
        cd_map[cmd] := cd_map[cmd] - 1
    }
    if cd_map[cmd] > 0 {
        boxes[cmd].Text := '@' . cmd . ' is on cooldown: ' . cd_map[cmd] . ' seconds remain'
    } else {
        ResetCD(cmd)
        SoundBeep(800, BEEP_DURATION)
    }
}
