# My [hammerspoon](http://www.hammerspoon.org/) config.

## Window Management

See [a video here](https://youtu.be/OjS6LqKEPcA):

* Hotkey+f: Full screen
* Hotkey+c: Centered on screen
* Hotkey+left: Left Half
* Hotkey+right: Right Half
* Hotkey+up: Top Half
* Hotkey+down: Bottom Half

## Shortcuts

* Hotkey+g: Open a new Google Chrome window
* Hotkey+t: Launch a Terminal
* Hotkey+l: Lock screen
* Hotkey+e: Enable hints, a way to switch apps

## What is this "Hotkey"?

`caps lock` is my hotkey.

In my Hammerspoon config I turn `F18` into a modifier key (like Command, Shift, Control, etc). `F18` isn't used for anything as far as I know:

![F18](apple-wireless-keyboard-numeric.png?raw=true "F18")

Then I use [Karabiner-Elements](https://github.com/tekezo/Karabiner-Elements) to remap my Caps Lock key to `F18`:

![How to configure Karabiner-Elements](Karabiner-Elements.png?raw=true "How to configure Karabiner-Elements")

This allows holding Caps Lock while hitting `f`, `c`, `left`, `right`, etc. There might be other ways to do this but this, for example you'll find examples out there of people binding Caps Lock to weird key modifier combinations (like `cmd`+`alt`+`ctrl`), but this way is really straightforward and doesn't accidentally trigger other apps that are listening for weird modifier key combinations.

## Screen Lock

Activate with `Hotkey`+`l` or `F19`.

After updating to High Sierra, [the way I was using](https://apple.stackexchange.com/a/123738) no longer works, due to a change in the Keychain Access app.

There's [another way here](https://stackoverflow.com/a/26492632), but it shows the login screen for a few seconds, I'd prefer just a blank screen.

I've settled on `pmset displaysleepnow` ([credit](https://apple.stackexchange.com/a/111493)), which just puts the display to sleep. You'll need to set _Require password immediately after sleep or screen saver begins_ under System Preferences, Security & Privacy, General (a good idea anyway) for it to actually lock the screen.

![Require password immediately after sleep or screen saver begins](L851F.png?raw=true "Require password immediately after sleep or screen saver begins")

## Logitech G600 Support

Using the Logitech G Hub software, I remapped the extra ring finger button to `F17`, and then remap `F17`'s down and up keypresses to the Mission Control key.

![logitech-g600-ring-finger-button.png](logitech-g600-ring-finger-button.png?raw=true "Logitech G600 ring finger button remap in Logitech G Hub")
