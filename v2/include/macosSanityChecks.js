const accessibilityEnabled = hs.permissions.checkAccessibility()
console.info(`Is Hammerspoon 2 enabled under Privacy/Accessibility: ${accessibilityEnabled}`)
if (!accessibilityEnabled) {
    hs.ui.alert('😱 WARNING! Privacy/Accessibility is NOT enabled for Hammerspoon 2. You need to turn it on.').show()
}

// Hammerspoon 2 has no isSecureInputEnabled(), so ask ioreg. It reports the PID holding
// Secure Input only while it's on.
hs.task.shell(`ioreg -l -w 0 | grep -oE '"kCGSSessionSecureInputPID"=[0-9]+'`, {}).then(({ stdout }) => {
    const match = stdout.match(/=(\d+)/)
    console.info(`macOS Secure Input enabled: ${!!match}`)
    if (!match) return
    const pid = Number(match[1])
    const appName = hs.application.fromPID(pid)?.title ?? 'unknown app'
    hs.ui.alert(`😱 WARNING! macOS Secure Input mode is currently activated by ${appName} (PID ${pid})!
Hammerspoon can't read keystrokes while this is on!
Figure out what's got it turned on and stop it.`).duration(6).show()
})

/*
Find the offending PID (kCGSSessionSecureInputPID) with:
    ioreg -l -w 0 | grep SecureInput | ggrep -Po 'kCGSSessionSecureInputPID"=\d+'
Careful, don't kill loginwindow.
Next time try locking screen (Menu Bar: Apple -> Lock Screen), then unlocking.
*/

module.exports = {}
