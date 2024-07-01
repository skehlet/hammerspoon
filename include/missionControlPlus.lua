-- local MISSION_CONTROL_KEYCODE = 160 -- Works for my keyboard, YMMV
-- local LONG_PRESS_THRESHOLD_MS = 250
-- local keyDownAt = 0

-- local missionControlMoveMouseToX = 1000
-- local missionControlMoveMouseToY = 0
-- local win = hs.window.focusedWindow()
-- if win then
--     local screenFrame = win:screen():fullFrame()
--     missionControlMoveMouseToX = math.floor(screenFrame.w / 2)
--     print("Half the screen width is " .. missionControlMoveMouseToX)
--     -- missionControlMoveMouseToX = screenFrame.w - 1
--     -- print("Upon invoking Mission Control, will move the mouse to x: " .. missionControlMoveMouseToX)
-- end


-- -- missionControlEventTap must be global to avoid garbage collection
-- missionControlEventTap = hs.eventtap.new({
--     hs.eventtap.event.types.keyDown,
--     hs.eventtap.event.types.keyUp
-- }, function(event)
--     if event:getKeyCode() ~= MISSION_CONTROL_KEYCODE then
--         return false -- propogate
--     end

--     -- don't intercept if cmd or ctrl was held down
--     local flags = event:getFlags()
--     if flags.cmd or flags.ctrl then
--         return false -- propogate
--     end

--     local isRepeat = event:getProperty(hs.eventtap.event.properties.keyboardEventAutorepeat)
--     if isRepeat == 1 then
--         return true -- discard
--     end

--     if event:getType() == hs.eventtap.event.types.keyDown then
--         onMissionControlKeyDown()
--     else
--         onMissionControlKeyUp()
--     end

--     return true -- discard
-- end)

-- missionControlEventTap:start()

-- function getCurrentMilliseconds()
--     local now = hs.timer.absoluteTime() -- nanoseconds
--     return now // 1000000 -- milliseconds
-- end


-- -- -- this is pretty solid, preserving
-- -- function onMissionControlKeyDown()
-- --     print('Intercepted Mission Control key DOWN')
-- --     keyDownAt = getCurrentMilliseconds()
-- --     local origMousePos = hs.mouse.absolutePosition()
-- --     hs.spaces.toggleMissionControl()
-- --     hs.mouse.absolutePosition({x = halfScreenWidthX, y = 0})

-- --     -- hs.timer.doAfter(0.005, function()
-- --     --     hs.mouse.absolutePosition({x = 0, y = 0})
-- --     -- end)

-- --     -- local count = 5
-- --     -- hs.timer.doUntil(function ()
-- --     --     count = count - 1
-- --     --     return count <= 0
-- --     -- end, function ()
-- --     --     hs.mouse.absolutePosition({x = 0, y = 0})
-- --     --     print("BAM " .. count)
-- --     -- end, 0.001)

-- --     hs.timer.doAfter(0.05, function()
-- --         -- -- adjust the original mouse position to account for mouse movement during the hijack window
-- --         -- local deltaMousePos = hs.mouse.absolutePosition()
-- --         -- origMousePos.x = origMousePos.x + deltaMousePos.x
-- --         -- origMousePos.y = origMousePos.y + deltaMousePos.y
-- --         -- hs.eventtap.leftClick({x=0, y=0}, 0)
-- --         hs.mouse.absolutePosition({x = halfScreenWidthX, y = 0})
-- --         hs.mouse.absolutePosition(origMousePos)
-- --     end)
-- -- end



-- -- -- trying a drag technique, but this is not good, the window being dragged looks weird in MC
-- -- function onMissionControlKeyDown()
-- --     print('Intercepted Mission Control key DOWN')
-- --     keyDownAt = getCurrentMilliseconds()
-- --     local origMousePos = hs.mouse.absolutePosition()
-- --     print("Mouse's original position, x: " .. origMousePos.x .. ', ' .. origMousePos.y)

-- --     local dragX = 1350
-- --     local dragY = 740
-- --     local win = hs.window.focusedWindow()
-- --     if win then
-- --         local frame = win:frame()
-- --         print("Frame: x: " .. frame.x .. ", y: " .. frame.y .. ", h: " .. frame.h .. ", w: " .. frame.w)
-- --         dragX = frame.x + 100
-- --         dragY = frame.y + 14
-- --     else
-- --         print("No focused window")
-- --     end


-- --     print("DRAG START! x: " .. dragX .. ", y: " .. dragY)
-- --     -- moveMouseTo(dragX, dragY)
-- --     hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDown, {x=dragX,y=dragY}):post()
-- --     hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDragged, {x=dragX,y=dragY}):post()
-- --     -- hs.spaces.toggleMissionControl()
-- --     -- moveMouseTo(missionControlMoveMouseToX, missionControlMoveMouseToY)
-- --     hs.timer.doAfter(0.1, function()
-- --         -- -- adjust the original mouse position to account for mouse movement during the hijack window
-- --         -- local newMousePos = hs.mouse.absolutePosition()
-- --         -- local deltaX = newMousePos.x - missionControlMoveMouseToX
-- --         -- local deltaY = newMousePos.y - missionControlMoveMouseToY
-- --         -- print("Observed Mouse delta of x: " .. deltaX .. ', ' .. deltaY)
-- --         -- origMousePos.x = origMousePos.x + deltaX
-- --         -- origMousePos.y = origMousePos.y + deltaY

-- --         -- moveMouseTo(missionControlMoveMouseToX, missionControlMoveMouseToY)
-- --         -- moveMouseTo(origMousePos.x, origMousePos.y)
-- --         hs.spaces.toggleMissionControl()
-- --         print("DRAG STOP!")
-- --         -- moveMouseTo(dragX, dragY)
-- --         hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDragged, {x=dragX,y=dragY}):post()
-- --         hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseUp, {x=dragX,y=dragY}):post()
-- --         moveMouseTo(origMousePos.x, origMousePos.y)
-- --     end)
-- -- end





-- -- this one is good, it works the best so far
-- -- Still not perfect, doesn't work if you're moving your mouse down
-- function onMissionControlKeyDown()
--     keyDownAt = getCurrentMilliseconds()
--     if isMissionControlActive() then
--         print("MC DOWN: Closing Mission Control")
--         hs.spaces.closeMissionControl()
--     else
--         local origMousePos = hs.mouse.absolutePosition()
--         print("MC DOWN: Activating Mission Control; mouse's original position, x: " .. origMousePos.x .. ', ' .. origMousePos.y)
--         moveMouseTo(missionControlMoveMouseToX, missionControlMoveMouseToY)
--         hs.spaces.toggleMissionControl()
--         hs.timer.doAfter(0.1, function()
--             -- adjust the original mouse position to account for mouse movement during the hijack window
--             local newMousePos = hs.mouse.absolutePosition()
--             local deltaX = newMousePos.x - missionControlMoveMouseToX
--             local deltaY = newMousePos.y - missionControlMoveMouseToY
--             print("MC DOWN: Observed Mouse delta of x: " .. deltaX .. ', ' .. deltaY)
--             origMousePos.x = origMousePos.x + deltaX
--             origMousePos.y = origMousePos.y + deltaY
--             -- move mouse to trigger thumbnails one more time, just for good measure
--             moveMouseTo(missionControlMoveMouseToX, missionControlMoveMouseToY)
--             -- then put it back where it was, originally
--             moveMouseTo(origMousePos.x, origMousePos.y)
--         end)
--     end
-- end






-- -- function onMissionControlKeyDown()
-- --     keyDownAt = getCurrentMilliseconds()
-- --     if isMissionControlActive() then
-- --         print("MC DOWN: Closing Mission Control")
-- --         hs.spaces.closeMissionControl()
-- --     else
-- --         local origMousePos = hs.mouse.absolutePosition()
-- --         print("MC DOWN: Activating Mission Control; mouse's original position, x: " .. origMousePos.x .. ', ' .. origMousePos.y)
-- --         -- moveMouseTo(missionControlMoveMouseToX, missionControlMoveMouseToY)
-- --         -- hs.spaces.toggleMissionControl()

-- --         -- os.execute('/opt/homebrew/bin/cliclick -r m:=-2560,0 w:1')
-- --         hs.task.new(
-- --             '/opt/homebrew/bin/cliclick',
-- --             function ()
-- --                 print("cliclick done")
-- --             end,
-- --             {
-- --                 '-r',
-- --                 'm:=-2560,0',
-- --                 'w:1'
-- --             }):start()


-- --         -- hs.timer.doAfter(0.1, function()
-- --         --     -- adjust the original mouse position to account for mouse movement during the hijack window
-- --         --     local newMousePos = hs.mouse.absolutePosition()
-- --         --     local deltaX = newMousePos.x - missionControlMoveMouseToX
-- --         --     local deltaY = newMousePos.y - missionControlMoveMouseToY
-- --         --     print("MC DOWN: Observed Mouse delta of x: " .. deltaX .. ', ' .. deltaY)
-- --         --     origMousePos.x = origMousePos.x + deltaX
-- --         --     origMousePos.y = origMousePos.y + deltaY
-- --         --     -- move mouse to trigger thumbnails one more time, just for good measure
-- --         --     -- moveMouseTo(missionControlMoveMouseToX, missionControlMoveMouseToY)
-- --         --     -- then put it back where it was, originally
-- --         --     -- moveMouseTo(origMousePos.x, origMousePos.y)
-- --         -- end)
-- --     end
-- -- end




-- -- doesn't work
-- -- function onMissionControlKeyDown()
-- --     keyDownAt = getCurrentMilliseconds()
-- --     if isMissionControlActive() then
-- --         print("MC DOWN: Closing Mission Control")
-- --         hs.spaces.closeMissionControl()
-- --     else
-- --         local origMousePos = hs.mouse.absolutePosition()
-- --         print("MC DOWN: Activating Mission Control; mouse's original position, x: " .. origMousePos.x .. ', ' .. origMousePos.y)
-- --         moveMouseTo(-2559, 1)
-- --         hs.spaces.toggleMissionControl()
-- --         hs.timer.doAfter(0.2, function()
-- --             -- -- adjust the original mouse position to account for mouse movement during the hijack window
-- --             -- local newMousePos = hs.mouse.absolutePosition()
-- --             -- local deltaX = newMousePos.x - missionControlMoveMouseToX
-- --             -- local deltaY = newMousePos.y - missionControlMoveMouseToY
-- --             -- print("MC DOWN: Observed Mouse delta of x: " .. deltaX .. ', ' .. deltaY)
-- --             -- origMousePos.x = origMousePos.x + deltaX
-- --             -- origMousePos.y = origMousePos.y + deltaY
-- --             -- move mouse to trigger thumbnails one more time, just for good measure
-- --             -- moveMouseTo(missionControlMoveMouseToX, missionControlMoveMouseToY)
-- --             -- then put it back where it was, originally
-- --             moveMouseTo(origMousePos.x, origMousePos.y)
-- --         end)
-- --     end
-- -- end


-- -- doesn't work
-- -- -- It's weird. Calling isMissionControlActive() takes 180ms+ when MC is active. So you want to avoid that.
-- -- -- So don't use this waitUtil() technique. Better to just doAfter.
-- -- function onMissionControlKeyDown()
-- --     keyDownAt = getCurrentMilliseconds()
-- --     if isMissionControlActive() then
-- --         print("MC DOWN: Closing Mission Control")
-- --         hs.spaces.closeMissionControl()
-- --     else
-- --         local origMousePos = hs.mouse.absolutePosition()
-- --         print("MC DOWN: Activating Mission Control; mouse's original position, x: " .. origMousePos.x .. ', ' .. origMousePos.y)
-- --         moveMouseTo(missionControlMoveMouseToX, missionControlMoveMouseToY)
-- --         hs.spaces.toggleMissionControl()
-- --         local busyWaitStartTime = getCurrentMilliseconds()

-- --         hs.timer.waitUntil(
-- --             function ()
-- --                 local now = getCurrentMilliseconds()
-- --                 print("waitUntil called at: " ..  now .. ", diff: " .. (now - busyWaitStartTime) .. "ms")
-- --                 local isReady = isMissionControlActive()
-- --                 if not isReady then
-- --                     print("MC DOWN: MC still not ready after " .. (getCurrentMilliseconds() - busyWaitStartTime) .. "ms")
-- --                 end
-- --                 return isReady
-- --             end, 
-- --             function()
-- --                 print("MC DOWN: Mission Control available after " .. (getCurrentMilliseconds() - busyWaitStartTime) .. "ms")
-- --                 -- adjust the original mouse position to account for mouse movement during the hijack window
-- --                 local newMousePos = hs.mouse.absolutePosition()
-- --                 local deltaX = newMousePos.x - missionControlMoveMouseToX
-- --                 local deltaY = newMousePos.y - missionControlMoveMouseToY
-- --                 print("MC DOWN: Observed Mouse delta of x: " .. deltaX .. ', ' .. deltaY)
-- --                 origMousePos.x = origMousePos.x + deltaX
-- --                 origMousePos.y = origMousePos.y + deltaY
-- --                 -- move mouse to trigger thumbnails one more time, just for good measure
-- --                 moveMouseTo(missionControlMoveMouseToX, missionControlMoveMouseToY)
-- --                 -- then put it back where it was, originally
-- --                 moveMouseTo(origMousePos.x, origMousePos.y)
-- --             end,
-- --             0.01
-- --         )
-- --     end
-- -- end


-- function onMissionControlKeyUp()
--     local downTime = getCurrentMilliseconds() - keyDownAt
--     if downTime < LONG_PRESS_THRESHOLD_MS then
--         print('MC UP: IGNORING quick press (' .. downTime .. 'ms)')
--     else
--         if isMissionControlActive() then
--             hs.spaces.closeMissionControl()
--             print('MC UP: HANDLING long press (' .. downTime .. 'ms): closing Mission Control')
--         else
--             print('MC UP: HANDLING long press (' .. downTime .. 'ms): Mission Control is not active, so nothing to do')
--         end
--     end
-- end

-- -- BEGIN copy/paste core Hammerspoon code
-- local axuielement = require("hs.axuielement")
-- local _dockElement
-- local getDockElement = function()
--     local startTime = getCurrentMilliseconds()
--     -- if the Dock is killed for some reason, its element will be invalid
--     if not (_dockElement and _dockElement:isValid()) then
--         print("getDockElement: cached dockElement was invalid")
--         local dockApp = hs.application.applicationsForBundleID("com.apple.dock")[1]
--         _dockElement = axuielement.applicationElement(dockApp)
--     end
--     print("getDockElement: took " .. (getCurrentMilliseconds() - startTime) .. "ms")
--     return _dockElement
-- end

-- local _missionControlGroup
-- local getMissionControlGroup = function()
--     local startTime = getCurrentMilliseconds()
--     if not (_missionControlGroup and _missionControlGroup:isValid()) then
--         _missionControlGroup = nil
--         local dockElement = getDockElement()
--         for _,v in ipairs(dockElement) do
--             if v.AXIdentifier == "mc" then
--                 print("getMissionControlGroup: took " .. (getCurrentMilliseconds() - startTime) .. "ms")
--                 _missionControlGroup = v
--                 break
--             end
--         end
--     end
--     return _missionControlGroup
-- end
-- -- END copy/paste core Hammerspoon code

-- function isMissionControlActive()
--     local startTime = getCurrentMilliseconds()
--     -- local dockApp = hs.application.applicationsForBundleID("com.apple.dock")[1]
--     -- if 
--     -- local dockElement = hs.axuielement.applicationElement(dockApp)
--     -- for _,v in ipairs(dockElement) do
--     --     if v.AXIdentifier == "mc" then
--     --         print("isMissionControlActive: took " .. (getCurrentMilliseconds() - startTime) .. "ms")
--     --         return true
--     --     end
--     -- end
--     -- print("isMissionControlActive: took " .. (getCurrentMilliseconds() - startTime) .. "ms")
--     -- return false

--     local missionControlGroup = getMissionControlGroup()
--     print("isMissionControlActive: took " .. (getCurrentMilliseconds() - startTime) .. "ms")
--     if missionControlGroup then
--         return true
--     else
--         return false
--     end

--     -- local dockElement = getDockElement()
--     -- local lenStartTime = getCurrentMilliseconds()
--     -- local len = #dockElement
--     -- print("isMissionControlActive: getting the length took " .. (getCurrentMilliseconds() - startTime) .. "ms")
--     -- if len > 1 then
--     --     print("isMissionControlActive: took " .. (getCurrentMilliseconds() - startTime) .. "ms")
--     --     return true
--     -- end
--     -- return false
-- end

-- function moveMouseTo(x, y)
--     print("Moving mouse to " .. x .. ', ' .. y)
--     hs.mouse.absolutePosition({x = x, y = y})
-- end
