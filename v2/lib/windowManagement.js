const windowManagement = {}

// cb(frame, screenFrame) returns the new [x, y, w, h] for the focused window.
function move(cb) {
    const win = hs.window.focusedWindow()
    if (!win || !win.frame || !win.screen) return
    const [x, y, w, h] = cb(win.frame, win.screen.frame)
    win.frame = new HSRect(x, y, w, h)
}

// Hammerspoon 2 has no moveOneScreenWest/East. Like v1's default, this keeps the window's
// position and size proportional to the screen it lands on.
function moveOneScreen(toScreen) {
    const win = hs.window.focusedWindow()
    if (!win || !win.frame || !win.screen) return
    const target = toScreen(win.screen)
    if (!target) return
    win.frame = win.frame.toUnitRect(win.screen.frame).fromUnitRect(target.frame)
}

function calculateHalfScreenCenteredFrame(f, sf) {
    const w = sf.w / 2
    const h = sf.h
    const x = sf.x + ((sf.w - w) / 2)
    const y = sf.y + ((sf.h - h) / 2)
    return [x, y, w, h]
}

windowManagement.makeFullScreen = () => move((f, sf) => [sf.x, sf.y, sf.w, sf.h])
windowManagement.makeHalfScreen = () => move((f, sf) => [f.x, f.y, sf.w / 2, sf.h])
windowManagement.makeHalfScreenCentered = () => move(calculateHalfScreenCenteredFrame)
windowManagement.moveToCenter = () => move((f, sf) => [
    sf.x + ((sf.w - f.w) / 2),
    sf.y + ((sf.h - f.h) / 2),
    f.w,
    f.h,
])
windowManagement.stretchVertically = () => move((f, sf) => [f.x, sf.y, f.w, sf.h])

windowManagement.moveLeft = () => move((f, sf) => [sf.x, sf.y, sf.w / 2, sf.h])
windowManagement.moveLeftBig = () => move((f, sf) => [sf.x, sf.y, .7 * sf.w, sf.h])
windowManagement.moveLeftSmall = () => move((f, sf) => [sf.x, sf.y, .3 * sf.w, sf.h])
windowManagement.moveWest = () => moveOneScreen(screen => screen.toWest())

windowManagement.moveRight = () => move((f, sf) => [sf.x + sf.w / 2, sf.y, sf.w / 2, sf.h])
windowManagement.moveRightBig = () => move((f, sf) => [sf.x + .3 * sf.w, sf.y, .7 * sf.w, sf.h])
windowManagement.moveRightSmall = () => move((f, sf) => [sf.x + .7 * sf.w, sf.y, .3 * sf.w, sf.h])
windowManagement.moveEast = () => moveOneScreen(screen => screen.toEast())

windowManagement.moveUp = () => move((f, sf) => [f.x, sf.y, f.w, sf.h / 2])
windowManagement.moveDown = () => move((f, sf) => [f.x, sf.y + sf.h / 2, f.w, sf.h / 2])

// openNewWindowFn() opens a window and returns it. Once the new window is in place and focused,
// onConfirmed(newWindow) is called.
windowManagement.openNewWindowCenteredHalfWidthOnCurrentScreen = (openNewWindowFn, onConfirmed) => {
    const targetScreen = hs.screen.main()
    if (!targetScreen) return
    const targetScreenFrame = targetScreen.frame
    const newWindow = openNewWindowFn()
    if (!newWindow) return

    const MAX_TRIES = 8
    const INTERVAL = 0.1

    function tryPosition(triesLeft) {
        if (!newWindow.isVisible) return
        const frame = newWindow.frame
        const [tx, ty, tw, th] = calculateHalfScreenCenteredFrame(frame, targetScreenFrame)
        const inPlace = (Math.abs(frame.x - tx) < 2 && Math.abs(frame.y - ty) < 2 &&
                         Math.abs(frame.w - tw) < 2 && Math.abs(frame.h - th) < 2)
        if (!inPlace) {
            newWindow.frame = new HSRect(tx, ty, tw, th)
            if (triesLeft > 1) {
                hs.timer.doAfter(INTERVAL, () => tryPosition(triesLeft - 1))
                return
            }
            console.warn(`${newWindow.title}: frame still not in place after max retries`)
        }
        newWindow.focus()
        // newWindow.application?.activate() // 2026-10-16 testing if this is no longer needed
        if (onConfirmed) onConfirmed(newWindow)
    }

    tryPosition(MAX_TRIES)
}

module.exports = windowManagement
