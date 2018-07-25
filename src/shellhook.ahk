/*
:title:     bug.n/shellhook
:copyright: (c) 2018 by joten <https://github.com/joten>
:license:   GNU General Public License version 3

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.
*/

class ShellHook {
  __New(winId := 0) {
    ;; winId is the window's id, which will receive the SHELLHOOK window messages.
    Global logger, sys

    this.wnd := new Window(winId ? winId : WinExist())
    logger.info("**ShellHook** registered to window (id = " . this.wnd.id . ", class = " . this.wnd.class . ", title = " . this.wnd.title . ")")
  
    DllCall("RegisterShellHookWindow", "UInt", this.wnd.id)    ;; Minimum operating systems: Windows 2000 (http://msdn.microsoft.com/en-us/library/ms644989(VS.85).aspx)
    msgNumber := DllCall("RegisterWindowMessage", "Str", "SHELLHOOK")
    If (msgNumber = sys.WM_DISPLAYCHANGE) {
      OnMessage(msgNumber, this.onDisplayChange)
    } Else {
      OnMessage(msgNumber, ObjBindMethod(this, "onShellMessage"))
    }
  }
  ;; SKAN: How to Hook on to Shell to receive its messages? (http://www.autohotkey.com/forum/viewtopic.php?p=123323#123323)

  __Delete() {
    DllCall("DeregisterShellHookWindow", "UInt", this.wnd.id)
  }

  onDisplayChange(hWnd, wParam, uMsg, lParam) {
    ;; This method can be overwritten after creating the object.
    Global logger

    logger.info("**ShellHook.onDisplayChange**: hWnd = " . hWNd . ", uMsg = " . uMsg . ", wParam = " . wParam . ", lParam = " . lParam)
    MsgBox, 291, , % "Would you like to reset the monitor configuration?`n'No' and 'Cancel' will result in no change."
    IfMsgBox Yes
    {
    }
  }

  onShellMessage(wParam, lParam) {
    ;; This method can be overwritten after creating the object.
    Global logger, sys

    lParam := Format("0x{:x}", lParam)
    logger.debug("**ShellHook.onShellMessage**: wParam = " . wParam . ", lParam = " . lParam)
    If (wParam = sys.HSHELL_WINDOWCREATED) {
    } Else If (wParam = sys.HSHELL_WINDOWDESTROYED) {
    } Else If (wParam = sys.HSHELL_WINDOWACTIVATED) {
    } Else If (wParam = sys.HSHELL_REDRAW) {
    } Else If (wParam = sys.HSHELL_RUDEAPPACTIVATED) {
    }
  }
}
