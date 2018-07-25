/*
:title:     bug.n/main
:copyright: (c) 2018 by joten <https://github.com/joten>
:license:   GNU General Public License version 3

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.
*/

;; script settings
#NoEnv                        ;; Recommended for performance and compatibility with future AutoHotkey releases.
OnExit("exitApp")
SendMode Input                ;; Recommended for new scripts due to its superior speed and reliability.
SetBatchLines, -1
SetControlDelay, 0
SetTitleMatchMode, 3
SetTitleMatchMode, Fast
SetWorkingDir %A_ScriptDir%   ;; Ensures a consistent starting directory.
#SingleInstance Force
#Warn                         ;; Enable warnings to assist with detecting common errors.

;; pseudo main function
  app := new Application("bug.n", A_ScriptDir . (SubStr(A_ScriptDir, -3) = "\src" ? "\.." : "") . "\data")
  app.logFilename    := app.varDirName  . "\" . A_ComputerName . "_" . A_UserName . "-log.md"
  app.configFilename := app.dataDirName . "\" . A_ComputerName . "_" . A_UserName . "-config.md"
  app.defaults := app.dataDirName . "\default-config.md"
  logger := new Logging(app.logFilename, app.logLevel)
  config := new Configuration(app.configFilename, app.defaults)
  sys := new System()
  mgr := new Manager()
  logger.log(app.name . " started (working directory: ``" . A_ScriptDir . "``")
Return
;; end of the auto-execute section

;; function, label & object definitions
exitApp() {
  ;; This method can be overwritten after creating the object (?).
  Global app, logger
  
  logger.warning("**exitApp**: Exiting app")
  logger.log(app.name . " ended", 0, False)
}

#Include application.ahk
#Include bar.ahk
#Include configuration.ahk
#Include group.ahk
#Include library.ahk
#Include logging.ahk
#Include manager.ahk
#Include monitor.ahk
#Include rectangle.ahk
#Include shellhook.ahk
#Include stack.ahk
#Include system.ahk
#Include window.ahk
