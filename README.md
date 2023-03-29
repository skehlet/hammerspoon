# My [hammerspoon](http://www.hammerspoon.org/) config.

This is working on macOS Ventura (13.2) and Hammerspoon 0.9.100.

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

Use macOS's `hidutil` program to remap your keys. To do this automatically at boot, copy the file `com.stevekehlet.RemapCapsLockToF18.plist` to your `~/Library/LaunchAgents` (create that directory if it doesn't already exist).

Then either reboot, or simply run:

```bash
launchctl load com.stevekehlet.RemapCapsLockToF18.plist
```

Now just hold down the Hammer (`caps lock`) and hit `f`, `c`, `left`, or `right`, etc.

Note: I've found that Hammerspoon itself doesn't intercept Caps Lock reliably for various reasons (e.g. it's a toggle on/off, may have an LED, etc), so we need another tool. I used to use Karabiner-Elements, but some systems I use have restrictions on extensions that can be loaded, so now I just use `hidutil`.

## How is your "Hammer" key different than a "Hyper"/Modal key?

There are plenty of Hammerspoon examples of creating a "hyper" key where you press *and release* a key (e.g. `caps lock`) and then hit another button to do what you want. If that keypress flow works better for you, great, but my "hammer key" approach simply creates another modifier key that allows new key combinations (e.g. `hammer`+`g`) that are quick and easy to press. It also has an advantage over some implementations (e.g. that use exotic combinations of `cmd`+`option`+`ctrl`) that it won't inadvertently trigger application keybindings.

## Why does my Hammer key sometimes stop working?

This was happening to me because of my Chrome Lastpass extension. Every once in a while a background Chrome window would get auto-logged out of a website, redirected to a login page, auto-focused on a password field, and LastPass would kick in, triggering macOS's "secure input" state where tools like Hammerspoon, TextExpander, Keyboard Maestro, Alfred, etc, are unable to intercept keypresses. This is a security feature, so keyloggers can't sniff your password input. See [hammerspoon#1743](https://github.com/Hammerspoon/hammerspoon/issues/1743). You can avoid this headache by disabling LastPass' auto-fill feature (Chrome -> LastPass -> Account Options -> Extension Preferences, uncheck Automatically fill login information). Prior to figuring this out, I used the workaround of locking screen (`hammer`+`l`) then using touch-id to quickly log back in. Some have reporting clicking on the LastPass extension in Chrome may undo it as well.


## External monitor swapping issues

I have a keybindings to run `displayplacer` to swap my external monitors. Sometimes after waking my laptop up from sleep, it gets the two mixed up (they're identical make/model).

## Screen Lock

Activate with `hammer`+`l`, or other hotkeys like `F15` or `Pause` (see the code).

## Other Stuff

* Mouse button 4 and 5 to perform Back/Forward in Chrome, Slack, Chrome, and Visual Studio for Mac.
* Hammer+mouse4 or mouse5 to move windows to left/right half of screen
* Caffeine equivalent
* Microphone and speaker indicators to confirm my Airpods are the active input/output
* Lots of little things added here and there
