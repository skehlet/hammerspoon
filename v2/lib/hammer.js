// The Hammer key
// Install com.stevekehlet.RemapCapsLockToF20.plist (see the top-level README) to map Caps Lock to F20.

const HAMMER_KEY = 'f20'

// require() only evaluates a file once.
// So all scripts requiring this file will get this same hammer instance.

// A modal with no trigger key: the F20 down/up hotkeys below enter and exit it.
const modal = hs.hotkey.createModal([], '')

const hammer = {
    isDown: false,
    /** @type {Array<() => void>} */
    onUpOnceCallbacks: [],

    bind(mods, key, fn) {
        modal.bind(mods, key, fn)
    },

    onUpOnce(fn) {
        this.onUpOnceCallbacks.push(fn)
    },
}

modal.onEnter = () => {
    hammer.isDown = true
}

modal.onExit = () => {
    hammer.isDown = false
    while (hammer.onUpOnceCallbacks.length > 0) {
        hammer.onUpOnceCallbacks.shift()()
    }
}

// This programmatically generates a hotkey binding for every possible
// combination of modifier keys, ensuring the Hammer key bindings always work,
// regardless of whether you hit cmd/alt/shift/ctrl or the hammer first.
// There are 2^4 = 16 combinations of these 4 modifiers; each bit of `i` selects one.
const MODIFIERS = ['cmd', 'alt', 'shift', 'ctrl']
const triggers = []
for (let i = 0; i < 16; i++) {
    const mods = MODIFIERS.filter((_, bit) => i & (1 << bit))
    const trigger = hs.hotkey.bind(mods, HAMMER_KEY,
        () => modal.enter(), // KeyDown
        () => modal.exit(),  // KeyUp
    )
    if (!trigger) {
        console.error(`hammer.js: failed to bind ${[...mods, HAMMER_KEY].join('+')}`)
    }
    triggers.push(trigger)
}

// Referenced from the exported object so neither gets garbage-collected.
hammer._modal = modal
hammer._triggers = triggers

module.exports = hammer
