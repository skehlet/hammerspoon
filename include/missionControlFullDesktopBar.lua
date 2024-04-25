-- If missionControlFullDesktopBar installed, intercept Mission Control (F3) keypresses and launch it instead
-- See https://github.com/briankendall/missionControlFullDesktopBar
local logger = hs.logger.new('MissionControlFullDesktopBar', 'debug')
local hammer = require("lib.hammer")
local eventTaps = require("lib.eventTaps")

local MISSION_CONTROL_KEYCODE = 0xa0
local MCFDB_PATH = '/Applications/missionControlFullDesktopBar.app/Contents/MacOS/missionControlFullDesktopBar'

local mcfdbSize = hs.fs.attributes(MCFDB_PATH, 'size')
if mcfdbSize then
    logger.i('missionControlFullDesktopBar found, intercepting Mission Control key events')
    eventTaps:createEventTap({hs.eventtap.event.types.keyDown, hs.eventtap.event.types.keyUp}, function(event)
        if event:getKeyCode() == MISSION_CONTROL_KEYCODE then
            local isRepeat = event:getProperty(hs.eventtap.event.properties.keyboardEventAutorepeat)
            if isRepeat == 1 then
                return true -- ignore and discard
            end
            -- don't intercept cmd+f3 or ctrl+f3
            local flags = event:getFlags()
            if (flags.cmd or flags.ctrl) then
                return false -- propogate
            end
            if event:getType() == hs.eventtap.event.types.keyDown then
                -- logger.i('intercepted Mission Control DOWN')
                if hammer.isDown then
                    logger.i(
                        'intercepted Hammer+Mission Control DOWN, finding and killing missionControlFullDesktopBar...')
                    local mcfdb = hs.application.find("missionControlFullDesktopBar")
                    if mcfdb then
                        mcfdb:kill()
                    end
                end
                -- os.execute(MCFDB_PATH..' -d -i')
                os.execute(MCFDB_PATH .. ' -d')
                return true -- discard
            else
                -- logger.i('intercepted Mission Control UP')
                os.execute(MCFDB_PATH .. ' -d -r')
                return true -- discard
            end
        end
        return false -- propogate
    end)
end
