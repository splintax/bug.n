/*
:title:     bug.n/stack
:copyright: (c) 2018 by joten <https://github.com/joten>
:license:   GNU General Public License version 3

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.
*/
/*
class Stack extends Group {
  /* __New(x, y, w, h, items := [], direction := 3)
    A stack must have a position, dimensions and items (i.e. windows).
  */
/*
  activateWindow(index := 0, delta := 0) {
    index := index != 0 ? (index = -1 ? this.items.Length() : index) : this.inGroup(WinExist("A"))
    i := IntLoop(index, delta, 1, this.items.Length())
    If (i > 0) {
      this.items[i].runCommand("activate")
    }
  }

  arrange() {
    this.move()
  }

  getWindows() {
    Return, this.items
  }

  moveWindow(index_1 := 0, index_2 := 0, delta := 0) {
    index_1 := index_1 != 0 ? (index_1 = -1 ? this.items.Length() : index_1) : this.inGroup(WinExist("A"))
    index_2 := index_2 != 0 ? (index_2 = -1 ? this.items.Length() : index_2) : index_1
    If (index_1 > 0 && index <= this.items.Length()) {
      j := Min(Max(index_2 + d, 1), this.items.Length())
      If (j > 0 && j != index_1) {
        j := (index_1 < j) ? j - 1 : j
        this.items.RemoveAt(index_1)
        this.items.InsertAt(j)
        this.arrange()
      }
    }
  }
}*/
