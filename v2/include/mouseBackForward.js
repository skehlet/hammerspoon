const hammer = require('../lib/hammer')
const windowManagement = require('../lib/windowManagement')

// NOTE: Hammerspoon 2 inverts v1's eventtap return values. Return hs.eventtap.consume (false)
// to discard an event, hs.eventtap.emit (true) to pass it on. Never return bare true/false.

const OTHER_MOUSE_DOWN_DEBOUNCE_TIME = 200 // ms
let otherMouseDownAt = 0
const otherMouseDownCustomHandlers = {}

function onOtherMouseDownWithHammer(event) {
    const button = event.buttonNumber
    const flags = event.flags
    if (button === 3) {
        if (flags.includes('shift')) {
            windowManagement.moveLeftBig()
        } else if (flags.includes('alt')) {
            windowManagement.moveLeftSmall()
        } else if (flags.includes('cmd')) {
            windowManagement.moveWest()
        } else {
            windowManagement.moveLeft()
        }
    } else if (button === 4) {
        if (flags.includes('shift')) {
            windowManagement.moveRightBig()
        } else if (flags.includes('alt')) {
            windowManagement.moveRightSmall()
        } else if (flags.includes('cmd')) {
            windowManagement.moveEast()
        } else {
            windowManagement.moveRight()
        }
    }
    return hs.eventtap.consume
}

function onOtherMouseDownCheckCustomHandlers(event) {
    const app = hs.application.frontmost()
    const appName = app?.name
    console.info(`onOtherMouseDownCheckCustomHandlers event, app: ${appName}`)
    const handler = otherMouseDownCustomHandlers[appName]
    if (!handler) {
        console.info(`No custom handler for ${appName}, passing on`)
        return hs.eventtap.emit
    }

    const button = event.buttonNumber
    console.info(`onOtherMouseDownCheckCustomHandlers event, app: ${appName}, button: ${button}`)
    if (button === 3) {
        console.info(`${appName}: intercepted button3`)
        handler.onBack(event, app)
    } else if (button === 4) {
        console.info(`${appName}: intercepted button4`)
        handler.onForward(event, app)
    }
    return hs.eventtap.consume
}

const tap = hs.eventtap.addWatcher([
    hs.eventtap.eventTypes.otherMouseDown
], event => {
    const now = Date.now()
    const timeSinceLastDown = now - otherMouseDownAt
    otherMouseDownAt = now
    if (timeSinceLastDown < OTHER_MOUSE_DOWN_DEBOUNCE_TIME) {
        console.log(`IGNORING UNWANTED DOUBLE CLICK of otherMouse button (${timeSinceLastDown}ms)`)
        return hs.eventtap.consume
    }

    if (hammer.isDown) {
        return onOtherMouseDownWithHammer(event)
    }

    return onOtherMouseDownCheckCustomHandlers(event)
}, false)?.start()

if (!tap) {
    console.error('mouseBackForward.js: failed to create event tap (Accessibility permission?)')
}

function registerCustomMouseBackForwardHandler(appName, onBack, onForward) {
    otherMouseDownCustomHandlers[appName] = { onBack, onForward }
}

registerCustomMouseBackForwardHandler(
    'Visual Studio',
    (event, app) => app.selectMenuItemByPath(['Search', 'Navigation History', 'Navigate Back']),
    (event, app) => app.selectMenuItemByPath(['Search', 'Navigation History', 'Navigate Forward'])
)

registerCustomMouseBackForwardHandler(
    'Notes',
    (event, app) => app.selectMenuItemByPath(['View', 'Recent Notes', 'Previous Note']),
    (event, app) => app.selectMenuItemByPath(['View', 'Recent Notes', 'Next Note'])
)

registerCustomMouseBackForwardHandler(
    'Microsoft Teams',
    (event, app) => hs.eventtap.keyStroke(['cmd'], '['),
    (event, app) => hs.eventtap.keyStroke(['cmd'], ']')
)

module.exports = { tap }
