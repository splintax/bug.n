/*
:title:     bug.n/monitor
:copyright: (c) 2018 by joten <https://github.com/joten>
:license:   GNU General Public License version 3

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.
*/

class Monitor extends Rectangle {
  __New(index) {
    this.index := index
    this.isPrimary := False
    SysGet, name, MonitorName, % index
    this.name := name

    SysGet, m, Monitor, % index
    this.x := mLeft
    this.y := mTop
    this.w := mRight - mLeft
    this.h := mBottom - mTop
    this.id := this.x . "-" . this.y . "_" . this.w . "x" . this.h

    this.workArea := new WorkArea(index)
  }
}

class WorkArea extends Rectangle {
  __New(index) {
    SysGet, m, MonitorWorkArea, % index
    this.x := mLeft
    this.y := mTop
    this.w := mRight - mLeft
    this.h := mBottom - mTop
  }
}
