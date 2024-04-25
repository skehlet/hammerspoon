local hammer = require("lib.hammer")
local screen = require("lib.screen")

hammer:bind({}, 'l', function()
    -- Wait for the release of the hammer key before activating screen lock.
    -- This solves issues I was having of the hammer key getting "stuck" since
    -- the release wouldn't be noticed once the screen was locked.
    hammer:onUpOnce(screen.lockScreen)
end)

hs.hotkey.bind({}, 'f15', screen.lockScreen) -- F15 (Pause on my PC keyboard)

-- hs.hotkey.bind({}, 'f19', screen.lockScreen) -- Disabled, no longer using a (Mac) keyboard with F19

-- comment this out for now, I don't have a keyboard with eject anymore
-- -- https://github.com/Hammerspoon/hammerspoon/issues/1220#issuecomment-276941617
-- eventTaps:createEventTap({
--     hs.eventtap.event.types.systemDefined
-- }, function(event)
--     -- http://www.hammerspoon.org/docs/hs.eventtap.event.html#systemKey
--     event = event:systemKey()
--     -- http://stackoverflow.com/a/1252776/1521064
--     local next = next
--     -- Check empty table
--     if next(event) then
--         if event.key == 'EJECT' and event.down then
--             -- logger.i('caught EJECT DOWN: ' .. event.key)
--             lockScreen()
--         end
--     end
-- end)
