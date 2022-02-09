# My [hammerspoon](http://www.hammerspoon.org/) config.

This is working on macOS Monterey (12.2) and Hammerspoon 0.9.93.

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

`caps lock` is my hammer key, it has a prime location on the keyboard for a key that isn't used very much, if ever. I use [Karabiner-Elements](https://github.com/tekezo/Karabiner-Elements) to remap `caps lock` to `F18` (a key unlikely to be used by anything), then in my Hammerspoon config I turn `F18` into a modifier key (like `command`, `shift`, `ctrl`, etc). Then I just hold down `caps lock` and hit `f`, `c`, `left`, `right`, etc.

![How to configure Karabiner-Elements](Karabiner-Elements.png?raw=true "How to configure Karabiner-Elements")

![F18](apple-wireless-keyboard-numeric.png?raw=true "F18")

There might be other ways to do this but this, for example you'll find examples out there of people binding `caps lock` to exotic key modifier combinations (like `cmd`+`alt`+`ctrl`), but I feel this way is straightforward and doesn't accidentally trigger other apps configured to use those modifier key combinations. Plus, I use Karabiner-Elements for other purposes like swapping the option and commands keys on my PC keyboard and binding additional keys to trigger Exposé/Mission Control.

If you don't want to use Karabiner-Elements, and just want to remap your Caps Lock to F18, the following will do the same:

```
hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x70000006D}]}'
```

To undo it:
```
hidutil property --set '{"UserKeyMapping":[]}'
```

See [Hyper Key on Mac without Karabiner](https://www.naseer.dev/post/hidutil/) for how to make it apply on every reboot.

## How is your "Hammer" key different than a "Hyper" key?

There are plenty of Hammerspoon examples of creating a "hyper" key where you press and release a key (e.g. `caps lock`), or combination of keys, and then hit another button to do what you want. If that keypress flow works better for you, great, but I've never really used a computer that way. The "hammer key" approach simply creates another modifier key that allows new key combinations (e.g. `hammer`+`g`) that are guaranteeed not to conflict with existing keybindings.


## Why does my Hammer key sometimes stop working?

I finally got to the root of this problem: macOS can sometimes enter a state of "secure input" where tools like Hammerspoon, TextExpander, Keyboard Maestro, Alfred, etc, are unable to intercept keypresses. This is a security feature, so keyloggers can't sniff your password input. This is great, except for when it activates unexpectedly in the background, for example, when you get auto-logged out of a website, redirected to a login page, auto-focused on a password field, and your LastPass extension for Chrome kicks in. I am currently testing out disabling LastPass' auto-fill feature (Chrome -> LastPass -> Account Options -> Extension Preferences, uncheck Automatically fill login information) to see if this goes away for good.

Otherwise, a quick workaround is to lock screen (`hammer`+`l`) and touch-id back in. Some have reporting clicking on the LastPass extension in Chrome may undo it as well. You can run `hs.eventtap.isSecureInputEnabled()` in the Hammerspoon console to see if secure input is currently enabled.


## External monitor swapping issues

Recently, since getting some new equipment, I've found that my two (identical) external monitors will randomly swap places. It seems to be a race condition, e.g. the order in which they wake up and register with macOS. This and many other similar problems I found googling around seems to be a major issue with macOS keeping track of displays and their positions. My issue may be that the serial number reported by the monitors (`ioreg -lw0 | grep DisplayAttributes | grep SerialNumber`) are identical.

I've added a Python script, based on [this very helpful Ask Different post](https://apple.stackexchange.com/a/48977/10204), to swap them. Note that I first tried to do this just with Hammerspoon's `hs.screen` APIs, however I found that moving screens around individually caused a lot of window chaos (resizing and repositioning). The Python script uses the Quartz APIs and are able to move the screens in a single API call, which has the effect of leaving all the windows unchanged. This is only a quick workaround, hopefully macOS fixes this, or I can find another way.

## Screen Lock

Activate with `hammer`+`l`, or other hotkeys like `F19` or `Pause` (see the code).

## Other Stuff

* Mouse button 4 and 5 to perform Back/Forward in Chrome, Slack, Chrome, and Visual Studio for Mac.
