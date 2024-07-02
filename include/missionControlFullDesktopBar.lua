-- If missionControlFullDesktopBar installed, intercept Mission Control (F3) keypresses and launch it instead
-- See https://github.com/briankendall/missionControlFullDesktopBar
local logger = hs.logger.new('MissionControlFullDesktopBar', 'debug')
local hammer = require("lib.hammer")
local eventTaps = require("lib.eventTaps")

local MISSION_CONTROL_KEYCODE = 0xa0
local MCFDB_PATH = '/Applications/missionControlFullDesktopBar.app/Contents/MacOS/missionControlFullDesktopBar'
-- local MCFDB_PATH = '/Users/skehlet/Library/Developer/Xcode/DerivedData/missionControlFullDesktopBar-cecfmmntuhizngavuwnoabrsqvib/Build/Products/Debug/missionControlFullDesktopBar.app/Contents/MacOS/missionControlFullDesktopBar'

local mcfdbSize = hs.fs.attributes(MCFDB_PATH, 'size')
if mcfdbSize then
    logger.i('missionControlFullDesktopBar found, intercepting Mission Control key events')
    eventTaps:createEventTap({
        hs.eventtap.event.types.keyDown,
        hs.eventtap.event.types.keyUp
    }, function(event)
        if event:getKeyCode() ~= MISSION_CONTROL_KEYCODE then
            return false -- propogate
        end

        -- don't intercept if cmd or ctrl was held down
        local flags = event:getFlags()
        if flags.cmd or flags.ctrl then
            return false -- propogate
        end

        local isRepeat = event:getProperty(hs.eventtap.event.properties.keyboardEventAutorepeat)
        if isRepeat == 1 then
            return true -- discard
        end

        if event:getType() == hs.eventtap.event.types.keyDown then
            onMissionControlKeyDown()
        else
            onMissionControlKeyUp()
        end

        return true -- discard
    end)
end

function onMissionControlKeyDown()
    print("Mission Control key DOWN")
    if hammer.isDown then
        logger.i('intercepted Hammer+Mission Control DOWN, finding and killing missionControlFullDesktopBar...')
        local mcfdb = hs.application.find("missionControlFullDesktopBar")
        if mcfdb then
            mcfdb:kill()
        end
    end
    os.execute(MCFDB_PATH .. ' -d -i')
end

function onMissionControlKeyUp()
    print("Mission Control key UP")
    if hammer.isDown then
        -- ignore
        return
    end
    os.execute(MCFDB_PATH .. ' -r')
end