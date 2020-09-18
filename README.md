# My [hammerspoon](http://www.hammerspoon.org/) config.

This is working on macOS Catalina and Hammerspoon 0.9.78.

## Window Management

See [a video here](https://youtu.be/OjS6LqKEPcA):

* Hotkey+f: Full screen
* Hotkey+c: Centered on screen
* Hotkey+left: Left Half
* Hotkey+right: Right Half
* Hotkey+up: Top Half
* Hotkey+down: Bottom Half
* Hotkey+shift+left: Left 70%
* Hotkey+shift+right: Right 70%
* Hotkey+option+left: Left 30%
* Hotkey+option+right: Right 30%
* Hotkey+s: Maximize ("stretch") vertically

## Shortcuts

* Hotkey+g: Open a new Google Chrome window
* Hotkey+t: Launch a Terminal
* Hotkey+l: Lock screen (additional lock screen bindings in Screen Lock section below)

## Other Stuff
* Mouse button 4 and 5 to Back/Forward in Chrome and Previous/Next channel in Slack

## What is this "Hotkey"?

`caps lock` is my hotkey. I use [Karabiner-Elements](https://github.com/tekezo/Karabiner-Elements) to remap `caps lock` to `F18` (an unused key):

![How to configure Karabiner-Elements](Karabiner-Elements.png?raw=true "How to configure Karabiner-Elements")

![F18](apple-wireless-keyboard-numeric.png?raw=true "F18")

Then in my Hammerspoon config I turn `F18` into a modifier key (like Command, Shift, Control, etc). This allows holding `caps lock` while hitting `f`, `c`, `left`, `right`, etc.

There might be other ways to do this but this, for example you'll find examples out there of people binding `caps lock` to weird key modifier combinations (like `cmd`+`alt`+`ctrl`), but this way is really straightforward and doesn't accidentally trigger other apps that are listening for weird modifier key combinations.

## Screen Lock

Activate with `Hotkey`+`l`, `F19`, or `eject`.
