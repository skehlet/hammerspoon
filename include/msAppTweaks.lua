local eventTaps = require("lib.eventTaps")

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

-- If using Excel, fix broken keybindings
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
