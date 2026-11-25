# Hammerspoon 2 port (beta)

A port of the v1 config in the repo root to [Hammerspoon 2](https://github.com/Hammerspoon/Hammerspoon2), which is a JavaScript rewrite, now in beta (1.0.0). Same features, same files: `lib/` and `include/` mirror their v1 counterparts.

## Setup

1. Download Hammerspoon 2 from its [releases page](https://github.com/Hammerspoon/Hammerspoon2/releases) and move it to `/Applications`, or run `brew install --cask hammerspoon/tap/hammerspoon2` (which also puts `hs2` on your `PATH`).
2. **Quit Hammerspoon (v1).** Both apps bind the Hammer key and watch the mouse buttons, so only run one at a time.
3. Launch Hammerspoon 2. When onboarding asks where to keep your config, choose `~/.hammerspoon/v2`. It never overwrites existing files, but it does add `bundle.js` and `package.json` (an optional npm bundler); delete them if you don't need it.
4. Grant Accessibility (and Notifications, when prompted) in System Settings → Privacy & Security.

To go back to v1, quit Hammerspoon 2 and launch Hammerspoon.

## Differences from v1

* **Object lifetime:** since Hammerspoon 2 0.0.14, running objects (enabled hotkeys, started watchers and timers, shown menubar items) stay alive without a reference. Anything not running, like the Hammer modal's hotkeys while the Hammer key is up, still needs one: `lib/hammer.js` keeps it. Each include also exports what it creates, and `init.js` holds every include's exports.
* **Event taps:** return `hs.eventtap.consume` to discard an event and `hs.eventtap.emit` to pass it on. This is inverted from v1's `return true -- discard`.
* **Includes are listed explicitly** in `init.js`, not discovered from `include/`. A failing include is logged and skipped.
* **Secure Input:** `macosSanityChecks.js` also names the app holding Secure Input, via `hs.eventtap.secureInputPID()` (Hammerspoon 2 0.0.15+).
* **Moving windows between screens** (`hammer`+`cmd`+`left`/`right`) is reimplemented, since `moveOneScreenWest/East` are gone. (Spaces support arrived in 1.0.0-beta.1, on `HSScreen`, `HSWindow` and `HSSpace`, but there is still no move-to-adjacent-screen helper.)
* **Not ported:** `hs.window.animationDuration` (doesn't exist in v2) and `lib/screen.lua` (the includes call `hs.power` directly).

## Editor support

`hammerspoon.d.ts` (currently for 1.0.0-beta.3, from the [Hammerspoon 2 docs](https://www.hammerspoon.org/2/1.0.0-beta.3/js/typescript-guide.html)), `globals.d.ts` (declares `require`, `module` and `__dirname`, which v2 provides but its `.d.ts` doesn't yet) and `jsconfig.json` give VS Code autocomplete and type checking for the plain-JS config, with no build step. When you update Hammerspoon 2, replace it with the matching version's file:

```bash
curl -fL https://www.hammerspoon.org/2/<version>/hammerspoon.d.ts -o v2/hammerspoon.d.ts
```

## Feedback

Hammerspoon 2 issues: https://github.com/Hammerspoon/Hammerspoon2/issues
