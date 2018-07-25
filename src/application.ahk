/*
:title:     bug.n/application
:copyright: (c) 2018 by joten <https://github.com/joten>
:license:   GNU General Public License version 3

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.
*/

class Application {
  __New(name, dataDirName) {
    this.name := name
    this.dataDirName := dataDirName
    this.logLevel := 0

    If (A_Args.Length() > 0) {
      this.dataDirName := RTrim(A_Args[1], " `t\")
      If (A_Args.Length() > 1) {
        this.logLevel := RegExMatch(A_Args[2], "[1-5]") ? A_Args[2] : 0
      }
    }
    
    this.varDirName := this.dataDirName . "\var"
    this.verifyDir(this.dataDirName)
    this.verifyDir(this.varDirName)

    Menu, Tray, Tip, % this.name
    If (A_IsCompiled) {
      Menu, Tray, Icon, %A_ScriptFullPath%, -159
    } Else If FileExist(A_ScriptDir . "\..\icon.ico") {
      Menu, Tray, Icon, % A_ScriptDir . "\..\icon.ico"
    }
    Menu, Tray, MainWindow
  }

  __Delete() {
    Global logger
    logger.warning("**Application.__Delete**: Exiting app")
  }

  verifyDir(dirName) {
    If !FileExist(dirName) {
      FileCreateDir, % dirName
      If (ErrorLevel = 1) {
        MsgBox, 16, % this.name . "Error: " . A_LastError, % "The directory '" . dirName . "' could not be created.`n=> The log file cannot be written. Aborting."
        ExitApp
      }
    } Else If !InStr(FileExist(dirName), "D") {
      MsgBox, 16, % this.name . "Error", % "The filepath '" . dirName . "' does exist, but is not a directory.`n=> The log file cannot be written. Aborting."
      ExitApp
    }
  }
}
