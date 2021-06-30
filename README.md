# My [hammerspoon](http://www.hammerspoon.org/) config.

This is working on macOS Big Sur (11.4) and Hammerspoon 0.9.90.

## Window Management

See [a video here](https://youtu.be/OjS6LqKEPcA):

* Hammer+f: Full screen
* Hammer+c: Centered on screen
* Hammer+left: Left Half
* Hammer+right: Right Half
* Hammer+up: Top Half
* Hammer+down: Bottom Half
* Hammer+shift+left: Left 70%
* Hammer+shift+right: Right 70%
* Hammer+option+left: Left 30%
* Hammer+option+right: Right 30%
* Hammer+command+left: Move one screen to the left
* Hammer+commmand+right: Move one screen to the right
* Hammer+s: Maximize ("stretch") vertically

## Shortcuts

* Hammer+g: Open a new Google Chrome window
* Hammer+t: Launch a Terminal
* Hammer+l: Lock screen (additional lock screen bindings in Screen Lock section below)

## What is this "Hammer" key?

`caps lock` is my hammer key, it has a prime location on the keyboard and isn't used very much. I use [Karabiner-Elements](https://github.com/tekezo/Karabiner-Elements) to remap `caps lock` to `F18` (a key unlikely to be used by anything), then in my Hammerspoon config I turn `F18` into a modifier key (like `command`, `shift`, `ctrl`, etc). Then I just hold down `caps lock` and hit `f`, `c`, `left`, `right`, etc.

![How to configure Karabiner-Elements](Karabiner-Elements.png?raw=true "How to configure Karabiner-Elements")

![F18](apple-wireless-keyboard-numeric.png?raw=true "F18")

There might be other ways to do this but this, for example you'll find examples out there of people binding `caps lock` to exotic key modifier combinations (like `cmd`+`alt`+`ctrl`), but I feel the way I do it is straightforward and doesn't accidentally trigger other apps configured to use those modifier key combinations. Plus, I use Karabiner-Elements for other purposes like swapping the option and commands keys on my PC keyboard and binding additional keys to trigger Exposé/Mission Control.

If you don't want to use Karabiner-Elements, and just want to remap your Caps Lock to F18, the following will do the same:

```
hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x70000006D}]}'
```

To undo it:
```
hidutil property --set '{"UserKeyMapping":[]}'
```

See [Hyper Key on Mac without Karabiner](https://www.naseer.dev/post/hidutil/) for how to make it apply on every reboot.


## Screen Lock

Activate with `hammer`+`l`, `F19`, or `eject`.

## Other Stuff

* Mouse button 4 and 5 to perform Back/Forward in Chrome, Slack, Chrome, and Visual Studio for Mac.
