// The cup icons are shared with the v1 config, in the repo root.
const ICON_DIR = `${__dirname}/../..`

const menubarItem = hs.menubar.create()

function isAwake() {
    return hs.power.isSleepPrevented('display')
}

function showCaffeine(awake) {
    const icon = HSImage.fromPath(`${ICON_DIR}/${awake ? 'cup-steaming.png' : 'cup-empty.png'}`)
    if (icon) icon.size = new HSSize(16, 16)
    menubarItem.setIcon(icon)
}

function setAwake(awake) {
    if (awake) {
        hs.power.preventSleep('display')
    } else {
        hs.power.allowSleep('display')
    }
    showCaffeine(isAwake())
}

menubarItem.setClickCallback(() => setAwake(!isAwake()))

// Start awake, like v1 (which toggled it on at load).
setAwake(true)

if (hs.appinfo.machineName === 'Steve’s MacBook Pro') {
    for (const event of /** @type {const} */ ([
        'screensaverDidStart',
        'screensaverDidStop',
        'screensDidLock',
        'screensDidUnlock',
        'screensDidWake',
        'sessionDidBecomeActive',
        'systemDidWake',
    ])) {
        hs.power.on(event, () => {
            console.info(`caffeine power watcher caught: ${event}`)
            if (!isAwake()) setAwake(true)
        })
    }
}

module.exports = { menubarItem }
