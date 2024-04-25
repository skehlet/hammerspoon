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
    if app then
        -- go to great lengths to make sure the new window appears on the current screen
        local currentScreen = hs.screen.mainScreen()
        local preExistingAppWindowIds = {}
        for _, win in ipairs(app:visibleWindows()) do
            preExistingAppWindowIds[win:id()] = true
        end

        openNewWindowFn(app)

        for i, win in ipairs(app:visibleWindows()) do
            if not preExistingAppWindowIds[win:id()] then
                -- if it's a new window, and it's on the wrong screen...
                if win:screen() ~= currentScreen then
                    -- logger.i("Moving New " .. applicationName .. " window (" .. win:title() .. ") to current screen")
                    win:moveToScreen(currentScreen)
                end
                -- I've noticed sometimes it still gets buried under other windows, this helps:
                -- logger.i("Focusing on New " .. applicationName .. " window (" .. win:title() .. ")")
                win:focus()
                app:activate()
                obj.makeHalfScreenCentered()
                break
            end
        end
    end
end

return obj
