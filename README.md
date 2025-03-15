# My [hammerspoon](http://www.hammerspoon.org/) config.

This is working on macOS Sequoia (15.2) and Hammerspoon 1.0.0.

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
* `hammer`+`b`: Open a new Brave Browser window
* `hammer`+`t`: Launch a Terminal
* `hammer`+`l`: Lock screen (additional lock screen bindings in Screen Lock section below)

## What is this "Hammer" key?

`Caps Lock` is my Hammer key, it has a perfect location on the keyboard and I'd never use it otherwise. It acts like just another modifier key, like `command`, `shift`, or `ctrl`, but exclusively for Hammerspoon keybindings.

## How do I turn my Caps Lock into a Hammer key?

Use macOS's `hidutil` program to remap your keys. To do this automatically at boot, copy the file `com.stevekehlet.RemapCapsLockToF20.plist` to your `~/Library/LaunchAgents`. Create that directory if it doesn't already exist, and feel free to rename the file if you don't want my name in it.

Then either reboot, or simply run:

```bash
launchctl load com.stevekehlet.RemapCapsLockToF20.plist
```

Now just hold down the Hammer (`caps lock`) and hit `f`, `c`, `left`, or `right`, etc.

## How is your "Hammer" key different than a "Hyper"/Modal key?

There are plenty of Hammerspoon examples of creating a "hyper" key where you press *and release* a key (e.g. `caps lock`) and then hit another button to do what you want. If you like that, great, but I just turn `caps lock` into another modifier key that allows new key combinations (e.g. `hammer`+`g`) that are quick and easy to press. It also works more reliably than some implementations I've seen (e.g. those that use exotic combinations of `cmd`+`option`+`ctrl`) that can inadvertently trigger application keybindings.

## Why does Hammerspoon sometimes stop working?

macOS has a security feature called *Secure Input* where it prevents Hammerspoon (and applications like it, including TextExpander, Keyboard Maestro, Alfred, etc) from watching keyboard input. This can get turned on without your knowledge, for example, if a background browser window gets logged out and is sitting at a password prompt. I've added some detections for this with a menu bar indicator, and a huge alert on Hammerspoon startup to alert you. There is no way to stop this other than finding the offending window and dealing with it, either entering your password and submitting it, focusing away from that field, or closing the window.

## Screen Lock

Activate with `hammer`+`l`, or other hotkeys like `F15` or `Pause` (see the code).

## Other Stuff

* Mouse button 4 and 5 to perform Back/Forward in Chrome, Slack, Chrome, and Visual Studio for Mac.
* Hammer+mouse4 or mouse5 to move windows to left/right half of screen
* Caffeine equivalent
* Microphone and speaker indicators to confirm my Airpods are the active input/output
* F13 (the button where PrintScreen is on PC keyboards) does that awkward keystroke (ctrl-shift-cmd-4) for you to take a screenshot and store it on the clipboard
* Lots of little things added here and there, see the [include](./include/) folder for all my scripts.
