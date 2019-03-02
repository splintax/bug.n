CapsLock::Ctrl

; This is convenient during development.
^!r::
MsgBox Reloading configuration.
Reload
return

; My keyboard doesn't have a right Windows key, just an AppsKey. So that's
; remapped to Windows, and the original function is accessible with a modifier.
AppsKey::RWin
^AppsKey::AppsKey

; Add some custom volume keys, because my keyboard doesn't have dedicated ones.
PrintScreen & F12::Send {Volume_Up}
PrintScreen & F11::Send {Volume_Down}
PrintScreen & F10::Send {Volume_Mute}
PrintScreen & F9::Send ^{F9} ; pause foobar2000
PrintScreen & F8::Send ^{F8} ; activate foobar2000
PrintScreen::Send {PrintScreen}
!PrintScreen::Send !{PrintScreen}

; Use the scroll wheel as a volume knob by holding the Windows key. A spare
; mouse button can be mapped to the Windows key for added convenience.
#WheelUp::Send {Volume_Up}
#WheelDown::Send {Volume_Down}
#WheelRight::Monitor_activateView(0, 1)
#WheelLeft::Monitor_activateView(0, -1)
#LButton::Send ^{F9} ; pause foobar2000
#RButton::Send ^{F8} ; activate foobar2000

WheelLeft::
If (A_TimeSincePriorHotkey > 100) {
  Click
  Send ^{-}
}
return

WheelRight::
If (A_TimeSincePriorHotkey > 100) {
  Click
  Send ^{=}
}
return

; Given an expression of the kind accepted by WinTitle, such as `ahk_exe
; putty.exe` (or a regex), activate the first window that matches it.
ActivateNextMatchingWindow(WinTitleExpression) {
  WinGet, MatchingWindows, List, %WinTitleExpression%
  ActiveIndex := 0
  Loop %MatchingWindows% {
    ; The pseudo-array returned by WinGet List contains the IDs of the windows
    ; matching the WinTitle expression.
    WindowID := MatchingWindows%A_Index%
    ; Check if this window is the active window - if it is, we don't want to
    ; reactivate it, we want to move onto the next matching window (if any).
    Active := WinActive("ahk_id " . WindowID)
    ; Check the title of this window and save it in the WindowTitle variable.
    ; This is just a hack to avoid various dodgy and invisible windows that
    ; you probably don't want to activate.
    WinGetTitle, WindowTitle, ahk_id %WindowID%
    WinGet, ProcessName, ProcessName, ahk_id %WindowID%
    ; If the conditions are satisfied, activate the window.
    if (WindowTitle != "" and WindowTitle != "Program Manager" and ProcessName != "ApplicationFrameHost.exe" and not Active) {
      WinActivate, ahk_id %WindowID%
      return
    } ; Otherwise, the loop continues for the next matching window.
  }
}

^e:: ; This is the main binding in Switch.ahk.
; First, we collect a single unit of input (L1) from the user. The non-printing
; keys are all EndKeys, meaning that 'Switch mode' won't seem to get 'stuck on'
; when you hit ^e by accident.
Input, SingleKey, L1, {LControl}{RControl}{LAlt}{RAlt}{LShift}{RShift}{LWin}{RWin}{AppsKey}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}{Del}{Ins}{BS}{CapsLock}{NumLock}{PrintScreen}{Pause}
; Then, we manually bind these keys to special functions.
if (SingleKey = "x") {
  Send !{F4}
} else if (SingleKey = "1") {
  ActivateNextMatchingWindow("ahk_exe explorer.exe")
} else if (SingleKey = "2") {
  ; This will suck if you use both at the same time, but I don't.
  ActivateNextMatchingWindow("ahk_exe firefox.exe")
  ActivateNextMatchingWindow("ahk_exe iexplore.exe")
} else if (SingleKey = "3") {
  ActivateNextMatchingWindow("ahk_exe putty.exe")
; Finally, here's the general case (the function will just exit here if the
; user provided no input). Match the input against the first letter of the
; executable. The backslashes are needed to deal with the fact that AutoHotKey
; provides the full path to the executable.
} else if (SingleKey != "") {
  SetTitleMatchMode RegEx
  ActivateNextMatchingWindow("ahk_exe i)\\" . SingleKey . "[^\\]*$")
}
return

; A bunch of shortcuts to get Vim-like navigation in Acrobat DC.
; Credit: https://superuser.com/questions/40909/vim-like-navigation-n-adobe-acrobat-reader/569921#569921
; TODO: Figure out why this breaks when moved to another file.

#IfWinActive ahk_class AcrobatSDIWindow
g::Send ^+n
return

#IfWinActive ahk_class AcrobatSDIWindow
+g::Send {End}
return

#IfWinActive ahk_class AcrobatSDIWindow
h::
Loop, 10 {
  Send {Left}
}
return

#IfWinActive ahk_class AcrobatSDIWindow
l::
Loop, 10 {
  Send {Right}
}
return

#IfWinActive ahk_class AcrobatSDIWindow
j::
Loop, 10 {
  Send {Down}
}
return

#IfWinActive ahk_class AcrobatSDIWindow
k::
Loop, 10 {
  Send {Up}
}
return

#IfWinActive ahk_class AcrobatSDIWindow
d::
Loop, 60 {
  Send {Down}
}
return

#IfWinActive ahk_class AcrobatSDIWindow
u::
Loop, 60 {
  Send {Up}
}
return

#IfWinActive ahk_class AcrobatSDIWindow
+j::Send ^{Down}

#IfWinActive ahk_class AcrobatSDIWindow
+k::Send ^{Up}
