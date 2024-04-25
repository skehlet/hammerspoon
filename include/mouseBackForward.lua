-- Mouse buttons 4/5 to go Back/Forward in various apps, or move left/right if the hammer key is down
-- Thanks to: https://tom-henderson.github.io/2018/12/14/hammerspoon.html

local eventTaps = require("lib.eventTaps")
local hammer = require("lib.hammer")
local windowManagement = require("lib.windowManagement")

eventTaps:createEventTap({
    hs.eventtap.event.types.otherMouseDown
}, function (event)
    local button = event:getProperty(hs.eventtap.event.properties.mouseEventButtonNumber)

    -- Make Hammer+mouse4/mouse5 behave like hammer+left/hammer+right.
    if hammer.isDown then
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

    local app = hs.application.frontmostApplication()
    -- logger.i('otherMouseDown event, button: ' .. button .. ', frontmostApp: ' .. app:name())
    if app:name() == 'Google Chrome' or app:name() == 'Brave Browser' then
        local isRepeat = event:getProperty(hs.eventtap.event.properties.keyboardEventAutorepeat)
        if isRepeat == 1 then
            logger.i("Chrome/Brave: discarding repeat button 3/4")
            return true -- ignore and discard
        end
        if button == 3 then
            -- logger.i("Chrome/Brave: intercepted button3")
            app:selectMenuItem({"History", "Back"})
            return true
        elseif button == 4 then
            -- logger.i("Chrome/Brave: intercepted button4")
            app:selectMenuItem({"History", "Forward"})
            return true -- discard
        end
    -- 2023-09-05: Appears Slack added button3/4 support at some point, and I'm seeing double back/forward behavior, so comment it out.
    -- elseif app:name() == 'Slack' then
    --     -- Strangely, Hammerspoon can't see to get or otherwise work with the menu items.
    --     -- So another way is to fake typing the keyboard shortcuts.
    --     if button == 3 then
    --         --logger.i("Slack: intercepted button3")
    --         hs.eventtap.keyStroke({'cmd'}, 'left')
    --         return true -- discard
    --     elseif button == 4 then
    --         --logger.i("Slack: intercepted button4")
    --         hs.eventtap.keyStroke({'cmd'}, 'right')
    --         return true -- discard
    --     end
    elseif app:name() == 'Visual Studio' then
        if button == 3 then
            app:selectMenuItem({"Search", "Navigation History", "Navigate Back"})
            return true -- discard
        elseif button == 4 then
            app:selectMenuItem({"Search", "Navigation History", "Navigate Forward"})
            return true -- discard
        end

    elseif app:name() == 'Notes' then
        if button == 3 then
            -- logger.i("Notes: intercepted button3")
            hs.eventtap.keyStroke({'cmd', 'alt'}, '[')
            return true -- discard
        elseif button == 4 then
            -- logger.i("Notes: intercepted button4")
            hs.eventtap.keyStroke({'cmd', 'alt'}, ']')
            return true -- discard
        end

    end
end)
