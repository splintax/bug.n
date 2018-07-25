/*
:title:     bug.n/system
:copyright: (c) 2018 by joten <https://github.com/joten>
:license:   GNU General Public License version 3

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.
*/

class System {
  __New(physicalDrive := "", networkInterface := "") {
    ;; physicalDrive and networkInterface should be the device names; e.g. physicalDrive may be PhysicalDrive0.

    ;; Windows CONSTANTS
    ;; this.DWMWA_CLOAK         :=  13
    this.DWMWA_CLOAKED       :=  14
    this.DWMWA_EXTENDED_FRAME_BOUNDS := 9
    this.GW_OWNER            :=   4
    this.WM_DISPLAYCHANGE    := 126              ;; This message is sent when the display resolution has changed.
    this.WM_ENTERSIZEMOVE    := 0x00000231
    this.WM_EXITSIZEMOVE     := 0x00000232
    this.WM_NULL             := 0
    this.WS_CAPTION          := 0x00C00000
    this.WS_CHILD            := 0x40000000
    ;; this.WS_CLIPCHILDREN     := 0x2000000
    ;; this.WS_DISABLED         := 0x8000000
    this.WS_EX_APPWINDOW     := 0x0040000
    ;; this.WS_EX_CONTROLPARENT := 0x0010000
    ;; this.WS_EX_DLGMODALFRAME := 0x0000001
    this.WS_EX_TOOLWINDOW    := 0x00000080
    this.WS_EX_TOPMOST       := 0x00000008
    this.WS_POPUP            := 0x80000000
    ;; this.WS_VSCROLL          := 0x200000

    this.HSHELL_WINDOWCREATED        :=  1
    this.HSHELL_WINDOWDESTROYED      :=  2
    ;; this.HSHELL_ACTIVATESHELLWINDOW  :=  3
    this.HSHELL_WINDOWACTIVATED      :=  4
    ;; this.HSHELL_GETMINRECT           :=  5
    this.HSHELL_REDRAW               :=  6
    ;; this.HSHELL_TASKMAN              :=  7
    ;; this.HSHELL_LANGUAGE             :=  8
    ;; this.HSHELL_SYSMENU              :=  9
    ;; this.HSHELL_ENDTASK              := 10
    ;; this.HSHELL_ACCESSIBILITYSTATE   := 11
    ;; this.HSHELL_APPCOMMAND           := 12
    ;; this.HSHELL_WINDOWREPLACED       := 13
    ;; this.HSHELL_WINDOWREPLACING      := 14
    ;; this.HSHELL_HIGHBIT              := 15?
    ;; this.HSHELL_FLASH                := 16?
    ;; this.HSHELL_RUDEAPPACTIVATED     := 17?
    ;; this.HSHELL_HIGHBIT              := 32768    ;; 0x8000
    ;; this.HSHELL_FLASH                := 32774    ;; (HSHELL_REDRAW|HSHELL_HIGHBIT)
    this.HSHELL_RUDEAPPACTIVATED     := 32772    ;; (HSHELL_WINDOWACTIVATED|HSHELL_HIGHBIT)

    this.COLOR_ACTIVECAPTION           :=  2
    this.COLOR_INACTIVECAPTION         :=  3
    this.COLOR_MENU                    :=  4
    this.COLOR_MENUTEXT                :=  7
    this.COLOR_CAPTIONTEXT             :=  9
    this.COLOR_HIGHLIGHT               := 13
    this.COLOR_INACTIVECAPTIONTEXT     := 19
    this.COLOR_GRADIENTACTIVECAPTION   := 27
    this.COLOR_GRADIENTINACTIVECAPTION := 28

    If (physicalDrive != "") {
      this.hDrive := DllCall("CreateFile", "Str", "\\.\" . physicalDrive . "", "UInt", 0, "UInt", 3, "UInt", 0, "UInt", 3, "UInt", 0, "UInt", 0)
    }

    If (networkInterface != "") {
      objWMIService := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" . A_ComputerName . "\root\cimv2")
      WQLQuery := "SELECT * FROM Win32_PerfFormattedData_Tcpip_NetworkInterface WHERE Name LIKE '%" . networkInterface . "%'"
      this.networkInterface := objWMIService.ExecQuery(WQLQuery).ItemIndex(0)
    }
  }

  __Delete() {
    If (this.hDrive) {
      DllCall("CloseHandle", "UInt", this.hDrive)
    }
  }

  colors[] {
    get {
      colors := {}
      colors[activeCaption]           := BGRToRGB(DllCall("GetSysColor", "Int", this.COLOR_ACTIVECAPTION))
      colors[inactiveCaption]         := BGRToRGB(DllCall("GetSysColor", "Int", this.COLOR_INACTIVECAPTION))
      colors[menu]                    := BGRToRGB(DllCall("GetSysColor", "Int", this.COLOR_MENU))
      colors[menuText]                := BGRToRGB(DllCall("GetSysColor", "Int", this.COLOR_MENUTEXT))
      colors[captionText]             := BGRToRGB(DllCall("GetSysColor", "Int", this.COLOR_CAPTIONTEXT))
      colors[highlight]               := BGRToRGB(DllCall("GetSysColor", "Int", this.COLOR_HIGHLIGHT))
      colors[inactiveCaptionText]     := BGRToRGB(DllCall("GetSysColor", "Int", this.COLOR_INACTIVECAPTIONTEXT))
      colors[gradientActiveCaption]   := BGRToRGB(DllCall("GetSysColor", "Int", this.COLOR_GRADIENTACTIVECAPTION))
      colors[gradientInactiveCaption] := BGRToRGB(DllCall("GetSysColor", "Int", this.COLOR_GRADIENTINACTIVECAPTION))
      
      Return, colors
    }
  }

  cpuLoad[] {
    get {
      ;; Total CPU Load
      Static idleTime_2, krnlTime_2, userTime_2

      idleTime_1 := idleTime_2
      krnlTime_1 := krnlTime_2
      userTime_1 := userTime_2
    
      DllCall("GetSystemTimes", "Int64P", idleTime_2, "Int64P", krnlTime_2, "Int64P", userTime_2)
      sysTime := Round((1 - (idleTime_2 - idleTime_1) / ((krnlTime_2 - krnlTime_1) + (userTime_2 - userTime_1))) * 100)
      Return, {value: sysTime, unit: "%"}   ;; system time in percent
    }
    ;; Sean: CPU LoadTimes (http://www.autohotkey.com/forum/topic18913.html)
  }

  diskLoad[] {
    get {
      Static rCount_2, wCount_2

      rCount_1 := rCount_2
      wCount_1 := wCount_2

      varCapacity := 5 * 8 + 4 + 4 + 4 + 4 + 8 + 4 + 8 * (A_IsUnicode ? 2 : 1) + 12    ;; 88?
      VarSetCapacity(var, varCapacity)
      DllCall("DeviceIoControl", "UInt", this.hDrive, "UInt", 0x00070020, "UInt", 0, "UInt", 0, "UInt", &var, "UInt", varCapacity, "UIntP", 0, "UInt", 0)   ;; IOCTL_DISK_PERFORMANCE
      rCount_2 := NumGet(var, 40)
      wCount_2 := NumGet(var, 44)
      rLoad := Round((1 - 1 / (1 + rCount_2 - rCount_1)) * 100)
      wLoad := Round((1 - 1 / (1 + wCount_2 - wCount_1)) * 100)

      Return, {read: {value: rLoad, unit: "%"}, write: {value: wLoad, unit: "%"}}
    }
    ;; fures: System + Network monitor - with net history graph (http://www.autohotkey.com/community/viewtopic.php?p=260329)
    ;; SKAN: HDD Activity Monitoring LED (http://www.autohotkey.com/community/viewtopic.php?p=113890&sid=64d9824fdf252697ff4d5026faba91f8#p113890)
  }

  memoryLoad[] {
    get {
      VarSetCapacity(memoryStatus, 4 + 4 + 4 + 4 + 4 + 4 + 4 + 4)
      DllCall("kernel32.dll\GlobalMemoryStatus", "UInt", &memoryStatus)
      Return, {value: Round(*(&memoryStatus + 4)), unit: "%"}   ;; LS byte is enough, 0..100
    }
    ;; fures: System + Network monitor - with net history graph (http://www.autohotkey.com/community/viewtopic.php?p=260329)
  }

  networkLoad[] {
    get {
      this.networkInterface.Refresh_
      dLoad := FormatBytes(this.networkInterface.BytesReceivedPerSec)
      uLoad := FormatBytes(this.networkInterface.BytesSentPerSec)
      dLoad.unit .= "/s"
      uLoad.unit .= "/s"

      Return, {download: dLoad, upload: uLoad}
    }
    ;; Pillus: System monitor (HDD/Wired/Wireless) using keyboard LEDs (http://www.autohotkey.com/board/topic/65308-system-monitor-hddwiredwireless-using-keyboard-leds/)
  }

  powerStatus[] {
    get {
      Global logger
      
      VarSetCapacity(powerStatus, (1 + 1 + 1 + 1 + 4 + 4))
      If (DllCall("GetSystemPowerStatus", "UInt", &powerStatus) && ErrorLevel = 0) {
        acLineStatus := NumGet(powerStatus, 0, "Char")
        batteryLife  := NumGet(powerStatus, 2, "Char")
      } Else {
        logger.error("**System.battery.get**: Cannot get the power status")
        acLineStatus := batteryLife := 255
      }
      acLineStatus := (acLineStatus = 0) ? "off" : (acLineStatus = 1) ? "on" : "?"
      batteryLife  := (batteryLife = 255) ? "???" : batteryLife

      Return, {batteryLife: {value: batteryLife, unit: "%"}, acLineStatus: acLineStatus}
    }
  }
  ;; PhiLho: AC/Battery status (http://www.autohotkey.com/forum/topic7633.html)
}
