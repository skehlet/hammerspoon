local hammer = require("lib.hammer")
local screen = require("lib.screen")

hammer:bind({'shift'}, 'l', function()
    hammer:onUpOnce(screen.systemSleep)
end)
