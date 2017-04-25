# My [hammerspoon](http://www.hammerspoon.org/) config.

Window management hotkeys:
* Hyper+f: Full screen
* Hyper+c: Centered on screen
* Hyper+left: Left Half
* Hyper+right: Right Half
* Hyper+up: Top Half
* Hyper+down: Bottom Half
* Hyper+t: Launch a Terminal
* Hyper+l: Lock screen

## Hyper key

Inspired by [this post](http://stevelosh.com/blog/2012/10/a-modern-space-cadet/#hyper) and others, I've remapped my Caps Lock key to a private modal key (F18, something never normally used, using [Karabiner-Elements](https://github.com/tekezo/Karabiner-Elements)) and used it for the above hotkeys.

Configuring Karabiner-Elements is simple:

![How to configure Karabiner-Elements](Karabiner-Elements.png?raw=true "How to configure Karabiner-Elements")

## Lockscreen executable

To build `lockscreen` ([credit](https://www.isi.edu/~calvin/mac-lockscreen.htm)):

```
clang -framework Foundation lockscreen.m -o lockscreen
mv lockscreen /usr/local/bin
```
