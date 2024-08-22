-- Mouse buttons 4/5 to go Back/Forward in various apps, or move left/right if the hammer key is down
-- Thanks to: https://tom-henderson.github.io/2018/12/14/hammerspoon.html

local logger = hs.logger.new('mouseBackForward.lua', 'debug')
local eventTaps = require("lib.eventTaps")
local hammer = require("lib.hammer")
local windowManagement = require("lib.windowManagement")
local util = require("lib.util")

local OTHER_MOUSE_DOWN_DEBOUNCE_TIME = 200 -- ms
local otherMouseDownAt = 0
local otherMouseDownCustomHandlers = {}

-- Make Hammer+mouse4/mouse5 behave like hammer+left/hammer+right.
function onOtherMouseDownWithHammer(event)
    local button = event:getProperty(hs.eventtap.event.properties.mouseEventButtonNumber)
    local flags = event:getFlags()
    if button == 3 then
        if flags.shift then
            windowManagement.moveLeftBig()
        elseif flags.alt then
            windowManagement.moveLeftSmall()
        elseif flags.cmd then
            windowManagement.moveWest()
        else
            windowManagement.moveLeft()
        end
    elseif button == 4 then
        if flags.shift then
            windowManagement.moveRightBig()
        elseif flags.alt then
            windowManagement.moveRightSmall()
        elseif flags.cmd then
            windowManagement.moveEast()
        else
            windowManagement.moveRight()
        end
    end
    return true -- discard
end

function onOtherMouseDownCheckCustomHandlers(event)
    local app = hs.application.frontmostApplication()
    local appName = app:name()
    logger.i('onOtherMouseDownCheckCustomHandlers event, app: ' .. appName)
    local handler = otherMouseDownCustomHandlers[appName]
    if not handler then
        logger.i("No custom handler for " .. appName .. ", passing on")
        return false -- propogate
    end
    local button = event:getProperty(hs.eventtap.event.properties.mouseEventButtonNumber)
    logger.i('onOtherMouseDownCheckCustomHandlers event, app: ' .. appName .. ', button: ' .. button)
    if button == 3 then
        logger.i(appName .. ": intercepted button3")
        handler.onBack(event, app)
    elseif button == 4 then
        logger.i(appName .. ": intercepted button4")
        handler.onForward(event, app)
    end
    return true -- discard
end

eventTaps:createEventTap({
    hs.eventtap.event.types.otherMouseDown
}, function(event)
    local isRepeat = event:getProperty(hs.eventtap.event.properties.keyboardEventAutorepeat)
    if isRepeat > 0 then
        logger.i("Ignoring otherMouseDown auto repeat")
        return true -- ignore and discard
    end

    -- implement debouncer since I'm getting unwanted double clicks, and they're not autorepeats
    local timeSinceLastDown = util.getCurrentMilliseconds() - otherMouseDownAt
    otherMouseDownAt = util.getCurrentMilliseconds()
    if timeSinceLastDown < OTHER_MOUSE_DOWN_DEBOUNCE_TIME then
        print('IGNORING UNWANTED DOUBLE CLICK of otherMouse button (' .. timeSinceLastDown .. 'ms)')
        return true -- ignore and discard
    end

    if hammer.isDown then
        return onOtherMouseDownWithHammer(event)
    end

    return onOtherMouseDownCheckCustomHandlers(event)
end)

local function registerCustomMouseBackForwardHandler(appName, onBack, onForward)
    otherMouseDownCustomHandlers[appName] = {
        onBack = onBack,
        onForward = onForward
    }
end

-- registerCustomMouseBackForwardHandler(
--     "Google Chrome", 
--     function(event, app)
--         app:selectMenuItem({"History", "Back"})
--     end,
--     function(event, app)
--         app:selectMenuItem({"History", "Forward"})
--     end
-- )

-- registerCustomMouseBackForwardHandler(
--     "Brave Browser", 
--     function(event, app)
--         app:selectMenuItem({"History", "Back"})
--     end,
--     function(event, app)
--         app:selectMenuItem({"History", "Forward"})
--     end
-- )

registerCustomMouseBackForwardHandler(
    "Visual Studio",
    function()
        app:selectMenuItem({"Search", "Navigation History", "Navigate Back"})
    end,
    function()
        app:selectMenuItem({"Search", "Navigation History", "Navigate Forward"})
    end
)

registerCustomMouseBackForwardHandler(
    "Notes",
    function(event, app)
        -- hs.eventtap.keyStroke({'cmd', 'alt'}, '[')
        -- update: they added menu items, so use them instead, but leave the keyStroke code for reference
        app:selectMenuItem({"View", "Previous Note"})
    end,
    function(event, app)
        -- hs.eventtap.keyStroke({'cmd', 'alt'}, ']')
        app:selectMenuItem({"View", "Next Note"})
    end
)
