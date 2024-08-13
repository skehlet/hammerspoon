-- Mouse buttons 4/5 to go Back/Forward in various apps, or move left/right if the hammer key is down
-- Thanks to: https://tom-henderson.github.io/2018/12/14/hammerspoon.html

local logger = hs.logger.new('mouseBackForward.lua', 'debug')
local eventTaps = require("lib.eventTaps")
local hammer = require("lib.hammer")
local windowManagement = require("lib.windowManagement")

-- Make Hammer+mouse4/mouse5 behave like hammer+left/hammer+right.
eventTaps:createEventTap({
    hs.eventtap.event.types.otherMouseDown
}, function (event)
    if hammer.isDown then
        local button = event:getProperty(hs.eventtap.event.properties.mouseEventButtonNumber)
        local isRepeat = event:getProperty(hs.eventtap.event.properties.keyboardEventAutorepeat)
        if isRepeat > 0 then
            logger.i("Ignoring otherMouseDown auto repeat")
            return true -- ignore and discard
        end
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
end)

local function onMouseBackForward(appName, onBack, onForward)
    eventTaps:createEventTap({
        hs.eventtap.event.types.otherMouseDown
    }, function (event)
        if hammer.isDown then
            return false
        end
        local app = hs.application.frontmostApplication()
        -- logger.i('otherMouseDown event, app: ' .. app:name())
        if app:name() == appName then
            local button = event:getProperty(hs.eventtap.event.properties.mouseEventButtonNumber)
            local isRepeat = event:getProperty(hs.eventtap.event.properties.keyboardEventAutorepeat)
            logger.i('otherMouseDown event, app: ' .. app:name() .. ', button: ' .. button)
            if isRepeat > 0 then
                logger.i(appName .. ": Discarding repeat button 3/4")
                return true -- ignore and discard
            end
            if button == 3 then
                logger.i(appName .. ": intercepted button3")
                onBack(event, app)
            elseif button == 4 then
                logger.i(appName .. ": intercepted button4")
                onForward(event, app)
            end
            return true -- discard
        end
    end)
end

-- onMouseBackForward(
--     "Google Chrome", 
--     function(event, app)
--         app:selectMenuItem({"History", "Back"})
--     end,
--     function(event, app)
--         app:selectMenuItem({"History", "Forward"})
--     end
-- )

-- onMouseBackForward(
--     "Brave Browser", 
--     function(event, app)
--         app:selectMenuItem({"History", "Back"})
--     end,
--     function(event, app)
--         app:selectMenuItem({"History", "Forward"})
--     end
-- )

onMouseBackForward(
    "Visual Studio",
    function()
        app:selectMenuItem({"Search", "Navigation History", "Navigate Back"})
    end,
    function()
        app:selectMenuItem({"Search", "Navigation History", "Navigate Forward"})
    end
)

onMouseBackForward(
    "Notes",
    function()
        hs.eventtap.keyStroke({'cmd', 'alt'}, '[')
    end,
    function()
        hs.eventtap.keyStroke({'cmd', 'alt'}, ']')
    end
)
