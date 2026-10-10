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

// Hammerspoon 2 garbage-collects hotkeys, timers, menubar items, etc. once nothing references them.
// Each include exports the objects it creates, and holding all the exports here keeps them alive
// for the life of the config.
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
