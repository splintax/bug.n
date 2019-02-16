#SingleInstance force

; This is convenient during development.
^!r::
MsgBox Reloading configuration.
Reload
return

; Add custom volume keys to get around the fact that the Microsoft Sculpt
; Ergonomic Desktop Keyboard can't use the media keys and F-keys simultaenously.
PrintScreen & F12::Send {Volume_Up}
PrintScreen & F11::Send {Volume_Down}
PrintScreen & F10::Send {Volume_Mute}
PrintScreen::Send {PrintScreen}
!PrintScreen::Send !{PrintScreen}

; Use the scroll wheel as a volume knob by holding the Windows key. An extra
; mouse button can be mapped to the Windows key for added convenience.
#WheelUp::Send {Volume_Up}
#WheelDown:: Send {Volume_Down}
#MButton::Send {Volume_Mute}

Toast(Text) {
  Menu Tray, NoIcon
  Menu Tray, Icon
  TrayTip,, %Text%, 1
}

ActivateExe(ExeName) {
  WinGetTitle, WindowTitle, ahk_exe %ExeName%
  WinActivate, ahk_exe %ExeName%
  Toast(WindowTitle)
}

ActivateID(WindowID) {
  WinGetTitle, WindowTitle, ahk_id %WindowID%
  WinActivate, ahk_id %WindowID%
  Toast(WindowTitle)
}

^e::
Input, SingleKey, L1
if (SingleKey = "t")
  ActivateExe("putty.exe")
else if (SingleKey = "n")
  ActivateExe("notepad++.exe")
else if (SingleKey = "f")
  ActivateExe("firefox.exe")
else if (SingleKey = "v")
  ActivateExe("foobar2000.exe")
else {
  SetTitleMatchMode RegEx
  WinGet, MatchingWindows, List, ahk_exe i)\\%SingleKey%[^\\]*$
  Loop %MatchingWindows% {
    WindowID := MatchingWindows%A_Index%
    Inactive := WinActive(ahk_id %WindowID%) = 0
    WinGetTitle, WindowTitle, ahk_id %WindowID%
    if (WindowTitle != "" and WindowTitle != "Program Manager" and Inactive) {
      ActivateID(WindowID)
      return
    }
  }
  Toast("No windows launched by a process starting with '" . SingleKey . "'.")
}
return
