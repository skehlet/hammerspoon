const hammer = require('../lib/hammer')

hammer.bind([], 'l', () => {
    hammer.onUpOnce(() => hs.power.lockScreen())
})

const f15Hotkey = hs.hotkey.bind([], 'f15', () => hs.power.lockScreen()) // F15 (Pause on my PC keyboard)

module.exports = { f15Hotkey }
