-- Window management functions

local hammer = require("lib.hammer")

local obj = {}

local function move(cb)
    local win = hs.window.focusedWindow()
    if win then
        local frame = win:frame()
        local screenFrame = win:screen():frame()
        frame.x, frame.y, frame.w, frame.h = cb(frame, screenFrame)
        -- logger.d(win:title()..' to '..frame.x..','..frame.y..','..frame.w..','..frame.h)
        win:setFrame(frame)
    end
end

function obj.makeFullScreen()
    move(function (f, sf) return sf.x, sf.y, sf.w, sf.h end)
end

function obj.makeHalfScreen()
    move(function (f, sf) return f.x, f.y, sf.w/2, sf.h end)
end

function obj.makeHalfScreenCentered()
    move(function (f, sf)
        local w = sf.w / 2
        local h = sf.h
        local x = sf.x + ((sf.w - w) / 2)
        local y = sf.y + ((sf.h - h) / 2)
        return x, y, w, h
    end)
end

function obj.moveToCenter()
    move(function (f, sf)
        local x = sf.x + ((sf.w - f.w) / 2)
        local y = sf.y + ((sf.h - f.h) / 2)
        return x, y, f.w, f.h
    end)
end

function obj.stretchVertically()
    move(function (f, sf) return f.x, sf.y, f.w, sf.h end)
end

function obj.moveLeft()
    move(function (f, sf) return sf.x, sf.y, sf.w/2, sf.h end)
end

function obj.moveLeftBig()
    move(function (f, sf) return sf.x, sf.y, .7*sf.w, sf.h end)
end

function obj.moveLeftSmall()
    move(function (f, sf) return sf.x, sf.y, .3*sf.w, sf.h end)
end

function obj.moveWest()
    local win = hs.window.focusedWindow()
    if win then
        win:moveOneScreenWest()
    end
end

function obj.moveRight()
    move(function (f, sf) return (sf.x2 - sf.w/2), sf.y, sf.w/2, sf.h end)
end

function obj.moveRightBig()
    move(function (f, sf) return (sf.x2 - .7*sf.w), sf.y, .7*sf.w, sf.h end)
end

function obj.moveRightSmall()
    move(function (f, sf) return (sf.x2 - .3*sf.w), sf.y, .3*sf.w, sf.h end)
end

function obj.moveEast()
    local win = hs.window.focusedWindow()
    if win then
        win:moveOneScreenEast()
    end
end

function obj.moveUp()
    move(function (f, sf) return f.x, sf.y, f.w, sf.h/2 end)
end

function obj.moveDown()
    move(function (f, sf) return f.x, (sf.y2 - sf.h/2), f.w, sf.h/2 end)
end

function obj.openNewCenteredHalfWidthWindowOnCurrentScreen(applicationName, openNewWindowFn)
    local app = hs.application.find(applicationName)
    if not app then
        hs.alert.show("Application not found: " .. applicationName)
        return
    end

    local currentScreen = hs.screen.mainScreen()
    local preExistingAppWindowIds = {}
    for _, win in ipairs(app:visibleWindows()) do
        preExistingAppWindowIds[win:id()] = true
    end

    openNewWindowFn(app)

    -- Go to great lengths to make sure the new window appears on the current screen
    -- Sadly, my attempts to use hs.window.filter and events don't work very well, believe it or not, this works faster
    -- and better. So keep it for now.

    -- --- Retry Logic Configuration ---
    local maxAttempts = 10 -- How many times to check for the new window
    local retryInterval = 0.1 -- Seconds to wait between each check
    local attempts = 0

    -- We declare the timer function variable here so it can call itself.
    local findWindowTimer = nil

    -- This is the function that will be run repeatedly.
    local tryToFindWindow = function()
        attempts = attempts + 1
        local newWindow = nil

        -- Look for a window that didn't exist before we called openNewWindowFn
        for _, win in ipairs(app:visibleWindows()) do
            if not preExistingAppWindowIds[win:id()] then
                newWindow = win
                break
            end
        end

        if newWindow then
            -- SUCCESS: We found the new window.
            -- Stop the timer from running again in case it was scheduled.
            if findWindowTimer then findWindowTimer:stop() end

            -- Now, manipulate the window as intended.
            if newWindow:screen() ~= currentScreen then
                newWindow:moveToScreen(currentScreen)
            end
            newWindow:focus()
            app:activate()
            obj.makeHalfScreenCentered()

        elseif attempts < maxAttempts then
            -- TRY AGAIN: Window not found yet, but we have attempts left.
            -- Schedule this same function to run again after the interval.
            findWindowTimer = hs.timer.doAfter(retryInterval, tryToFindWindow)

        else
            -- FAILURE: We've run out of attempts.
            hs.alert.show("Hammerspoon: Could not find new window for " .. applicationName)
        end
    end

    -- Kick off the first attempt after an initial delay.
    findWindowTimer = hs.timer.doAfter(retryInterval, tryToFindWindow)
end

return obj
