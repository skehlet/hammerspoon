hs.hotkey.bind({"cmd", "alt"}, "v", function() hs.eventtap.keyStrokes(hs.pasteboard.getContents()) end)

-- Older attempt:

-- myDoKeyStroke = function(modifiers, character)
--     local event = require("hs.eventtap").event
--     event.newKeyEvent(modifiers, string.lower(character), true):post()
--     event.newKeyEvent(modifiers, string.lower(character), false):post()
-- end

-- function slowPaste()
--     local str = hs.pasteboard.getContents()
--     for i = 1, #str do
--         local c = str:sub(i,i)
--         logger.i("do key stroke: " .. c)
--         myDoKeyStroke({}, c)
--         hs.timer.usleep(100000) 
--     end
-- end

-- hs.hotkey.bind({"cmd", "alt"}, "v", slowPaste)
