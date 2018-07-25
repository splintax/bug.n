/*
:title:     bug.n/group
:copyright: (c) 2018 by joten <https://github.com/joten>
:license:   GNU General Public License version 3

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.
*/

class Group extends Rectangle {
  __New(x, y, w, h, items := "", direction := 3) {
    /*  x, y: The position, if an area is associated with the group.
        w, h: The dimensions, if an area is associated with the group.
        items: In the last instance of a stack, this is an array of Window objects; before that it is an array of groups and in the next to last instance an array of stacks.
        direction: propagation in the direction of the ...
          1 = x-axis, from left to right
          2 = y-axis, from top to bottom
          3 = z-axis, one on top of each other, all windows the same position and size
    */
    this.x := x
    this.y := y
    this.w := w
    this.h := h
    this.items := (items.Length > 0) ? items : []
    this.direction := direction
    this.wFactor := 1.0
    this.hFactor := 1.0
  }

  activateWindow(indices := "", deltas := "") {
    /* Activate an item in `items`, given by `indices` or by `deltas`, relative to the currently active window.
        * indices: `indices.Length() =  0` ? Get the indices of the currently active window.
                   `indices = [0]` ? the last item of `this.items`; if an index is 0 or negative, it will be interpreted as an offset from the end of `this.items`
        * deltas: [1] = next item (bottom/ right/ first), [-1] = previous item (top/ left/ last) relative to `indices` in the direction given by `this.direction`
        e.g. `indices = [1] && deltas.Length() = 0` ? Activate the first window in a stack.
             `indices = [1] && deltas = [-1] || indices = [0] && deltas = [0]` ? Activate the last window in a stack.
    */
    indices := (indices.Length() > 0) ? indices : this.inGroup(WinExist("A"))
    If (indices.Length() > 0 && (deltas.Length() = indices.Length() || deltas.Length() = 0)) {
      ref := this.getWindowReference(this.items, indices, deltas, True)
      If (ref.index > 0 && ref.stack.Length() > 0) {
        ref.stack[ref.index].runCommand("activate")
      }
    }
  }

  arrange() {
    /* Arrange the windows in all items ans sub-items.
      This method forwards the call until it gets to a stack, which finally can arrange its windows.
    */
    If (this.items[1].HasKey("id")) {
      this.move()
    } Else {
      For i, item in this.items {
        item.arrange()
      }
    }
  }

  getWindowReference(items, indices, deltas, loop := False) {
    /* Go through `items` along `indices` applying `deltas` to get the last group, i.e a stack, with the window given by `index`.
    */
    index := indices.Pop()
    For i, j in indices {
      delta := (deltas.Length() = indices.Length()) ? deltas[i] : 0
      j := j + (j < 1 ? items.Length() : 0)
      If (loop) {
        j := IntLoop(j, delta, 1, items.Length())
      } Else {
        j := Min(Max(j + delta, 1), items.Length())
      }
      items := items[j]
    }
    index := Min(Max(index + (index < 1 ? items.Length() : 0), 1), items.Length())
    If !(items[index].HasKey("id")) {
      index := 0
      stack := []
    }
    Return, {index: index, stack: items}
  }

  getWindows() {
    /* Get the windows in all items and sub-items as a plain array.
      This method forwards the call until it gets to a stack, which finally can return its windows.
    */
    windows := []
    If (this.items[1].HasKey("id")) {
      windows := this.items
    } Else {
      For i, item in this.items {
        windows.push(item.getWindows())
      }
    }
    Return, windows
  }

  inGroup(winId) {
    /* Recursive search for the window given by `winId` in the group's items.
    */
    indices_1 := []
    For j, item in this.items {
      If (item.HasKey("id")) {
        If (item.id = winId) {
          indices_1.push(j)
          Break
        }
      } Else {
        indices_2 := item.inGroup(winId)
        If (indices_2.Length() > 0) {
          indices_1.push(indices_2)
        }
      }
    }
    Return, indices_1
  }

  insertItemsAt(index, value, rearrange := True) {
    /* Insert an item given by `value` at position `index`.
        * index: If an index is 0 or negative, it will be interpreted as an offset from the end of `this.items`; e.g. `index = 0` ? last index
        * value: an object of the same class as the other items; in the last instance this is a window.
        * rearrange: Rearranging the group may be prevented.
      In general groups have a dimension, items do not have to be equally sized and distributed; therefor the other items need to be resized, to fit in the new item.
    */
    index += (index < 1) ? this.items.Length() : 0
    this.items.InsertAt(index, value)
    If (this.direction = 1 || this.direction = 2) {
      factorSum := 0
      For i, item in items {
        factorSum += (this.direction = 1) ? item.wFactor : item.hFactor
      }
      If (this.direction = 1) {
        For i, item in items {
          item.wFactor /= factorSum / items.Length()
        }
      } Else {
        For i, item in items {
          item.hFactor /= factorSum / items.Length()
        }
      }
    }
    If rearrange {
      this.arrange()
    }
  }

  move(x := 0, y := 0, w := 0, h := 0) {
    ;; Move the whole group with all items, re-positioning and -sizing its items, but maintaining the direction.
    this.x := (x != 0) ? x : this.x
    this.y := (y != 0) ? y : this.y
    this.w := (w >  0) ? w : this.w
    this.h := (h >  0) ? h : this.h
    offset := 0
    For i, item in items {
      x := this.x + (this.direction = 1 ? offset : 0)
      y := this.y + (this.direction = 2 ? offset : 0)
      w := this.w * (this.direction = 1 ? item.wFactor / items.Length() : 1)
      h := this.h * (this.direction = 2 ? item.hFactor / items.Length() : 1)
      item.move(x, y, w, h)
      offset += (this.direction = 1) ? w : h
    }
  }

  moveWindow(indices_1 := "", indices_2 := "", deltas := "") {
    /* Move an item in `items`, given by `indices_1` to `indices_2` or by `deltas` relative to the currently active window.
        * indices_1: `indices_1.Length() =  0` ? Get the indices of the currently active window.
                     `indices_1.Length() = [0]` ? the last item of `this.items`; if an index is 0 or negative, it will be interpreted as an offset from the end of `this.items`
        * indices_2: `indices_2.Length() =  0` ? `indices_2 := indices_1`, the currently active window, using deltas to calculate the new indces.
                     `indices_2 = [0]` ? the last item of `this.items`; if an index is 0 or negative, it will be interpreted as an offset from the end of `this.items`
        * deltas: [1] = next item (bottom/ right/ last), -1 = previous item (top/ left/ first) relative to `indices_2` in the direction given by `this.direction`
        e.g. `indices_1 = [] && indices_2 = [1] && deltas =  []` ? Move the currently activate window to the first position in a stack.
             `indices_1 = [0] && indices_2 = [] && deltas = [-1]` ? Move the last window one position in front.
      Items are not moved beyond the bounderies (first/ last).
      Source and target item are not interchanged, but the moving item will be re-inserted at the target position.
    */
    indices_1 := (indices_1.Length() > 0) ? indices_1 : this.inGroup(WinExist("A"))
    indices_2 := (indices_2.Length() > 0) ? indices_2 : indices_1
    If (indices_1.Length() > 0 && (deltas.Length() = indices_2.Length() || deltas.Length() = 0)) {
      ref := this.getWindowReference(this.items, indices_1, [], False)
      index_1 := ref.index
      items_1 := ref.stack
      If (index_1 > 0 && items_1.Length() > 0) {
        value := items_1.RemoveAt(index_1)
        If (items_1 != items_2) {
          items_1.arrange()
        }
        If (value != "") {
          ref := this.getWindowReference(this.items, indices_2, deltas, False)
          index_2 := ref.index
          items_2 := ref.stack
          If (index_2 = 0 && items_2 = 0) {
            index_2 := index_1
            items_2 := items_1
          } Else If (items_1 = items_2) {
            index_2 := (index_1 < index_2) ? index_2 - 1 : index_2
          }
          items_2.InsertAt(index_2, value)
          items_2.arrange()
        }
      }
    }
  }

  removeItemsAt(index, rearrange := True) {
    /* Remove the item at position `index`.
        * index: If an index is 0 or negative, it will be interpreted as an offset from the end of `this.items`; e.g. `index = 0` ? last index
        * rearrange: Rearranging the group may be prevented.
      In general groups have a dimension, items do not have to be equally sized and distributed; therefor the other items need to be resized, to fit in the new item.
    */
    removedItem := ""
    index += (index < 1) ? this.items.Length() : 0
    If (index > 0 && index <= this.items.Length()) {
      removedItem := this.items.RemoveAt(index)
      If (this.direction = 1 || this.direction = 2) {
        factorSum := 0
        For i, item in items {
          factorSum += (this.direction = 1) ? item.wFactor : item.hFactor
        }
        If (this.direction = 1) {
          For i, item in items {
            item.wFactor /= factorSum / items.Length()
          }
        } Else {
          For i, item in items {
            item.hFactor /= factorSum / items.Length()
          }
        }
      }
      If (rearrange && this.items.Length > 0) {
        this.arrange()
      }
    }
    Return, removedItem
  }

  runCommand(str) {
    If InStr(";activate;alwaysOnTopOn;alwaysOnTopToggle;bottom;close;hide;minimize;restore;show;top;", ";" . str . ";") {
      For i, item in this.items {
        item.runCommand(str)
      }
    }
  }

  separate(direction := 0, factor := 0.5, count := 1) {
    /* Split the current group in `direction` with `factor` after `count` items, creating a new group next to it.
        * direction: Split in direction of the ...
            1 = x-axis, vertically
            2 = y-axis, horizontally
            0 => orthogonally to the direction of the group itself.
        * factor: factor > 0 => The new rectangle is at the bottom or to the right of the current group.
        * count: Split the window list after `count` windows; this may be an integer >= 1 or a factor > 0 && <= 1.
      The new group's direction will be copied from the current group.
    */
    group_2 := False
    If (factor > 0 && factor < 1 && count > 0 && count < this.items.Length()) {
      direction := (direction = 1 || direction = 2) ? direction : (this.direction = 1 ? 2 : 1)
      rect := this.split(direction, factor)
      If (rect) {
        group_2 := new Group(rect.x, rect.y, rect.w, rect.h, [], this.direction)
        count := Max(1, Floor(count < 1 ? count * this.items.Length() : count))
        Loop, % (this.items.Length() - count) {
          group_2.push(this.items.RemoveAt(count + 1))
        }
        this.arrange()
      }
    }
    Return, group_2
  }

  setDirection(value := 0, delta := 1) {
    /* Set the group's direction of propagation directly by setting `value` or incrementally by using `delta`.
        * value: `value = 0` ? Get the current direction of `this`.
        * delta: `delta = 1` ? forward loop (1 -> 2 -> 3 -> 1...), `delta = -1` ? backward loop (1 -> 3 -> 2 -> 1...)
    */
    value := value ? value : this.direction
    this.direction := IntLoop(this.direction, delta, 1, 3)
    this.arrange()
  }

  ;; Methods, an extended object like a layout or stack should implement:
  addWindows(values) {
    /* Add one or more items to the group (layout).
        values: An array of one or more items (windows).
      This method should determine the position in the group and/ or sub-groups (indices) and use `this.insertItemAt` to add the values at the specific position in the items array, in the end that is a stack.
    */
  }

  removeWindows(values) {
    /* Remove one or more items from the group.
        values: An array of one or more items, i.e. windows.
      Removing windows may need garbage collection, i.e. removing empty stacks as well and resetting positions and dimensions of items.
    */
  }
}
