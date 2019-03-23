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
XButton1 & WheelUp::Send {Volume_Up}
XButton1 & WheelDown::Send {Volume_Down}
#WheelDown::Monitor_activateView(0, 1)
#WheelUp::Monitor_activateView(0, -1)
#LButton::Send ^{F9} ; pause foobar2000
#RButton::Send ^{F8} ; activate foobar2000

; Use the mouse to manage browser tabs by holding the XButton.
XButton1 & MButton::Send ^{F4}
XButton1 & LButton::Send ^+{Tab}
XButton1 & RButton::Send ^{Tab}

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
