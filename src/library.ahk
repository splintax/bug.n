/*
:title:     bug.n/library
:copyright: (c) 2018 by joten <https://github.com/joten>
:license:   GNU General Public License version 3

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.
*/

BGRToRGB(int) {
  ;; BGR format: 0xBBGGRR
  int := Format("{:x}", int)
  Return, SubStr(int, 5, 2) . SubStr(int, 3, 2) . SubStr(int, 1, 2)
}

FormatBytes(value) {
  If (value > 1047527424) {
    value /= 1024 * 1024 * 1024
    unit := "GB"
  } Else If (value > 1022976) {
    value /= 1024 * 1024
    unit := "MB"
  } Else If (value > 999) {
    value /= 1024
    unit := "kB"
  } Else {
    unit := " B"
  }
  value := Round(value, 1)
  If (value > 99.9 || unit = " B")
    value := Round(value, 0)

  Return, {value: value, unit: unit}
}

IntLoop(value, delta, lowerBound, upperBound) {
  If (upperBound <= 0 || upperBound < lowerBound)
    Return, 0

  n := upperBound - lowerBound + 1
  lowerBoundBasedI := value - lowerBound
  lowerBoundBasedI := Mod(lowerBoundBasedI + delta, n)
  If (lowerBoundBasedI < 0)
    lowerBoundBasedI += n

  Return, lowerBound + lowerBoundBasedI
}

StrPad(str_1, chars, count) {
  str_2 := ""
  Loop, % Abs(count) {
    str_2 .= chars
  }
  If (count < 0) {
    Return, SubStr(str_2 . str_1, count * StrLen(chars) + 1)
  } Else {
    Return, SubStr(str_1 . str_2, 1, count * StrLen(chars))
  }
}

StrPart(str, delimiter, ByRef str_1, ByRef str_2) {
  i := InStr(str, delimiter)
  If (i > 0) {
    str_1 := SubStr(str, 1, i - 1)
    str_2 := SubStr(str, i + StrLen(delimiter))
  } Else {
    str_1 := str
    str_2 := ""
  }
}

StrRun(str) {
  StrPart(str, " ", command, parameters)
  command := Format("{:L}", RTrim(command, ","))
  If (command = "exitapp") {
    ExitApp
  } Else If (command = "reload") {
    Reload
  } Else If (command = "run") {
    parameters := StrSplit(parameters, ",", " `t")
    For i, parameter in parameters {
      parameter_%i% := parameter
    }
    If (parameters.Length() = 2) {
      Run, %parameter_1%, %parameter_2%
    } Else If (parameters.Length() = 3) {
      Run, %parameter_1%, %parameter_2%, %parameter_3%
    } Else If (parameters.Length() = 4) {
      Run, %parameter_1%, %parameter_2%, %parameter_3%, %parameter_4%
    } Else {
      Run, %parameter_1%
    }
  } Else If (command = "send") {
    Send % Trim(parameters)
  } Else If RegExMatch(str, "O)(\w+)\((.*)\)", match) {
    function := match.Value(1)
    parameters := StrSplit(match.Value(2), ",", " `t")
    If (parameters.Length() = 1) {
      %function%(parameters[1])
    } Else If (parameters.Length() = 2) {
      %function%(parameters[1], parameters[2])
    } Else If (parameters.Length() = 3) {
      %function%(parameters[1], parameters[2], parameters[3])
    } Else If (parameters.Length() = 4) {
      %function%(parameters[1], parameters[2], parameters[3], parameters[4])
    } Else {
      %function%()
    }
  }
}

StrWidth(str, fontSize) {
  d := (fontSize > 17) ? 4 : (fontSize > 12) ? 3 : (fontSize > 8 || fontSize = 7) ? 2 : 1
  Return, StrLen(str) * (fontSize - d)
}
