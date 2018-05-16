# My [hammerspoon](http://www.hammerspoon.org/) config.

Window management hotkeys:
* Hyper+f: Full screen
* Hyper+c: Centered on screen
* Hyper+left: Left Half
* Hyper+right: Right Half
* Hyper+up: Top Half
* Hyper+down: Bottom Half

A few other misc features:
* Hyper+g: Open a new Google Chrome window
* Hyper+t: Launch a Terminal
* Hyper+l: Lock screen
* Hyper+e: Enable hints, a way to switch apps

## Hyper key

Inspired by [this post](http://stevelosh.com/blog/2012/10/a-modern-space-cadet/#hyper) and others, I'm using [Karabiner-Elements](https://github.com/tekezo/Karabiner-Elements) to remap my Caps Lock key to F18 (something never normally used) and then [Hammerspoon](http://www.hammerspoon.org/) to make F18 a modal key. Then I can make various key combinations like above and not conflict with any other apps.
 
Configuring Karabiner-Elements is simple:

![How to configure Karabiner-Elements](Karabiner-Elements.png?raw=true "How to configure Karabiner-Elements")

## Lockscreen
After updating to High Sierra, [the way I was using](https://apple.stackexchange.com/a/123738) no longer works, due to a change in the Keychain Access app.

There's [another way here](https://stackoverflow.com/a/26492632), but it shows the login screen for a few seconds, I'd prefer just a blank screen.

I've settled on `pmset displaysleepnow` ([credit](https://apple.stackexchange.com/a/111493)). It just puts the display to sleep, and relies on you having
set _Require password immediately after sleep or screen saver begins_, which I had set anyway.

![Require password immediately after sleep or screen saver begins](L851F.png?raw=true "Require password immediately after sleep or screen saver begins")
