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

## What's this "Hotkey"?

`caps lock` is my hotkey.

In [my Hammerspoon config](https://github.com/skehlet/hammerspoon/blob/master/init.lua#L45) I turn F18 into a modifier key (like
Command, Shift, Control, etc). F18 isn't used for anything as far as I know:

![F18](apple-wireless-keyboard-numeric.png?raw=true "F18")

Then I use [Karabiner-Elements](https://github.com/tekezo/Karabiner-Elements) to remap my Caps Lock key to F18:

![How to configure Karabiner-Elements](Karabiner-Elements.png?raw=true "How to configure Karabiner-Elements")

This allows holding Caps Lock while hitting `f`, `c`, `left`, `right`, etc. There might be other ways to do this but this is straightforward and never conflicts with any other apps that might have weird modifier key (for example, `cmd`+`alt`+`ctrl`+`c`) combinations.

## Mission Control: Expanding Desktop thumbnails by default

At some point macOS stopped expanding the Desktop thumbnails by default whenever you'd hit the Mission Control key (F3). It's frustrating that there's no way to turn this back on. Thankfully, [missionControlFullDesktopBar](https://github.com/briankendall/missionControlFullDesktopBar) comes to the rescue. The author states:

> I recommend making it so that the above command is executed when the button is pressed, and the following command is executed when it's released

and this is possible by intercepting F3 keypresses, see [my config](https://github.com/skehlet/hammerspoon/blob/master/init.lua#L118), and [my video of it working](https://youtu.be/K0PgxgLWZM4).

## Lockscreen

After updating to High Sierra, [the way I was using](https://apple.stackexchange.com/a/123738) no longer works, due to a change in the Keychain Access app.

There's [another way here](https://stackoverflow.com/a/26492632), but it shows the login screen for a few seconds, I'd prefer just a blank screen.

I've settled on `pmset displaysleepnow` ([credit](https://apple.stackexchange.com/a/111493)). It just puts the display to sleep, and relies on you having
set _Require password immediately after sleep or screen saver begins_, which I had set anyway.

![Require password immediately after sleep or screen saver begins](L851F.png?raw=true "Require password immediately after sleep or screen saver begins")
