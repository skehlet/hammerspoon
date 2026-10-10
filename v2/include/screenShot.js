// F13 (PrintScreen on PC keyboards): screenshot a selection to the clipboard.
const f13Hotkey = hs.hotkey.bind([], 'f13', () => {
    hs.eventtap.keyStroke(['ctrl', 'shift', 'cmd'], '4')
})

module.exports = { f13Hotkey }
