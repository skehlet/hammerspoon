# My [hammerspoon](http://www.hammerspoon.org/) config.

Basic stuff:
* Full screen
* Centered on screen
* Left/Right Half
* Top/Bottom Half
* Lock screen
* Launch a Terminal

I'm using [Karabiner](https://pqrs.org/osx/karabiner/) and [Seil](https://pqrs.org/osx/karabiner/seil.html.en) to map my Caps Lock key to Command+Alt+Ctrl. When I upgrade to macOS Sierra I'll use [Karabiner-Elements](https://github.com/tekezo/Karabiner-Elements/) and [the config file here](https://github.com/lodestone/hyper-hacks).

To build `lockscreen` ([source](https://www.isi.edu/~calvin/mac-lockscreen.htm)):

```
clang -framework Foundation lockscreen.m -o lockscreen
mv lockscreen /usr/local/bin
```
