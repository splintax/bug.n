/*
:title:     bug.n/bar
:copyright: (c) 2018 by joten <https://github.com/joten>
:license:   GNU General Public License version 3

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.
*/

class Bar extends Rectangle {
  __New(index, id, data, backColor, fontColor, fontName, fontSize, x, y, w, h, transparency) {
    /*
    The parameter 'i' is the index of the GUI to separate different bars.
    The parameter 'id' is a string, which becomes the window title and part of variable names; it should be a unique string in the context of window titles and variable names.
    The parameter 'data' is an array, containsing arrays for each row and its elements.
    Inner arrays contain objects describing the elements:
    [[{id: <part of the variable name>, text: <string>, progress: <integer between 0 and 100>, backColor: <hexadecimal RGB value>, foreColor: <hexadecimal RGB value>, fontColor: <hexadecimal RGB value>, flex: <True or False (default)>}]]
    An element with 'flex: True' will receive the residual width (difference between the width of the bar and the sum of the elements' width). Only one element per row can have 'flex: True'; if there is more than one element with flex, the last will be the only one with flex; if there is no element with flex, the first and last element will each get half of the residual width.
    */
    
    this.index := index
    this.id := id
    this.data := data
    this.x := x
    this.y := y
    this.w := w

    this.textH := this.getTextHeight(fontName, fontSize)    ;; The height of a text control with the given font results in the minimal bar height.
    this.h := data.Length() * this.textH
    this.h := this.h < h ? h : this.h                       ;; If the specified height of the GUI is less than the calculated hight depending on the fontsize, the GUI height will be reset. The y-position will not be reset.
    
    this.setElementsWidth(fontSize)

    ;; setting the gui window
    Gui, %index%: Default
    Gui, Destroy
    Gui, +AlwaysOnTop -Caption -DPIScale +LastFound +ToolWindow
    Gui, Color, % backColor
    Gui, Font, % "c" . fontColor . " s" . fontSize, % fontName

    ;; adding the elements in order of the array above
    For i, row in this.data {
      For j, element in row {
        this.addElement(element.id, element.text, element.progress, element.backColor, element.foreColor, element.fontColor, element.x, element.y, element.w, element.h)
      }
    }
    Gui, Font, % "c" . fontColor . " s" . fontSize, % fontName

    ;; creating the gui window
    winTitle := this.id
    Gui, Show, % "NoActivate x" . this.x . " y" . this.y . " w" . this.w . " h" . this.h, % winTitle
    this.isVisible := True
    this.winId := WinExist(winTitle)
    WinSet, Transparent, % transparency, % "ahk_id " . this.winId
  }

  __Delete() {
    DllCall("Shell32.dll\SHAppBarMessage", "UInt", (ABM_REMOVE := 0x1), "UInt", &this.appBarData)
    ;; SKAN: Crazy Scripting : Quick Launcher for Portable Apps (http://www.autohotkey.com/forum/topic22398.html)
  }

  addElement(id, text, progress, backColor, foreColor, fontColor, x, y, w, h) {
    textY := Round(y + (h - this.textH) / 2)
    
    index := this.index
    Gui, %index%: Default
    Gui, Add, Progress, % "x" . x . " y" . y . " w" . w . " h" . h . " Background" . backColor . " c" . foreColor . " v" . this.id . "_" . id . "_fore"
    GuiControl, , % this.id . "_" . id . "_fore", % progress
    Gui, Font, % "c" . fontColor
    Gui, Add, Text, % "x" . x . " y" . textY . " w" . w . " h" . this.textH . " BackgroundTrans Center v" . this.id . "_" . id, % text
  }
  
  getTextHeight(fontName, fontSize) {
    Static Ctrl
    
    Gui, 99: Default
    Gui, Font, % "s" . fontSize, % fontName
    Gui, Add, Text, x0 y0 vCtrl, |
    GuiControlGet, Ctrl, Pos
    Gui, Destroy
    CtrlH += 2
    CtrlH *= (A_ScreenDPI / 96)
    Return, CtrlH
  }

  newAppBar() {
    this.appBarMsg := DllCall("RegisterWindowMessage", Str, "AppBarMsg")

    ;; appBarData: http://msdn2.microsoft.com/en-us/library/ms538008.aspx
    VarSetCapacity(this.appBarData, 36, 0)
    offset := NumPut(             36, this.appBarData)
    offset := NumPut(     this.winId, offset+0)
    offset := NumPut( this.appBarMsg, offset+0)
    offset := NumPut(              1, offset+0)
    offset := NumPut(         this.x, offset+0)
    offset := NumPut(         this.y, offset+0)
    offset := NumPut(this.x + this.w, offset+0)
    offset := NumPut(this.y + this.h, offset+0)
    offset := NumPut(              1, offset+0)

    DllCall("Shell32.dll\SHAppBarMessage", "UInt", (ABM_NEW      := 0x0), "UInt", &this.appBarData)
    DllCall("Shell32.dll\SHAppBarMessage", "UInt", (ABM_QUERYPOS := 0x2), "UInt", &this.appBarData)
    DllCall("Shell32.dll\SHAppBarMessage", "UInt", (ABM_SETPOS   := 0x3), "UInt", &this.appBarData)
    ;; SKAN: Crazy Scripting : Quick Launcher for Portable Apps (http://www.autohotkey.com/forum/topic22398.html)
  }

  setElementsWidth(fontSize) {
    ;; calculating the elements' and bar dimensions and position
    rowH := Round(this.h / this.data.Length())
    For i, row in this.data {
      rowW := 0
      flexI := 0
      For j, element in row {
        element.x := rowW
        element.y := (i - 1) * rowH
        element.w := StrWidth(element.text, fontSize) * (A_ScreenDPI / 96)
        element.h := rowH
        rowW += element.w
        If (element.flex) {
          flexI := j
        }
      }
      flexW := w - rowW
      If (flexW >= 0) {
        If (flexI > 0) {
          row[flexI].w += flexW
        } Else {
          row[row.MinIndex()] += Round(flexW / 2)
          row[row.MaxIndex()] += Round(flexW / 2)
        }
      } Else {
        ;; If the sum of the elements' width is larger than the specified width of the GUI, the elements will be equally distributed.
        rowW := 0
        elementW := Round(w / row.Length())
        For j, element in row {
          element.x := rowW
          element.w := elementW
          rowW += element.w
        }
      }
    }
  }

  setVisibility(value := "!") {
    ;; value: 0 = hide, 1 = show, ! = toggle
    this.isVisible := (value = "!") ? !this.isVisible : value

    index := this.index
    Gui, %index%: Default
    If (this.isVisible) {
      this.update()
      Gui, Show
    } Else {
      Gui, Cancel
    }
  }
}

  update(data) {
    ;; Parameter 'data' as described above in '__New'
    For i, row in this.data {
      For j, element in row {
        updateColors := (element.backColor != data[i][j].backColor || element.foreColor != data[i][j].foreColor || element.fontColor != data[i][j].fontColor)
        If (element.text != data[i][j].text || element.progress != data[i][j].progress || updateColors) {
          text     := element.text     != data[i][j].text     ? data[i][j].text     : "?"
          progress := element.progress != data[i][j].progress ? data[i][j].progress : "?"
          backcolor := updateColors ? data[i][j].backColor : "?"
          forecolor := updateColors ? data[i][j].foreColor : "?"
          fontcolor := updateColors ? data[i][j].fontColor : "?"
          updateElement(element.id, text, progress, backColor, foreColor, fontColor)
        }
      }
    }
  }

  updateElement(id, text := "?", progress := "?", backColor := "?", foreColor := "?", fontColor := "?") {
    index := this.index
    Gui, %index%: Default
    If (backColor != "?" && foreColor != "?" && fontColor != "?") {
      GuiControl, % "+Background" . backColor . " +c" . foreColor, % this.id . "_" . id . "_fore"
      GuiControl, % "+c" . fontColor, % this.id . "_" . id
    }
    If (progress != "?") {
      GuiControl,, % this.id . "_" . id . "_fore", % progress
    }
    If (text != "?") {
      GuiControl,, % this.id . "_" . id, % text
    }
  }
