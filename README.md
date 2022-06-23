# My [hammerspoon](http://www.hammerspoon.org/) config.

This is working on macOS Monterey (12.2) and Hammerspoon 0.9.93.

## Window Management via keypresses

Focus on a window and press one of the following key combinations. See [a video here](https://youtu.be/OjS6LqKEPcA).

* `hammer`+`f`: Full screen
* `hammer`+`c`: Centered on screen
* `hammer`+`left`: Left Half
* `hammer`+`right`: Right Half
* `hammer`+`up`: Top Half
* `hammer`+`down`: Bottom Half
* `hammer`+`shift`+`left`: Left 70%
* `hammer`+`shift`+`right`: Right 70%
* `hammer`+`option`+`left`: Left 30%
* `hammer`+`option`+`right`: Right 30%
* `hammer`+`command`+`left`: Move one screen to the left
* `hammer`+`commmand`+`right`: Move one screen to the right
* `hammer`+`s`: Maximize ("stretch") vertically

## Shortcuts

* `hammer`+`g`: Open a new Google Chrome window
* `hammer`+`t`: Launch a Terminal
* `hammer`+`l`: Lock screen (additional lock screen bindings in Screen Lock section below)

## What is this "Hammer" key?

`Caps Lock` is my chosen Hammer key, it has a prime location on the keyboard for a key that isn't used very much.

## How do I turn Caps Lock into a Hammer key?

Hammerspoon can't intercept Caps Lock reliably for various technical reasons, e.g. it's a toggle on/off, may have an LED, etc. So instead, I use [Karabiner-Elements](https://github.com/tekezo/Karabiner-Elements) to remap `caps lock` to `F18` (another key unlikely to be used by anything). Then it's easy via Hammerspoon to to turn `F18` into a modifier key (like `command`, `shift`, `ctrl`, etc) and assign keybindings.

Then you just hold down the Hammer (`caps lock`) and hit `f`, `c`, `left`, or `right`, etc.

![How to configure Karabiner-Elements](Karabiner-Elements.png?raw=true "How to configure Karabiner-Elements")

## How is your "Hammer" key different than a "Hyper"/Modal key?

There are plenty of Hammerspoon examples of creating a "hyper" key where you press *and release* a key (e.g. `caps lock`) and then hit another button to do what you want. If that keypress flow works better for you, great, but I've never really used a computer that way (except for some strange Emacs combinations when I used it a long time ago). The "hammer key" approach simply creates another modifier key that allows new key combinations (e.g. `hammer`+`g`) that are quick and easy to press, and has the bonus over some hyper key implementations (e.g. that use exotic combinations of `cmd`+`option`+`ctrl`) that they're guaranteeed not to accidentally trigger existing application keybindings.

## Why does my Hammer key sometimes stop working?

See [hammerspoon#1743](https://github.com/Hammerspoon/hammerspoon/issues/1743): macOS can sometimes enter a state of "secure input" where tools like Hammerspoon, TextExpander, Keyboard Maestro, Alfred, etc, are unable to intercept keypresses. This is a security feature, so keyloggers can't sniff your password input. This is great, except for when it activates unexpectedly in the background, for example, when you get auto-logged out of a website, redirected to a login page, auto-focused on a password field, and your LastPass extension for Chrome kicks in. You can avoid this problem by disabling LastPass' auto-fill feature (Chrome -> LastPass -> Account Options -> Extension Preferences, uncheck Automatically fill login information). Or, a quick workaround is to lock screen (`hammer`+`l`) and touch-id back in. Some have reporting clicking on the LastPass extension in Chrome may undo it as well. You can run `hs.eventtap.isSecureInputEnabled()` in the Hammerspoon console to see if secure input is currently enabled.


## External monitor swapping issues

I have a keybindings to run `displayplacer` to swap my external monitors. Sometimes after waking my laptop up from sleep, it gets the two mixed up (they're identical make/model).

## Screen Lock

Activate with `hammer`+`l`, or other hotkeys like `F19` or `Pause` (see the code).

## Other Stuff

* Mouse button 4 and 5 to perform Back/Forward in Chrome, Slack, Chrome, and Visual Studio for Mac.
* Hammer+mouse4 or mouse4 to move windows to left/right half
* Caffeine equivalent
* Microphone and speaker indicators to confirm my Airpods are the active input/output
