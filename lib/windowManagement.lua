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

function obj.openNewWindowCenteredHalfWidthOnCurrentScreen(openNewWindowFn)
    local currentScreen = hs.screen.mainScreen()

    local newWindow = openNewWindowFn()
    if not newWindow then
        hs.alert.show("Failed to open new " .. applicationName .. " window")
        return
    end
    logger.i('New window:', newWindow)

    local currentScreenFrame = currentScreen:frame()
    local frame = newWindow:frame()
    -- logger.d(newWindow:title()..' from '..frame.x..','..frame.y..','..frame.w..','..frame.h)
    frame.x, frame.y, frame.w, frame.h = calculateHalfScreenCenteredFrame(frame, currentScreenFrame)
    -- logger.d(newWindow:title()..' to '..frame.x..','..frame.y..','..frame.w..','..frame.h)
    newWindow:setFrame(frame)
    newWindow:focus()
    newWindow:application():activate()
end

return obj
