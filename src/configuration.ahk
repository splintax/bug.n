/*
:title:     bug.n/configuration
:copyright: (c) 2018 by joten <https://github.com/joten>
:license:   GNU General Public License version 3

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.
*/

class Configuration {
  __New(filename, defaults) {
    this.filename := filename
    this.defaults := defaults
    this.hotkeys := []
    this.variables := []

    this.barBackColor := "000000"
    this.barFontColor := "ffffff"
    this.barFontName := "Lucida Console"
    this.barFontSize := 8
    this.barOpacity := 192

    this.statusBarPosX := 0
    this.statusBarPosY := 0
    this.statusBarWidth := 1.0
    this.statusBarHeight := 10
    this.statusBarUpdateInterval := 60000

    statusBarShowCPU := False
    statusBarShowDate := "ddd. dd. MMM. yyyy"
    statusBarShowDisk := False
    statusBarShowMemory := False
    statusBarShowNetwork := False
    statusBarShowPower := False
    statusBarShowTime := "HH:mm"
    statusBarShowVolume := False

    this.restore()
  }

  edit() {
    Global logger

    If !FileExist(this.filename) {
      this.save()
    }
    If FileExist(this.filename) {
      Run, % "open " . this.filename
    } Else {
      logger.warning("**config.edit**: File not found (``" . this.filename . "``)")
      MsgBox, 16, % this.appName . "Error", % "The configuration file '" . this.filename . "' does not exist."
    }
  }

  relabelHotkey() {
    Global logger

    key := A_ThisHotkey
    logger.debug("**config.relabelHotkey**: Running relabeled hotkey function (" . key . " -> " . this.hotkeys[key] . ")")
    StrRun(this.hotkeys[key])
  }

  restore() {
    Global logger

    filename := FileExist(this.filename) ? this.filename : this.defaults
    If FileExist(filename) {
      Loop, Read, % filename
      {
        If (SubStr(A_LoopReadLine, 1, 4) = "    ") {
          StrPart(SubStr(A_LoopReadLine, 5), "=", name, value)
          If (name = "hotkey") {
            StrPart(value, "::", keyName, function)
            If (function = "") {
              Hotkey, %keyName%, Off
              logger.info("**config.restore**: Hotkey disabled (" . keyName . ")")
            } Else {
              this.hotkeys[keyName] := function
              Hotkey, %keyName%, this.relabelHotkey
              logger.info("**config.restore**: Hotkey relabeled (" . keyName . " -> " . function . ")")
            }
          } Else {
            this.variables.push(name)
            If (value != "") {
              this[name] := value
              logger.debug("**config.restore**: Variable set, " . name . " -> " . (value ? "``" . value . "``" : ""))
            }
          }
        }
      }
      logger.info("**Configuration** read from file (``" . this.filename . "``)")
    } Else {
      logger.warning("**config.restore**: File not found (``" . this.filename . "``)")
    }
  }

  save() {
    Global logger

    filename := FileExist(this.filename) ? this.filename : this.defaults
    str := ""
    If FileExist(filename) {
      FileRead, str, % filename
    }

    endOfline := "`r`n"
    activeLine := endOfline . "    "
    value_1 := "[^" . endOfline . "]*"
    For i, name in this.variables {
      value_2 := this[name]
      str := RegExReplace(str, activeLine . name . "=" . value_1, activeLine . name . "=" . value_2,, 1)
    }

    tmpFilename := this.filename . ".tmp"
    FileDelete, % tmpFilename
    FileAppend, % str, % tmpFilename
    If (ErrorLevel && FileExist(this.filename)) {
      logger.error("**Configuration.save**: Error writing configuration to file (" . this.filename . ")")
      If FileExist(tmpFilename) {
        FileDelete, % tmpFilename
      }
    } Else {
      FileMove, % tmpFilename, % this.filename, 1
    }
  }
}

;; logging
#^+Down::logger.setLevel(-1)
#^+Up::logger.setLevel(+1)

;; administration
#^e::config.edit()
#^s::config.save()
#^r::Reload
#^q::ExitApp
