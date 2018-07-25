/*
:title:     bug.n/window
:copyright: (c) 2018 by joten <https://github.com/joten>
:license:   GNU General Public License version 3

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.
*/

class Window extends Rectangle {
  __New(id, group := "") {
    Global logger, sys
    
    this.id := Format("0x{:x}", id)
    this.caption := True
    this.group := group
    this.wFactor := 1.0
    this.hFactor := 1.0
    
    mem := A_DetectHiddenWindows
    DetectHiddenWindows, On
    WinGetClass, winClass, % "ahk_id " . this.id
    WinGetTitle, winTitle, % "ahk_id " . this.id
    WinGet, winPID, PID, % "ahk_id " . this.id
    WinGet, winPName, ProcessName, % "ahk_id " . this.id
    WinGet, winPPath, ProcessPath, % "ahk_id " . this.id
    WinGet, winStyle, Style, % "ahk_id " . this.id
    WinGet, winExStyle, ExStyle, % "ahk_id " . this.id
    WinGet, winMinMax, MinMax, % "ahk_id " . this.id
    DetectHiddenWindows, % mem
    
    this.class := winClass
    this.title := winTitle
    this.pName := winPName
    this.pPath := winPPath
    this.style := winStyle
    this.exStyle := winExStyle
    this.getPosEx()
    this.minMax := winMinMax
    
    isBar := (this.class = "AutoHotkey" && !(this.style & sys.WS_CAPTION) && this.exStyle & sys.WS_EX_TOOLWINDOW && this.exStyle & sys.WS_EX_TOPMOST)
    this.isAppWindow := InStr(";Button;DesktopBackgroundClass;Progman;Shell_TrayWnd;SysListView32;WorkerW;#32768;", ";" . this.class . ";") && !isBar && !this.isCloaked()
    this.isChild := this.style & sys.WS_CHILD
    this.isElevated := !A_IsAdmin && !DllCall("OpenProcess", UInt, 0x400, Int, 0, UInt, winPID, Ptr)    ;; jeeswg: How would I mimic the windows Alt+Esc hotkey in AHK? (https://autohotkey.com/boards/viewtopic.php?p=134910&sid=192dd8fcd7839b6222826561491fcd57#p134910)
  	this.isPopup := this.style & sys.WS_POPUP
    this.isGhost := this.pPath = "C:\Windows\System32\dwm.exe" && this.class = "Ghost"
    this.isResponding := DllCall("SendMessageTimeout", "UInt", this.id, "UInt", 0x0, "Int", 0, "Int", 0, "UInt", 0x2, "UInt", 150, "UInt *", 0)   ;; 150 = timeout in milliseconds
    
    this.ownerId  := Format("0x{:x}", DllCall("GetWindow", "UInt", this.id, "UInt", sys.GW_OWNER))
    this.parentId := Format("0x{:x}", DllCall("GetParent", "UInt", this.id))
    
    logger.debug("**Window.__New**: [" . this.id . "] " . (this.title ? "``" . this.title . "``" : "_no title_") . ", ``" . this.class . "``")
  }

  eval(rules) {
    Global logger
    
    For i, rule in rules {
      ;; 1 = title,pPath,class; 2 = property (evaluating to true or false)
      ;; 3 = filter (true or false); 4 = icon; 5 = caption; 6 = MinMax; 7 = Window.evalCommand(string)
      haystack := this.title .  "," . this.pPath .  "," . this.class
      needle   := rule[1]
      property := rule[2]
      q1 := this.isHung()
      q2 := RegExMatch(haystack, needle)
      q3 := property ? (SubStr(property, 1, 2) = "0x" ? (property = this.id) : this[property]) : True
      logger.debug("**Window.eval**: rule " . i . " " . needle . " -> " . q2 . " and '" . property . "' -> " . q3 . (q1 ? " _but window is hung_" : ""))
      If q2 && q3 {
        If (!q1 && !rule[5]) {
          this.evalCommand("unsetCaption")
        }
        If (!q1 && rule[6] = +1) {
          this.evalCommand("maximize")
        }
        If (!q1 && rule[6] = -1) {
          this.evalCommand("minimize")
        }
        If (!q1 && rule[7]) {
          this.evalCommand(rule[7])
        }
        logger.debug("**Window.eval**: rule " . i . " applied, " . rule[3] . ";" . rule[4] . ";" . rule[5] . ";" . rule[6] . ";" . rule[7] . "")
        Return, rule[3]
      }
    }
    Return, 1
  }
  
  runCommand(str) {
    Global logger, sys
    
    logger.debug("**Window.evalCommand**: [" . this.id . "] " . str)
    If this.isHung("Window." . str) {
      Return, 1
    } Else If (str = "activate") {
      WinActivate, % "ahk_id " this.id
    } Else If (str = "alwaysOnTopOn") {
      WinSet, AlwaysOnTop, On, % "ahk_id " this.id
    } Else If (str = "alwaysOnTopToggle") {
      WinSet, AlwaysOnTop, Toggle, % "ahk_id " this.id
    } Else If (str = "bottom") {
      WinSet, Bottom,, % "ahk_id " this.id
    } Else If (str = "close") {
      WinClose, % "ahk_id " this.id
    } Else If (str = "setCaption") {
      WinSet, Style, % "+" . sys.WS_CAPTION, % "ahk_id " this.id
      this.caption := True
    } Else If (str = "hide") {
      WinHide, % "ahk_id " this.id
    } Else If (str = "maximize") {
      If (!this.caption) {
        WinSet, Style, % "+" . sys.WS_CAPTION, % "ahk_id " this.id
      }
      If (this.minMax = 1) {
        WinRestore, % "ahk_id " this.id
      }
      WinMaximize, % "ahk_id " this.id
      If (!this.caption) {
        WinSet, Style, % "-" . sys.WS_CAPTION, % "ahk_id " this.id
      }
      this.minMax := 1
    } Else If (str = "minimize") {
      WinMinimize, % "ahk_id " this.id
      this.minMax := -1
    } Else If (str = "restore") {
      WinRestore, % "ahk_id " this.id
      this.minMax := 0
    } Else If (str = "show") {
      WinShow, % "ahk_id " this.id
    } Else If (str = "top") {
      WinSet, Top,, % "ahk_id " this.id
    } Else If (str = "unsetCaption") {
      WinSet, Style, % "-" . sys.WS_CAPTION, % "ahk_id " this.id
      this.caption := False
    }
    Return, 0
  }
  
  getPosEx() {
    Global sys
    Static Dummy5693, RECTPlus
    
    S_OK := 0x0

    ;-- Workaround for AutoHotkey Basic
    PtrType := (A_PtrSize = 8) ? "Ptr" : "UInt"

    ;-- Get the window's dimensions
    ;   Note: Only the first 16 bytes of the RECTPlus structure are used by the
    ;   DwmGetWindowAttribute and GetWindowRect functions.
    VarSetCapacity(RECTPlus, 24,0)
    DWMRC := DllCall("dwmapi\DwmGetWindowAttribute"
        , PtrType, this.id                              ;-- hwnd
        , "UInt",  sys.DWMWA_EXTENDED_FRAME_BOUNDS          ;-- dwAttribute
        , PtrType, &RECTPlus                            ;-- pvAttribute
        , "UInt",  16)                                  ;-- cbAttribute

    If (DWMRC <> S_OK) {
      If ErrorLevel in -3, -4                           ;-- Dll or function not found (older than Vista)
      {                                                 ;-- Do nothing else (for now)
      } Else {
        outputdebug,
          (LTrim Join`s
           Function: %A_ThisFunc% -
           Unknown error calling "dwmapi\DwmGetWindowAttribute".
           RC = %DWMRC%,
           ErrorLevel = %ErrorLevel%,
           A_LastError = %A_LastError%.
           "GetWindowRect" used instead.
          )
      }

      ;-- Collect the position and size from "GetWindowRect"
      DllCall("GetWindowRect", PtrType, this.id, PtrType, &RECTPlus)
    }

    ;-- Populate the output variables
    this.x := Left := NumGet(RECTPlus, 0,  "Int")
    this.y := Top  := NumGet(RECTPlus, 4,  "Int")
    Right          := NumGet(RECTPlus, 8,  "Int")
    Bottom         := NumGet(RECTPlus, 12, "Int")
    this.w         := Right - Left
    this.h         := Bottom - Top
    this.offsetX   := 0
    this.offsetY   := 0

    ;-- If DWM is not used (older than Vista or DWM not enabled), we're done
    If (DWMRC <> S_OK) {
      Return, &RECTPlus
    }

    ;-- Collect dimensions via GetWindowRect
    VarSetCapacity(RECT, 16, 0)
    DllCall("GetWindowRect", PtrType, this.id, PtrType, &RECT)
    GWR_w := NumGet(RECT,  8, "Int") - NumGet(RECT, 0, "Int")   ;-- Right minus Left
    GWR_h := NumGet(RECT, 12, "Int") - NumGet(RECT, 4, "Int")   ;-- Bottom minus Top

    ;-- Calculate offsets and update output variables
    NumPut(this.offsetX := (this.w - GWR_w) // 2, RECTPlus, 16, "Int")
    NumPut(this.offsetY := (this.h - GWR_h) // 2, RECTPlus, 20, "Int")
    
    Return, &RECTPlus
  }
  ;; jballi: [Function] WinGetPosEx v0.1 (Preview) - Get the real position and size of a window (https://autohotkey.com/boards/viewtopic.php?t=3392)
  
  info() {
    str := "ID:      `t" . this.id
    str .= "`nClass:   `t" . this.class
    str .= "`nTitle:   `t" . SubStr(this.title, 1, 64) . (StrLen(this.title) > 69 ? "..." : "")
    str .= "`nProcess: `t" . this.pPath
    str .= "`nStyle:   `t" . this.style
    str .= this.minMax ? "`n         `tis " . (this.minMax = -1 ? "min" : "max") . "imized" : ""
    str .= "`n         `thas " . (!this.caption ? "no " : "") . "title bar (caption)"
    str .= "`nPosition:`t" . this.formatPos()
    Return, s
  }

  isCloaked() {
    Global sys
    
    result := False
    VarSetCapacity(var, A_PtrSize)
    If !DllCall("DwmApi\DwmGetWindowAttribute", "Ptr", this.id, "UInt", sys.DWMWA_CLOAKED, "Ptr", &var, "UInt", A_PtrSize)
      ;; returns S_OK (which is zero) on success, otherwise, it returns an HRESULT error code
      result := NumGet(var)    ;; omitting the "&" performs better
    /* DWMWA_CLOAKED: If the window is cloaked, the following values explain why:
      1  The window was cloaked by its owner application (DWM_CLOAKED_APP)
      2  The window was cloaked by the Shell (DWM_CLOAKED_SHELL)
      4  The cloak value was inherited from its owner window (DWM_CLOAKED_INHERITED)
    */
    Return, result
  }
  ;; ophthalmos: Get last active window resp. all windows in the Alt+Tab list (https://autohotkey.com/boards/viewtopic.php?p=68194&sid=427a7811da17f81ad31bac20af9835d6#p68194)

  isHung(functionName := "") {
    Global logger, sys
    
    mem := A_DetectHiddenWindows
    DetectHiddenWindows, On
    SendMessage, sys.WM_NULL,,,, % "ahk_id " . this.id
    err := ErrorLevel
    DetectHiddenWindows, % mem
    If (err && functionName) {
      logger.warning("**" . functionName . "**: Potentially hung window [" . this.id . "]")
    }

    Return, err
  }
  
  move(x, y, w, h) {
    Global logger, sys
    
    logger.debug("**Window.move**: id = [" . this.id . "] " . this.x . " - " . x . ", " . this.y . " - " . y . ", " . this.w . " - " . w . ", " . this.h . " - " . h)
    If this.isHung("Window.move") {
      Return, 1
    } Else If (this.getPosEx() && this.match(new Rectangle(x, y, w, h))) {
      Return, 0
    }
    
    SendMessage, sys.WM_ENTERSIZEMOVE,,,, % "ahk_id " . this.id
    WinMove, % "ahk_id " . this.id,, %x%, %y%, %w%, %h%
    WinGet, winMinMax, MinMax, % "ahk_id " . this.id
    this.minMax := winMinMax
    If (this.minMax != 1) {
      If (this.getPosEx() && !this.match(new Rectangle(x, y, w, h))) {
        x -= this.x - x
        y -= this.y - y
        w += w - this.w - 1
        h += h - this.h - 1
        WinMove, % "ahk_id " . this.id,, %x%, %y%, %w%, %h%
      }
    }
    SendMessage, sys.WM_EXITSIZEMOVE,,,, % "ahk_id " . this.id
    
    Return, 0
  }
  
  update() {
    Global sys
    
    mem := A_DetectHiddenWindows
    DetectHiddenWindows, On
    WinGetTitle, winTitle, % "ahk_id " . this.id
    WinGet, winStyle, Style, % "ahk_id " . this.id
    WinGet, winExStyle, ExStyle, % "ahk_id " . this.id
    WinGet, winMinMax, MinMax, % "ahk_id " . this.id
    DetectHiddenWindows, % mem
    
    this.title := winTitle
    this.style := winStyle
    this.exStyle := winExStyle
    this.getPosEx()
    this.minMax := winMinMax
    
    this.isChild := this.style & sys.WS_CHILD
    this.isPopup := this.style & sys.WS_POPUP
    this.isResponding := DllCall("SendMessageTimeout", "UInt", this.id, "UInt", 0x0, "Int", 0, "Int", 0, "UInt", 0x2, "UInt", 150, "UInt *", 0)   ;; 150 = timeout in milliseconds
  }
}
