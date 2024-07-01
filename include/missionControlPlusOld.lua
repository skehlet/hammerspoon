-- local logger = hs.logger.new('MissionControlPlus', 'debug')
-- local eventTaps = require("lib.eventTaps")

-- local MISSION_CONTROL_KEYCODE = 160
-- local keyDownAt = 0

-- function getCurrentMilliseconds()
--     local now = hs.timer.absoluteTime() -- nanoseconds
--     return now // 1000000 -- milliseconds
-- end

-- eventTaps:createEventTap({hs.eventtap.event.types.keyDown, hs.eventtap.event.types.keyUp}, function(event)
--     if event:getKeyCode() == MISSION_CONTROL_KEYCODE then
--         local isRepeat = event:getProperty(hs.eventtap.event.properties.keyboardEventAutorepeat)
--         if isRepeat == 1 then
--             return true -- ignore and discard
--         end
--         -- don't intercept cmd+f3 or ctrl+f3
--         local flags = event:getFlags()
--         if (flags.cmd or flags.ctrl) then
--             return false -- propogate
--         end


--         if event:getType() == hs.eventtap.event.types.keyDown then
--             logger.i('Intercepted Mission Control key DOWN')
--             keyDownAt = getCurrentMilliseconds()

--             -- 1. save current mouse position
--             local origMousePos = hs.mouse.absolutePosition()
--             -- 2. move mouse to x:0 y:0
--             hs.mouse.absolutePosition({x=0, y=0})
--             -- 3. trigger mission control
--             hs.spaces.toggleMissionControl()
--             -- 4. delay 0.1 sec
--             -- 5. restore saved mouse position
--             hs.timer.doAfter(0.1, function()
--                 hs.mouse.absolutePosition(origMousePos)
--             end)
            
--             return true -- discard
--         else -- keyUp
--             local downTime = getCurrentMilliseconds() - keyDownAt
--             logger.i('Intercepted Mission Control UP (was held down for '..downTime..'ms)')
--             if downTime < 150 then
--                 logger.i('IGNORING UP event from a quick press of Mission Control key')
--             else
--                 logger.i('This was an UP event from a long press of Mission Control key: toggling Mission Control')
--                 hs.spaces.toggleMissionControl()
--                 return true -- discard
--             end
--         end


--     end
--     return false -- propogate
-- end)
