# bug.n default configuration

This reflects the default configuration, which is effectively used, if no
`A_ComputerName_A_UserName-config.md` is found.

Using the hotkey <kbd>Win</kbd><kbd>Ctrl</kbd><kbd>S</kbd> copies the content
of this file to the computer and user specific configuration file,
`A_ComputerName_A_UserName-config.md`, and inserts the current values for
those variables, which are active, i.e. on a new line and with `    ` in front
of them.

The general format for a valid configuration line begins with `    `; only
lines beginning with `    ` are evaluated. All values are written without
quotation marks; `False` is written as `0` and `True` is written as `1`.

You may disable variables by removing the prefixing `    `, change values or
remove them, if you want to let bug.n reset them with the current values the
next time you use the hotkey <kbd>Win</kbd><kbd>Ctrl</kbd><kbd>S</kbd>.


## Variables

barBackColor=000000
barFontColor=ffffff
barFontName=Lucida Console

barFontSize=8
> The font size of bar elements in pt.

barOpacity=192
> The degree of transparency of bars: 0 makes the window invisible, while 255
makes it opaque.

> On each monitor a status bar is shown. The *bar* values above and the
statusBar* values below are used for all of them, but the values below are
relative to the position and dimensions of the monitor, they are located on.

statusBarPosX=0
statusBarPosY=0
> The position of status bars. Positive values are interpreted as the offset of
the top left corner of the bar from the top left corner of the monitor,
negative as the offset of the bottom right corner of the bar from the bottom
right corner of the monitor (e.g. `statusBarPosY=0` positions it at the bottom
of the screen).

> The statusBar* values above and below are used as follows:
* Integer values as pixels.
* Floating point values are multiplied with the associated monitor dimension.

statusBarWidth=1.0
statusBarHeight=10
> The dimensions of the bar.

statusBarUpdateInterval=60000
> The time in milliseconds, after which the status bar's contents are updated.

> If one of the following statusBarShow* values is not 0, the corresponding
field is shown in the status bar.

statusBarShowCPU=0

statusBarShowDate=ddd. dd. MMM. yyyy
> A date format as described in [autohotkey.com/docs/commands/FormatTime](https://autohotkey.com/docs/commands/FormatTime.htm).

statusBarShowDisk=0
> If not zero, this should be a drive name e.g. "PhysicalDrive0".

statusBarShowMemory=0

statusBarShowNetwork=0
> If not zero, this should be a device name of a network interface e.g.
"Centrino".

statusBarShowPower=0

statusBarShowTime=HH:mm
> A time format as described in [autohotkey.com/docs/commands/FormatTime](https://autohotkey.com/docs/commands/FormatTime.htm).

statusBarShowVolume=0

## Hotkeys

