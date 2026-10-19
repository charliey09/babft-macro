#Requires AutoHotkey v2.0
#SingleInstance Force

; discord webhook goes here
webhook := ""

; how often you want to reset character in seconds (should be lower if your afk gold grinder is inconsistent)
; default 5 minutes
resetTime := 5*60

; developer mode enables tools i use
devMode := True

global LOG_FILE := A_ScriptDir "\activity.log"
global DISCORD_WEBHOOK_URL := webhook
global SettingsFile := A_ScriptDir "\macro_settings.ini"

PrintScreen:: {
    if devMode != True {
        return
    } else {
        MouseGetPos(&x, &y)
        color := PixelGetColor(x, y)
        ToolTip("Pixel: `nPos: " x ", " y "`nColor: " color)
    }
}

ScrollLock:: {
    if devMode != True {
        return
    } else {
        MouseGetPos(&x, &y)
        Loop {
            color := PixelGetColor(x, y, "RGB")
            ToolTip("Tracking Pixel:`nPos: " x ", " y "`nColor: " color)
            Sleep(10)
            if GetKeyState("Pause", "P")
                break
        }
    }
}

Pause:: {
    if devMode != True {
        return
    } else {
        ToolTip()
    }
}

Status(msg) {
    timestamp := FormatTime(, "HH:mm:ss")
    FileAppend("[" timestamp "] " msg "`n", LOG_FILE)
    ToolTip(msg)
    SetTimer(RemoveToolTip, -2500)
    DiscordWebhook("[" timestamp "] " msg)
}

RemoveToolTip() {
    ToolTip()
}

DiscordWebhook(text) {
    global DISCORD_WEBHOOK_URL
    if (DISCORD_WEBHOOK_URL == "" || InStr(DISCORD_WEBHOOK_URL, "YOUR_WEBHOOK")) {
        return
    }
    try {
        jsonPayload := '{"content": "' text '"}'
        whr := ComObject("Msxml2.XMLHTTP")
        whr.Open("POST", DISCORD_WEBHOOK_URL, true)
        whr.SetRequestHeader("Content-Type", "application/json")
        whr.Send(jsonPayload)
    } catch Error as e {
        FileAppend("[Discord Error] " e.Message "`n", LOG_FILE)
    }
}

F1::{
    Status("Macro started")
    loop {
        Macro()
    }
}

F2::{
    Status("Reloading script"), sleep(1000)
    try {
        Run("babft.ahk")
    } catch error as e{
        Status("Script failed to reload:" e.Message)
    }
}

F3::{
    Status("Closing script")
    ExitApp()
}

F4::{
    if devmode != True {
        return
    } else {
        Send("{i down}"), sleep(2000)
        Send("{i up}"), sleep(1000)
        loop 3 {
            send("{o}"), Sleep(700)
        }
        Send("{esc}"), sleep(100)
        Send("r"), sleep(100)
        Send("{Enter}"), sleep(3000)
        Send("{w down}"), sleep(2000)
        Send("{w up}")
        Send("{a down}"), Sleep(10000)
        Send("{a up}")
        Send("{w down}"), sleep(7000)
        Send("{w up}")

        Send("{s down}{d down}"), Sleep(4200)
        Send("{d up}"), Sleep(6000)
        Send("{s up}")
        Send("{space}")
    }
}

Macro() {
    While WinExist("RobloxPlayerBeta.exe") or PixelGetColor(60, 558, "RGB") = 0x3ABDEE {
        Send("{esc}"), sleep(100)
        Send("r"), sleep(100)
        Send("{Enter}")
        Send("{s down}")
        loop resetTime {
            MouseClick("L", 967, 732), Sleep(1000)
        }
    }

    Try {
        Status("Launching Roblox player")
        Run("roblox-player:")
    } catch {
        Status("Error: Roblox not found")
    }
    Sleep(5000)
    if (PixelGetColor(62, 589, "RGB") = 0x121215) {
        Sleep(2000)
        MouseMove(185, 900), sleep(200) ; hovers over most recent game
        MouseClick("L", 196, 1060), Sleep(5000) ; clicks play
        while (PixelGetColor(50, 536, "RGB") != 0x4CBCED) { ; waits for launch menu to appear
            Sleep(100)
        }
        ;mouseclick("L", 0, 0)
        send("{o down}"), Sleep(2000) ; zooms camera out
        Send("{o up}")
        loop 2 {
            if PixelSearch(&FoundX, &FoundY, 1689, 76, 1689, 76, 0xE4E5E5, 10) {
                Send("{w down}"), sleep(3000)
                Send("{w up}")
                Send("{a down}"), Sleep(5000)
                Send("{a up}")
                Send("{w down}"), sleep(3000)
                Send("{w up}")
            } else if PixelSearch(&FoundX, &FoundY, 1700, 74, 1700, 74, 0x687D86, 10) {
                WinClose("RobloxPlayerBeta.exe")
                return
            }
            MouseClick("L", 1793, 460), Sleep(500) ; clicks menu
            MouseClick("L", 759, 191), Sleep(500) ; clicks teams
            MouseClick("L", 399, 475), Sleep(500) ; tries to change to white team
            MouseClick("L", 1437, 853), Sleep(500) ; clicks change
        }
    }
}
