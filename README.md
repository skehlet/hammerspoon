# My [hammerspoon](http://www.hammerspoon.org/) config.

Window management hotkeys:
* Hyper+f: Full screen
* Hyper+c: Centered on screen
* Hyper+left: Left Half
* Hyper+right: Right Half
* Hyper+up: Top Half
* Hyper+down: Bottom Half

A few other misc features:
* Hyper+t: Launch a Terminal
* Hyper+l: Lock screen
* Hyper+e: Enable hints, a way to switch apps

## Hyper key

Inspired by [this post](http://stevelosh.com/blog/2012/10/a-modern-space-cadet/#hyper) and others, I'm using [Karabiner-Elements](https://github.com/tekezo/Karabiner-Elements) to remap my Caps Lock key to F18 (something never normally used) and then [Hammerspoon](http://www.hammerspoon.org/) to make F18 a modal key. Then I can make various key combinations like above and not conflict with any other apps.
 
Configuring Karabiner-Elements is simple:

![How to configure Karabiner-Elements](Karabiner-Elements.png?raw=true "How to configure Karabiner-Elements")

## Lockscreen executable

To build `lockscreen` ([credit](https://www.isi.edu/~calvin/mac-lockscreen.htm)):

```
clang -framework Foundation lockscreen.m -o lockscreen
mv lockscreen /usr/local/bin
```
