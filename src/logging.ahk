/*
:title:     bug.n/logging
:copyright: (c) 2018 by joten <https://github.com/joten>
:license:   GNU General Public License version 3

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.
*/

class Logging {
  /*
  Log messages (with or without a timestamp) to a file given by filename
  truncate = True => Delete an existing log file with the same filename and create a new one.
  Logging.level (higher value => more logging)
    CRITICAL = 1
    ERROR    = 2
    WARNING  = 3
    INFO     = 4
    DEBUG    = 5
  */
  
  __New(filename, level := 0, truncate := True) {
    this.filename := filename
    this.level := level ? level : 1
    this.label := StrSplit(";CRITICAL;ERROR;WARNING;INFO;DEBUG", ";")
    
    If (truncate && FileExist(this.filename)) {
      FileDelete, % this.filename
      this.log("**Logging.__New**: File deleted (``" . this.filename . "``)")
    }
    FormatTime, timestamp, , yyyy-MM-dd HH:mm:ss
    FileAppend, % "`r`n# " . timestamp . "`r`n", % this.filename
    this.log("**Logging** started (level = " . this.level . ", filename = ``" . this.filename . "``)")
  }
  
  log(message, level := 0, timestamp := True) {
    ;; level = 0 => alaways logged, independent from Logging.level
    If (this.level >= level) {
      i := level + 1
      If (timestamp) {
        FormatTime, timestamp, , yyyy-MM-dd HH:mm:ss
        message := StrPad(timestamp, " ", 19) . "> " . StrPad(this.label[i], ".", 8) . (this.label[i] != "" ? ": " : ". ") . message . "`r`n"
      } Else If (this.label[i] != "") {
        message := StrPad("", " ", 19 + 2) . StrPad(this.label[i], ".", 8) . ": " . message . "`r`n"
      } Else {
        message := StrPad("", " ", 19 + 2 + 8 + 2) . message . "`r`n"
      }
      FileAppend, % message, % this.filename
    }
  }
  critical(message) {
    this.log(message, 1)
  }
  error(message) {
    this.log(message, 2)
  }
  warning(message) {
    this.log(message, 3)
  }
  info(message) {
    this.log(message, 4)
  }
  debug(message) {
    this.log(message, 5)
  }
  
  setLevel(d, level := 0) {
    level := level ? level : this.level
    level := Min(Max(level + d, 1), 5)
    If (level != this.level) {
      this.level := level
      i := level + 1
      this.log("**Logging.setLevel**: " . this.label[i])
    }
  }
}
