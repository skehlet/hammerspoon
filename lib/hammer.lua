-- The Hammer key
-- Install com.stevekehlet.RemapCapsLockToF18.plist (see the README) to map Caps Lock to F18.
local logger = hs.logger.new('hammer.lua', 'debug')

local eventTaps = require("lib.eventTaps")

local hammer = hs.hotkey.modal.new()

hammer.onUpOnceCallbacks = {}

function hammer:entered()
    logger.i("Hammer down")
    self.isDown = true
end

function hammer:onUpOnce(fn)
    table.insert(self.onUpOnceCallbacks, fn)
end

function hammer:exited()
    logger.i("Hammer up")
    self.isDown = false
    while #self.onUpOnceCallbacks > 0 do
        fn = table.remove(self.onUpOnceCallbacks, 1)
        fn()
    end
end

-- Capture presses and releases of F18 to activate the hammer
eventTaps:createEventTap({hs.eventtap.event.types.keyDown, hs.eventtap.event.types.keyUp}, function(event)
    -- logger.i('caught key: ' .. event:getKeyCode() .. ' of type: ' .. event:getType())
    if event:getKeyCode() == hs.keycodes.map['f18'] then
        local isRepeat = event:getProperty(hs.eventtap.event.properties.keyboardEventAutorepeat)
        if isRepeat > 0 then
            return true -- ignore and discard
        end
        if event:getType() == hs.eventtap.event.types.keyDown then
            hammer:enter()
            return true
        else
            hammer:exit()
            return true
        end
    end
end)

return hammer
