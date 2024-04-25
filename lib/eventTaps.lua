-- Simple convenience method to create and start an eventTap then store it in a
-- global variable so it doesn't get garbage collected
local obj = {}

obj.myEventTaps = {}

function obj:createEventTap(types, handler)
    table.insert(self.myEventTaps, hs.eventtap.new(types, handler):start())
end

return obj
