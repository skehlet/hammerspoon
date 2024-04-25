-- 2024-04-24 Haven't needed this in a long time, macOS must have finally sorted out multiple external monitor placement.
-- -- Switch monitors
-- -- This is a workaround to deal with macOS getting confused on which of my external monitors is left and right.
-- -- Hit the key binding and it will swap them.
-- -- Note I tried built-in Hammerspoon APIs, a C program, and a Python script, but 
-- -- found just calling out to `displayplacer` to be the simplest/most effective and it's a
-- -- maintained solution.
-- -- See https://github.com/Hammerspoon/hammerspoon/issues/1462#issuecomment-568534028

-- -- Unneeded, but keeping, where else am I going to store this:
-- -- local VIRTUALLY_LEFT_MONITOR_UUID = "4CE08EDE-BF77-49A0-8F23-6453DBAF6DCD"
-- -- local VIRTUALLY_RIGHT_MONITOR_UUID = "DEBC10C3-DF73-4222-B5D1-3027F6954EBC"
-- -- local PHYSICALLY_LEFT_MONITOR_SERIAL = "M5LMQS070425"
-- -- local PHYSICALLY_RIGHT_MONITOR_SERIAL = "M5LMQS064778"

-- -- Example command:
-- --[[
--  /opt/homebrew/bin/displayplacer \
-- 	"id:6DF848C4-4A01-4378-8222-02DBF53E0627 origin:(0,0)" \
-- 	"id:24B7AB28-EABA-46DE-90EA-2F69C91E67C5 origin:(2560,0)"
-- ]]--

-- local hammer = require("lib.hammer")

-- local EXT_MONITOR_NAME_PATTERN = 'VG27A'
-- local DISPLAYPLACER_PATH = '/opt/homebrew/bin/displayplacer'

-- function screenLayoutWatcher()
--     local d1, d2 = hs.screen.find(EXT_MONITOR_NAME_PATTERN)
--     local currentPrimary = hs.screen.primaryScreen()
--     local newPrimary
--     if d1 == currentPrimary then
--         newPrimary = d2
--     else
--         newPrimary = d1
--     end

--     local cmd = string.format(
--         '%s "id:%s origin:(%d,%d)" "id:%s origin:(%d,%d)"',
--         DISPLAYPLACER_PATH,
--         newPrimary:getUUID(), 0, 0,
--         currentPrimary:getUUID(), newPrimary:fullFrame().w, 0
--     )

--     print(cmd)
--     print(hs.execute(cmd))
-- end

-- -- A screen watcher might be nice but for now just handling manually.
-- --   screenWatcher = hs.screen.watcher.new(screenLayoutWatcher)
-- --   screenWatcher:start()
-- --   screenLayoutWatcher()

-- hammer:bind({'shift'}, 's', function ()
--     logger.i("Swapping monitors")
--     screenLayoutWatcher()
-- end)
