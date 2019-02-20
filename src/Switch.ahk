#SingleInstance force

CapsLock::Ctrl

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
#LButton::Send ^!p

Toast(Text) {
  Menu Tray, NoIcon
  Menu Tray, Icon
  TrayTip,, %Text%, 1
}

Activate(WindowID) {
  WinGetTitle, WindowTitle, ahk_id %WindowID%
  WinActivate, ahk_id %WindowID%
  ;Toast(WindowTitle)
}

NextMatchingWindow(WinTitle) {
  WinGet, MatchingWindows, List, %WinTitle%
  ActiveIndex := 0
  Loop %MatchingWindows% {
    WindowID := MatchingWindows%A_Index%
    Active := WinActive("ahk_id " . WindowID)
    WinGetTitle, WindowTitle, ahk_id %WindowID%
    if (WindowTitle != "" and WindowTitle != "Program Manager" and not Active) {
      return WindowID
    }
  }
  ;Toast("No windows matching '" . WinTitle . "'.")
}

^e::
Input, SingleKey, L1, {LControl}{RControl}{LAlt}{RAlt}{LShift}{RShift}{LWin}{RWin}{AppsKey}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}{Del}{Ins}{BS}{CapsLock}{NumLock}{PrintScreen}{Pause}
if (SingleKey = "x") {
  Send !{F4}
} else if (SingleKey = "1") {
  Activate(NextMatchingWindow("ahk_exe explorer.exe"))
} else if (SingleKey = "2") {
  Activate(NextMatchingWindow("ahk_exe firefox.exe"))
  Activate(NextMatchingWindow("ahk_exe iexplore.exe"))
} else if (SingleKey = "3") {
  Activate(NextMatchingWindow("ahk_exe putty.exe"))
} else if (SingleKey != "") {
  SetTitleMatchMode RegEx
  WindowID := NextMatchingWindow("ahk_exe i)\\" . SingleKey . "[^\\]*$")
  Activate(WindowID)
}
return
