// NOTE: return hs.eventtap.consume to discard an event, hs.eventtap.emit to pass it on (inverted from v1).

const tap = hs.eventtap.addWatcher([
    hs.eventtap.eventTypes.flagsChanged
], event => {
    const win = hs.window.focusedWindow()
    if (win?.title?.includes('- Outlook -') && event.keyCode === hs.keycodes.map['alt']) {
        console.info('O365 Mail alt key workaround, ignoring alt flags changed event')
        return hs.eventtap.consume // Discard the raw alt key up or down
    }
    return hs.eventtap.emit
}, false)?.start()

if (!tap) {
    console.error('msAppTweaks.js: failed to create event tap (Accessibility permission?)')
}

module.exports = { tap }
