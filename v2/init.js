// Hammerspoon 2 config. See README.md in this directory for setup.

// Load order matters only in that each include is isolated: one failing (e.g. an API that changed
// in a new Hammerspoon 2 build) is logged and skipped, without taking down the rest.
const INCLUDES = [
    'macosSanityChecks',
    'reloadAutomatically',
    'caffeine',
    'windows',
    'openBrowser',
    'openTerminal',
    'lockScreen',
    'systemSleep',
    'mouseBackForward',
    'msAppTweaks',
    'forcePaste',
    'screenShot',
]

// Each include exports the objects it creates. Since Hammerspoon 2 0.0.14, running objects (enabled
// hotkeys, started watchers, shown menubar items, etc.) stay alive without a reference, so this is
// no longer what keeps them alive; it's a handle for inspecting or stopping them later.
const includes = {}
for (const name of INCLUDES) {
    try {
        includes[name] = require(`./include/${name}`)
    } catch (e) {
        console.error(`Failed to load include/${name}: ${e}`)
    }
}

hs.permissions.requestNotifications().then(granted => {
    if (granted) {
        hs.notify.show('Hammerspoon 2', 'Config loaded', () => {})
    }
})
