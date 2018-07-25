/*
:title:     bug.n/rectangle
:copyright: (c) 2018 by joten <https://github.com/joten>
:license:   GNU General Public License version 3

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.
*/

class Rectangle {
  __New(x := 0, y := 0, w := 0, h := 0) {
    this.x := x
    this.y := y
    this.w := w
    this.h := h
  }

  match(rect, delta := 2) {
    If (rect.w = 0 || rect.h = 0) {
      Return, (this.x <= rect.x && this.y <= rect.y && this.x + this.w >= rect.x && this.y + this.h >= rect.y)
    } Else {
      Return, (Abs(this.x - rect.x) < delta && Abs(this.y - rect.y) < delta && Abs(this.w - rect.w) < delta && Abs(this.h - rect.h) < delta)
    }
  }

  formatPos() {
    str := "x = " . StrPad(this.x, " ", -4) . ", y = " . StrPad(this.y, " ", -4) . ", width = "
    str .= StrPad(this.w, " ", -4) . ", height = " . StrPad(this.h, " ", -4)
    Return, str
  }

  split(direction := 0, factor := 0) {
    /* Split the rectangle in `direction`            with `factor`, creating a new rectangle with (1 - factor)
                                1 = x-axis, vertical      * width                                 * width of the current rectangle
                                2 = y-axis, horizontal    * height                                * height of the current rectangle
        factor > 0 => The new rectangle is at the bottom or to the right of the current rectangle.
    */
    rect := False
    If (factor > 0 && factor < 1) {
      If (direction = 1) {
        y := this.y
        h := this.h
        w := Round((1 - factor) * this.w)
        this.w := this.w - w
        x := this.x + this.w
      } Else If (direction = 2) {
        x := this.x
        w := this.w
        h := Round((1 - factor) * this.h)
        this.h := this.h - h
        y := this.y + this.h
      }
      rect := new Rectangle(x, y, w, h)
    }
    Return, rect
  }
}
