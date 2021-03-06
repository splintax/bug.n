﻿; Use the scroll wheel as a volume knob by holding the Windows key. A spare
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

; Typography
:*?:--n::–
:*?:--m::—
:*?:<--::←
:*?:-->::→
:*?:||^::↑
:*?:||v::↓
:*?:^^o::°

; Superscripts
:*?:^1::¹
:*?:^2::²
:*?:^3::³
:*?:^4::⁴
:*?:^5::⁵
:*?:^6::⁶
:*?:^7::⁷
:*?:^8::⁸
:*?:^9::⁹
:*?:^0::⁰
:*?:^+::⁺
:*?:^-::⁻
:*?:^=::⁼
:*?:^(::⁽
:*?:^)::⁾
:*?:^^n::ⁿ
:*?:^^i::ⁱ
:*?:..x::×
:*?:..%::÷
:*?:+_::±

; French characters
:*?:\\a::à
:*?:\\A::À
:*?:-ae-::æ
:*?:-AE-::Æ
:*?:,,c::ç
:*?:,,C::Ç
:*?:\\e::è
:*?:\\E::È
:*?:''e::é
:*?:''E::É
:*?:^e::ê
:*?:^E::Ê
:*?:^i::î
:*?:^I::Î
:*?:..i::ï
:*?:^o::ô
:*?:^O::Ô
:*?:-oe-::œ
:*?:-OE-::Œ
:*?:\\u::ù
:*?:\\U::Ù
:*?:^u::û

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
