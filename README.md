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

I finally got to the root of this problem: macOS can sometimes enter a state of "secure input" where tools like Hammerspoon, TextExpander, Keyboard Maestro, Alfred, etc, are unable to intercept keypresses. This is a security feature, so keyloggers can't sniff your password input. This is great, except for when it activates unexpectedly in the background, for example, when you get auto-logged out of a website, redirected to a login page, auto-focused on a password field, and your LastPass extension for Chrome kicks in. I am currently testing out disabling LastPass' auto-fill feature (Chrome -> LastPass -> Account Options -> Extension Preferences, uncheck Automatically fill login information) to see if this goes away for good.

Otherwise, a quick workaround is to lock screen (`hammer`+`l`) and touch-id back in. Some have reporting clicking on the LastPass extension in Chrome may undo it as well. You can run `hs.eventtap.isSecureInputEnabled()` in the Hammerspoon console to see if secure input is currently enabled.


## External monitor swapping issues

Recently, since getting some new equipment, I've found that my two (identical) external monitors will randomly swap places. It seems to be a race condition, e.g. the order in which they wake up and register with macOS. This and many other similar problems I found googling around seems to be a major issue with macOS keeping track of displays and their positions. My issue may be that the serial number reported by the monitors (`ioreg -lw0 | grep DisplayAttributes | grep SerialNumber`) are identical.

I've added a Python script, based on [this very helpful Ask Different post](https://apple.stackexchange.com/a/48977/10204), to swap them. Note that I first tried to do this just with Hammerspoon's `hs.screen` APIs, however I found that moving screens around individually caused a lot of window chaos (resizing and repositioning). The Python script uses the Quartz APIs and are able to move the screens in a single API call, which has the effect of leaving all the windows unchanged. This is only a quick workaround, hopefully macOS fixes this, or I can find another way.

## Screen Lock

Activate with `hammer`+`l`, or other hotkeys like `F19` or `Pause` (see the code).

## Other Stuff

* Mouse button 4 and 5 to perform Back/Forward in Chrome, Slack, Chrome, and Visual Studio for Mac.
