-- -- Doesn't work

-- -- 1. Clicking the DJ button only works some of the time. Could be the
-- --    coordiantes are wrong, but seems more like a delay that the Spotify app
-- --    isn't focused yet. Maybe two clicks would solve this. Update: it does seem
-- --    to work, but then it doesn't move the mouse back.

-- -- 2. Doesn't properly focus back on the original window. It may require adding
-- --     some delay or something. Update: a delay does help

-- -- 3. Still not finding the button, maybe a percentage would help instead of a
-- --    fixed value. Update: no, percentage doesn't work. It's neither an exact
-- --    offset nor an exact percentage.

-- -- Spotify DJ button
-- function clickSpotifyDj()
--     local app = hs.application.find("Spotify")
--     if app ~= nil then
--         print('clickSpotifyDj: found Spotify app: ' .. app:name())
--         local win = app:findWindow("")
--         if win ~= nil then
--             local origFrame = win:frame()
--             print('clickSpotifyDj: found Spotify window: ' .. win:title()
--                 .. ', x: ' .. origFrame.x .. ', y: ' .. origFrame.y 
--                 .. ', w: ' .. origFrame.w .. ', h: ' .. origFrame.h)

--             local frame = win:frame()
--             frame.w = 1280
--             frame.h = 707
--             print('clickSpotifyDj: resizing Spotify to known size, w: ' .. frame.w .. ', h: ' .. frame.h)
--             win:setFrame(frame)

--             -- these are good for the DJ button
--             -- the button moves around, these numbers are not reliable
--             -- local clickX = frame.x + frame.w - 260
--             local clickX = frame.x + frame.w - 290
--             local clickY = frame.y + frame.h - 42

--             -- -- these are good for the Next track button (for debugging instead of repeatedly hitting the DJ button)
--             -- local clickX = frame.x + frame.w - 592
--             -- local clickY = frame.y + frame.h - 52

--             local origWin = hs.window.focusedWindow()
--             if origWin ~= nil then
--                 print('clickSpotifyDj: saving origWin: ' .. origWin:title())
--             end

--             local origMousePos = hs.mouse.absolutePosition()
--             print('clickSpotifyDj: saving origMousePos, x: ' .. origMousePos.x .. ', y: ' .. origMousePos.y)

--             win:focus()
--             print('clickSpotifyDj: clicking at: ' .. clickX .. ", " .. clickY)
--             hs.mouse.absolutePosition({x=clickX, y=clickY}) -- don't know why this is needed, but it is
--             -- hs.eventtap.leftClick({x=clickX, y=clickY}, 0)
--             -- hs.mouse.absolutePosition(origMousePos)

--             -- hs.timer.delayed.new(0.1, function()
--             --     print('clickSpotifyDj: restoring Spotify window size, w: ' .. origFrame.w .. ', h: ' .. origFrame.h)
--             --     win:setFrame(origFrame)
--             --     if origWin ~= nil then
--             --         print('clickSpotifyDj: focusing back on: ' .. origWin:title())
--             --         origWin:focus()
--             --     end
--             -- end):start()
--         end
--     end
-- end

-- eventTaps:createEventTap({
--     hs.eventtap.event.types.systemDefined
-- }, function(event)
--     local systemKey = event:systemKey()
--     local flags = event:getFlags()
--     if systemKey.key == 'FAST' and systemKey.down and flags.shift then
--         print('caught shift+FAST DOWN: ' .. systemKey.key)
--         clickSpotifyDj()
--     end
-- end)
