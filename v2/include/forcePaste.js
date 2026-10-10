// Type out the clipboard, for fields that block pasting.
// keyStrokesAsync() so typing a long clipboard doesn't stall the rest of Hammerspoon.
const hotkey = hs.hotkey.bind(['cmd', 'alt'], 'v', () => {
    const text = hs.pasteboard.readString()
    if (text) hs.eventtap.keyStrokesAsync(text)
})

module.exports = { hotkey }
