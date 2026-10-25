const accessibilityEnabled = hs.permissions.checkAccessibility()
console.info(`Is Hammerspoon 2 enabled under Privacy/Accessibility: ${accessibilityEnabled}`)
if (!accessibilityEnabled) {
    hs.ui.alert('😱 WARNING! Privacy/Accessibility is NOT enabled for Hammerspoon 2. You need to turn it on.').show()
}

const secureInputEnabled = hs.eventtap.isSecureInputEnabled()
console.info(`macOS Secure Input enabled: ${secureInputEnabled}`)
if (secureInputEnabled) {
    // secureInputPID() is a best guess, and can be null even while Secure Input is on.
    const pid = hs.eventtap.secureInputPID()
    const holder = pid === null
        ? 'an unknown app'
        : `${hs.application.fromPID(pid)?.name ?? 'unknown app'} (PID ${pid})`
    hs.ui.alert(`😱 WARNING! macOS Secure Input mode is currently activated by ${holder}!
Hammerspoon can't read keystrokes while this is on!
Figure out what's got it turned on and stop it.`).duration(6).show()
}

/*
Find the offending PID (kCGSSessionSecureInputPID) with:
    ioreg -l -w 0 | grep SecureInput | ggrep -Po 'kCGSSessionSecureInputPID"=\d+'
Careful, don't kill loginwindow.
Next time try locking screen (Menu Bar: Apple -> Lock Screen), then unlocking.
*/

module.exports = {}
