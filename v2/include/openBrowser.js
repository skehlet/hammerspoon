const hammer = require('../lib/hammer')
const windowManagement = require('../lib/windowManagement')

const BROWSER_APP_NAME = 'Brave Browser'

function openBrowser() {
    const app = hs.application.matchingName(BROWSER_APP_NAME)
    if (!app) {
        hs.ui.alert(`Application not found: ${BROWSER_APP_NAME}`).show()
        return null
    }
    console.info(`Found ${BROWSER_APP_NAME}: ${app}`)
    if (!app.selectMenuItemByPath(['File', 'New Window'])) {
        hs.ui.alert(`Failed to open new ${BROWSER_APP_NAME} window`).show()
        return null
    }
    return app.findWindow('New Tab')[0] ?? null
}

function openBrowserBookmark(win, bookmarkPath) {
    if (!win.application?.selectMenuItemByPath(bookmarkPath)) {
        hs.ui.alert(`Failed to open bookmark in ${BROWSER_APP_NAME}`).show()
        return null
    }
    return win
}

hammer.bind([], 'b', () => {
    windowManagement.openNewWindowCenteredHalfWidthOnCurrentScreen(openBrowser)
})

hammer.bind([], 'a', () => {
    windowManagement.openNewWindowCenteredHalfWidthOnCurrentScreen(
        openBrowser,
        win => openBrowserBookmark(win, ['Bookmarks', 'AI', 'Claude'])
    )
})

hammer.bind([], 'g', () => {
    windowManagement.openNewWindowCenteredHalfWidthOnCurrentScreen(
        openBrowser,
        win => openBrowserBookmark(win, ['Bookmarks', 'AI', 'Gemini'])
    )
})

hammer.bind([], 'u', () => {
    const win = hs.window.focusedWindow()
    if (!win || win.application?.title !== BROWSER_APP_NAME) {
        hs.ui.alert(`Not a ${BROWSER_APP_NAME} window`).show()
        return
    }
    console.info(`Current window: ${win}`)
    win.application.selectMenuItemByPath(['Bookmarks', 'Copy Link'])
})

module.exports = {}
