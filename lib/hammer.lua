-- The Hammer key
-- Install com.stevekehlet.RemapCapsLockToF20.plist (see the README) to map Caps Lock to F20.
local logger = hs.logger.new('hammer.lua', 'debug')
local util = require("lib.util")

local hs = hs
local hammerKey = 'f20'
local hammerKeyCode = hs.keycodes.map[hammerKey]

-- Lua's `require()` only sources a file once.
-- So all scripts requiring this file will get this same hammer instance.
local hammer = hs.hotkey.modal.new()

hammer.onUpOnceCallbacks = {}

function hammer:entered()
    self.isDown = true
    self.lastEnterTime = hs.timer.absoluteTime()
end

function hammer:onUpOnce(fn)
    table.insert(self.onUpOnceCallbacks, fn)
end

function hammer:exited()
    self.isDown = false
    self.lastEnterTime = nil
    while #self.onUpOnceCallbacks > 0 do
        fn = table.remove(self.onUpOnceCallbacks, 1)
        fn()
    end
end

-- This programmatically generates a hotkey binding for every possible
-- combination of modifier keys, ensuring the Hammer key bindings always work,
-- regardless of whether you hit cmd/alt/shift/ctrl or the hammer first.

local modifiers = {'cmd', 'alt', 'shift', 'ctrl'}
-- There are 2^4 = 16 combinations of these 4 modifiers.
-- We loop from 0 to 15. Each number's binary representation
-- will tell us which modifiers to include in the combination.
for i = 0, 15 do
    local current_mods = {}
    -- Check the bits for the current number `i`
    if (i & 1) > 0 then table.insert(current_mods, modifiers[1]) end -- cmd
    if (i & 2) > 0 then table.insert(current_mods, modifiers[2]) end -- alt
    if (i & 4) > 0 then table.insert(current_mods, modifiers[3]) end -- shift
    if (i & 8) > 0 then table.insert(current_mods, modifiers[4]) end -- ctrl

    -- Create a binding for this specific combination of modifiers
    hs.hotkey.bind(current_mods, hammerKey,
        function() hammer:enter() end, -- KeyDown
        function() hammer:exit() end,  -- KeyUp
        function() end                 -- KeyRepeat (do nothing)
    )
end

-- -- This block implements a workaround for occasional missed "up" events in the Hammer modal.
-- -- By comparing the current time with when the modal was activated, it detects stale states and resets them.
-- -- This ensures that even if a "hammer up" event is dropped, the modal doesn't remain active indefinitely.

-- -- Define how many seconds must pass before we consider the state "stale".
-- -- You can adjust this value to your preference.
-- local STALE_THRESHOLD_SECONDS = 3

-- -- Store a reference to the original hammer:bind function
-- local original_hammer_bind = hammer.bind

-- -- Redefine hammer:bind with our new function
-- function hammer:bind(modifiers, key, fn)
--     -- Create a new "wrapped" function that will be executed by the hotkey
--     local wrapped_fn = function()
--         -- Ensure lastEnterTime exists to avoid errors
--         if not self.lastEnterTime then
--             print("Blocked hotkey: Hammer modal is not active.")
--             self:exit() -- Clean up just in case
--             return
--         end

--         local now_ns = hs.timer.absoluteTime()
--         local elapsed_ns = now_ns - self.lastEnterTime
--         local elapsed_s = elapsed_ns / 1e9 -- Convert nanoseconds to seconds

--         -- Check if the elapsed time is less than our threshold
--         if elapsed_s < STALE_THRESHOLD_SECONDS then
--             -- The key press is recent. Run the intended function.
--             fn()
--         else
--             -- The key has been "down" for an unusually long time.
--             -- Assume the state is stale, block the action, and reset.
--             print(string.format("Blocked stale hotkey: Hammer down for %.2fs. Resetting.", elapsed_s))
--             self:exit()
--         end
--     end

--     -- Call the original :bind function with our new, wrapped function
--     original_hammer_bind(self, modifiers, key, wrapped_fn)
-- end

return hammer
