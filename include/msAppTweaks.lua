local eventTaps = require("lib.eventTaps")
-- local util = require("lib.util")
local logger = hs.logger.new('caffeine.lua', 'debug')

-- If using O365 Outlook or Calendar, intercept option-delete and
-- instead send: option-shift-left then delete
-- Currently this is a very annoying bug in O365:
-- https://answers.microsoft.com/en-us/msoffice/forum/all/mac-option-delete-keyboard-shortcut-to-delete-word/2907b079-e37d-4032-add3-ffb0d67cedd8
-- eventTaps:createEventTap({
--     hs.eventtap.event.types.keyDown
-- }, function(event)
--     if event:getKeyCode() == hs.keycodes.map['delete'] and event:getFlags().alt then
--         local win = hs.window.focusedWindow()
--         if win:title():find('- Outlook -') then
--             logger.i('O365 option-delete workaround firing!')
--             hs.eventtap.keyStroke({'alt', 'shift'}, 'left', 0)
--             hs.eventtap.keyStroke({}, 'delete', 0)
--             return true -- discard
--         end
--     end
-- end)

-- If using O365 Outlook webmail client, discard alt up/down notifications. This
-- is to workaround an annoying (to me) behavior where Outlook will intercept an
-- option down+up sequence, when it's inadvertently done without modifying
-- another key, and show Windows-style alt hotkeys in the Outlook web app,
-- preventing subsequent use of the option key for moving backwards/forwards
-- between words (option-left, option-right).
-- Logic:
-- If Outlook web mail is the current focused application
-- AND the flagsChanged event is for the alt key (don't care either up or down)
-- THEN, discard the event
eventTaps:createEventTap({
    hs.eventtap.event.types.flagsChanged
}, function(event)
    local win = hs.window.focusedWindow()
    if win and win:title():find('- Outlook -') and event:getKeyCode() == hs.keycodes.map['alt'] then
        logger.i("O365 Mail alt key workaround, ignoring alt flags changed event")
        return true -- Discard the raw alt key up or down
    end
end)

-- If using Excel, try to fix some very un-mac-like keybindings
eventTaps:createEventTap({
    hs.eventtap.event.types.keyDown
}, function(event)
    if hs.application.frontmostApplication():name() == "Microsoft Excel" then
        if event:getFlags().cmd then
            local flags = {}
            if event:getFlags().shift then
                table.insert(flags, 'shift')
            end
            -- util.dumpTable(flags)

            if event:getKeyCode() == hs.keycodes.map['left'] then
                hs.eventtap.keyStroke(flags, 'home', 0)
                return true -- discard
            elseif event:getKeyCode() == hs.keycodes.map['right'] then
                hs.eventtap.keyStroke(flags, 'end', 0)
                return true -- discard
            end
        end

        if event:getKeyCode() == hs.keycodes.map['delete'] and event:getFlags().alt then
            -- logger.i('Excel option-delete!')
            hs.eventtap.keyStroke({'alt', 'shift'}, 'left', 0)
            hs.eventtap.keyStroke({}, 'delete', 0)
            return true -- discard
        end

    end
end)
