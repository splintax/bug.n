/*
:title:     bug.n/manager
:copyright: (c) 2018 by joten <https://github.com/joten>
:license:   GNU General Public License version 3

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.
*/

class Manager {
  __New() {
    Global config, logger
    
    this.monitors := []
    this.bars     := []
    this.windows  := {}
    
    SysGet, n, MonitorCount
    logger.info("Number of **monitors** found: " . n)
    Loop, % n {
      this.monitors[A_Index] := new Monitor(A_Index)
      logger.debug("**Manager.__New**: monitor   " . A_Index . ", name = '" . this.monitors[A_Index].name . "'")
      logger.debug("**Manager.__New**: monitor   " . A_Index . ", " . this.monitors[A_Index].formatPos())
      logger.debug("**Manager.__New**: work area " . A_Index . ", " . this.monitors[A_Index].workArea.formatPos())
    }

    data := this.statusBarData[]
    For i, m in this.monitors {
      w := (RegExMatch(config.statusBarWidth,  "O)(\d+\.\d+)", factor) ? factor.Value(1) * m.w : config.statusBarWidth)
      h := (RegExMatch(config.statusBarHeight, "O)(\d+\.\d+)", factor) ? factor.Value(1) * m.h : config.statusBarHeight)
      x := m.x + (RegExMatch(config.statusBarPosX, "O)(-?\d+\.\d+)", factor) ? factor.Value(1) * m.w : config.statusBarPosX)
      x += (RegExMatch(config.statusBarPosX, "O)^-\d") ? m.w - w : 0)
      y := m.y + (RegExMatch(config.statusBarPosY, "O)(-?\d+\.\d+)", factor) ? factor.Value(1) * m.h : config.statusBarPosY)
      y += (RegExMatch(config.statusBarPosY, "O)^-\d") ? m.h - h : 0)
      this.bars[i] := new Bar(i, "bar_" . i, data, config.barBackColor, config.barFontColor, config.barFontName, config.barFontSize, x, y, w, h, config.barOpacity)
    }
    timer := ObjBindMethod(this, "updateStatusBars")
    SetTimer, % timer, % config.statusBarUpdateInterval

    evtMgr := new ShellHook(this.bars[1].winId)
  }

  __Delete() {
    For i, wnd in this.windows {
      If (WinExist("ahk_id " . wnd.id) && !wnd.caption) {
        wnd.runCommand("setCaption")
      }
    }
  }

  statusBarData[] {
    get {
      Global config

      ;; [[{id: , text: , progress: , backColor: , foreColor: , fontColor: , flex: }]]
      
    }
  }

  updateStatusBars() {
    data := this.statusBarData[]
    For i, obj in this.bars {
      obj.update(data)
    }
  }
}
