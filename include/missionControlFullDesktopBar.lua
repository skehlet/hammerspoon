-- If missionControlFullDesktopBar installed, intercept Mission Control (F3) keypresses and launch it instead
-- See https://github.com/briankendall/missionControlFullDesktopBar
-- Using daemonize.py seems to resolve/help Hammerspoon hanging issues with os.execute

local logger = hs.logger.new('MissionControlFullDesktopBar', 'debug')
local hammer = require("lib.hammer")
local eventTaps = require("lib.eventTaps")
local util = require("lib.util")

local MISSION_CONTROL_KEYCODE = 0xa0
-- local MCFDB_PATH = '/Applications/missionControlFullDesktopBar.app/Contents/MacOS/missionControlFullDesktopBar'
local MCFDB_PATH = '/Users/skehlet/Library/Developer/Xcode/DerivedData/missionControlFullDesktopBar-cecfmmntuhizngavuwnoabrsqvib/Build/Products/Debug/missionControlFullDesktopBar.app/Contents/MacOS/missionControlFullDesktopBar'
-- local USE_MCFDB_IN_DAEMON_MODE = true
local DAEMONIZE_PATH = hs.fs.currentDir() .. "/misc/daemonize.py"
local LONG_PRESS_THRESHOLD_MS = 500

local keyDownAt = 0

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

function terminateMissionControlFullDesktopBar()
    local mcfdb = hs.application.find("missionControlFullDesktopBar")
    if mcfdb then
        mcfdb:kill()
    end
end

function onMissionControlKeyDown()
    if hammer.isDown then
        logger.i('Hammer+Mission Control key DOWN: finding and killing missionControlFullDesktopBar')
        terminateMissionControlFullDesktopBar()
    end

    print("Mission Control key DOWN, launching missionControlFullDesktopBar")
    keyDownAt = util.getCurrentMilliseconds()
    -- if USE_MCFDB_IN_DAEMON_MODE then
    --     os.execute(DAEMONIZE_PATH .. " " .. MCFDB_PATH .. ' -d -i')
    -- else
    --     os.execute(DAEMONIZE_PATH .. " " .. MCFDB_PATH)
    -- end
    os.execute(DAEMONIZE_PATH .. " " .. MCFDB_PATH)
end

function onMissionControlKeyUp()
    if hammer.isDown then
        return -- ignore
    end

    -- TRY: always use my own keyUp timing logic. This might avoid unintended MC closures when the system is laggy.

    -- if USE_MCFDB_IN_DAEMON_MODE then
    --     print('Mission Control key UP')
    --     os.execute(DAEMONIZE_PATH .. " " .. MCFDB_PATH .. ' -r')
    -- else
        -- if not daemonized, can't use -r, close MC ourselves IFF it was a long press:
        local downTime = util.getCurrentMilliseconds() - keyDownAt
        if downTime < LONG_PRESS_THRESHOLD_MS then
            print('Mission Control key UP: ignoring quick release (' .. downTime .. 'ms)')
        else
            print('Mission Control key UP: handling long press (' .. downTime .. 'ms): closing Mission Control')
            hs.spaces.closeMissionControl()
        end
    -- end
end
