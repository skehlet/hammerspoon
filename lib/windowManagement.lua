-- Window management functions

local hammer = require("lib.hammer")
local logger = hs.logger.new('windowManagement.lua', 'debug')

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

function calculateHalfScreenCenteredFrame(f, sf)
    local w = sf.w / 2
    local h = sf.h
    local x = sf.x + ((sf.w - w) / 2)
    local y = sf.y + ((sf.h - h) / 2)
    return x, y, w, h
end

function obj.makeHalfScreenCentered()
    move(calculateHalfScreenCenteredFrame)
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

-- openNewWindowFn()  -> hs.window  (opens and returns the new window)
-- onConfirmed(win)    -> optional; called once the window is confirmed in place
--                        and focused -- safe to fire menu actions here
function obj.openNewWindowCenteredHalfWidthOnCurrentScreen(openNewWindowFn, onConfirmed)
    -- Capture the target screen before openNewWindowFn() can shift focus
    local targetScreenFrame = hs.screen.mainScreen():frame()

    local newWindow = openNewWindowFn()
    if not newWindow then return end

    -- Retry asynchronously until the frame is confirmed in place, up to maxTries.
    -- macOS animates window placement asynchronously; a synchronous retry loop
    -- never yields and loses the race. doAfter yields back to the event loop so
    -- macOS can finish its own placement before we check and re-assert.
    local maxTries = 8
    local interval = 0.1

    local function tryPosition(triesLeft)
        if not newWindow:isVisible() then return end
        local frame = newWindow:frame()
        local tx, ty, tw, th = calculateHalfScreenCenteredFrame(frame, targetScreenFrame)
        local inPlace = (math.abs(frame.x - tx) < 2 and math.abs(frame.y - ty) < 2 and
                         math.abs(frame.w - tw) < 2 and math.abs(frame.h - th) < 2)
        if not inPlace then
            frame.x, frame.y, frame.w, frame.h = tx, ty, tw, th
            newWindow:setFrame(frame)
            if triesLeft > 1 then
                hs.timer.doAfter(interval, function() tryPosition(triesLeft - 1) end)
                return
            end
            logger.w(newWindow:title()..': frame still not in place after max retries')
        end
        -- Window is confirmed in place (or retries exhausted): focus then notify.
        -- onConfirmed runs here so any menu/bookmark action targets this window.
        newWindow:focus()
        newWindow:application():activate()
        if onConfirmed then onConfirmed(newWindow) end
    end

    tryPosition(maxTries)
end

return obj
