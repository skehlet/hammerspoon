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
* Hotkey+shift+left: Left 62% (Inspired by [the Golden Ratio](https://en.wikipedia.org/wiki/Golden_ratio))
* Hotkey+shift+right: Right 62%
* Hotkey+option+left: Left 38%
* Hotkey+option+right: Right 38%

## Shortcuts

* Hotkey+g: Open a new Google Chrome window
* Hotkey+t: Launch a Terminal
* Hotkey+l: Lock screen

## Other Stuff
* Mouse button 4 and 5 to Back/Forward in Chrome and Previous/Next channel in Slack
* Hotkey + NumPad 1,4,7,3,6,9: Bottom left, left, top left, bottom right, right, top right.

## What is this "Hotkey"?

`caps lock` is my hotkey. I use [Karabiner-Elements](https://github.com/tekezo/Karabiner-Elements) to remap `caps lock` to `F18` (an unused key):

![How to configure Karabiner-Elements](Karabiner-Elements.png?raw=true "How to configure Karabiner-Elements")

Then in my Hammerspoon config I turn `F18` into a modifier key (like Command, Shift, Control, etc):

![F18](apple-wireless-keyboard-numeric.png?raw=true "F18")

This allows holding `caps lock` while hitting `f`, `c`, `left`, `right`, etc. There might be other ways to do this but this, for example you'll find examples out there of people binding `caps lock` to weird key modifier combinations (like `cmd`+`alt`+`ctrl`), but this way is really straightforward and doesn't accidentally trigger other apps that are listening for weird modifier key combinations.

## Screen Lock

Activate with `Hotkey`+`l`, `F19`, or `eject`.

## Logitech G600 Support

Using the Logitech G Hub software, I remapped the extra ring finger button to `F17`, and then remap `F17`'s down and up keypresses to the Mission Control key.

![Logitech G600 ring finger button remap in Logitech G Hub](logitech-g600-ring-finger-button.png?raw=true "Logitech G600 ring finger button remap in Logitech G Hub")

**Important note:** When using Karabiner-Elements, you need to uncheck both entries for the Logitech G600 ("Gaming Mouse G600 (Logitect)") under Devices, otherwise it seems to capture all the events and Hammerspoon doesn't get them.

![Karabiner Elements with G600 devices disabled](Karabiner-Elements-with-G600-disabled.png?raw=true "Karabiner Elements with G600 devices disabled")