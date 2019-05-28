local logger = hs.logger.new('init.lua', 'debug')
local util = require('util')

local MISSION_CONTROL_KEYCODE = 0xa0
local F17_KEYCODE = 0x40

hs.window.animationDuration = 0
-- eliminate some warnings from showing up in the log:
for idx, name in ipairs({
    'nplastpass',
    'Code Helper',
    'Postman Helper',
    'Slack Helper'
}) do
    hs.window.filter.ignoreAlways[name] = true
end

-- reload hammerspoon config automatically on save
local function reloadConfig(files)
    local doReload = false
    for _, file in pairs(files) do
        if file:sub(-4) == '.lua' then
            doReload = true
        end
    end
    if doReload then
        hs.reload()
    end
end

-- note myWatcher and other variables are deliberately global so they're never garbage collected
myWatcher = hs.pathwatcher.new(os.getenv('HOME')..'/.hammerspoon/', reloadConfig):start()

local function move(cb)
    local win = hs.window.focusedWindow()
    if win then
        local frame = win:frame()
        local screenFrame = win:screen():frame()
        frame.x, frame.y, frame.w, frame.h = cb(frame, screenFrame)
        -- logger.d(win:title()..' to '..frame.x..','..frame.y..','..frame.w..','..frame.h)
        win:setFrame(frame)
  end
end

local function lockScreen()
    -- built-in screensaver:
    -- hs.caffeinate.startScreensaver()
    -- this one just blanks the screen, no photos/etc
    --os.execute('/usr/local/bin/lockscreen')
    -- To lock screen, the following requires you have "Require password immediately after sleep or screen saver begins" 
    -- set under System Preferences, Security & Privacy, General.
    os.execute('pmset displaysleepnow')
end

-- Use Karabiner-Elements to map caps_lock to f18.
-- Then use Hammerspoon to bind f18 to a new modal key, which we configure with a number of combinations below.
hyper = hs.hotkey.modal.new()
f18 = hs.hotkey.bind({}, 'f18', function () hyper:enter() end, function () hyper:exit() end)

hyper:bind({}, 'f', function ()
    move(function (f, sf) return sf.x, sf.y, sf.w, sf.h end)
end)

hyper:bind({}, 'c', function ()
    move(function (f, sf)
        local x = sf.x + ((sf.w - f.w) / 2)
        local y = sf.y + ((sf.h - f.h) / 2)
        return x, y, f.w, f.h
    end)
end)

hyper:bind({}, 'left', function ()
    move(function (f, sf) return sf.x, sf.y, sf.w/2, sf.h end)
end)
-- hyper:bind({}, 'left', function () hs.grid.set(hs.window.focusedWindow(), {0, 0, 2, 6}) end)

hyper:bind({}, 'right', function ()
    move(function (f, sf) return (sf.x2 - sf.w/2), sf.y, sf.w/2, sf.h end)
end)
-- hyper:bind({}, 'right', function () hs.grid.set(hs.window.focusedWindow(), {2, 0, 2, 6}) end)

hyper:bind({}, 'up', function ()
    move(function (f, sf) return f.x, sf.y, f.w, sf.h/2 end)
end)

hyper:bind({}, 'down', function ()
    move(function (f, sf) return f.x, (sf.y2 - sf.h/2), f.w, sf.h/2 end)
end)

hyper:bind({}, 'r', hs.reload)
hyper:bind({}, 'e', hs.hints.windowHints)
hyper:bind({}, 't', function ()
    os.execute('/usr/bin/open -a Terminal ~')
end)
hyper:bind({}, 'l', lockScreen)

hyper:bind({}, 'g', function ()
    local ok, result = hs.osascript.applescript('tell application "Google Chrome" to make new window')
    if not ok then
        hs.alert.show('Error launching new Chrome window: '..result)
        return
    end
    local firstNewWindow = hs.window.filter.new(false):setAppFilter('Google Chrome', {
        currentSpace = true,
        visible = true,
        allowTitles = 'New Tab'
    }):getWindows()[1]
    if firstNewWindow then
        firstNewWindow:focus()
    end
end)

hs.hotkey.bind({}, 'f19', lockScreen)

-- I switched to https://github.com/briankendall/forceFullDesktopBar, it works better in Mojave, I longer need this.
-- -- if missionControlFullDesktopBar installed, intercept Mission Control (F3) keypresses and launch it instead
-- -- See https://github.com/briankendall/missionControlFullDesktopBar
-- local MCFDB_PATH = '/Applications/missionControlFullDesktopBar.app/Contents/MacOS/missionControlFullDesktopBar'
-- local mcfdbSize = hs.fs.attributes(MCFDB_PATH, 'size')
-- if mcfdbSize then
--     local log = hs.logger.new('missionControlFullDesktopBar', 'debug')
--     log.i('missionControlFullDesktopBar found, intercepting Mission Control key events')
--     function handleMissionControl(e)
--         local code = e:getProperty(hs.eventtap.event.properties.keyboardEventKeycode)
--         if code == MISSION_CONTROL_KEYCODE then
--             -- ignore auto-repeats
--             local isAutoRepeat = e:getProperty(hs.eventtap.event.properties.keyboardEventAutorepeat)
--             if isAutoRepeat == 1 then
--                 return true -- discard
--             end
--             -- don't intercept cmd+f3 or ctrl+f3
--             local flags = e:getFlags()
--             if (flags.cmd or flags.ctrl) then
--                 return false -- propogate
--             end
--             local type = e:getType()
--             if type == hs.eventtap.event.types.keyDown then
--                 --log.i('intercepted Mission Control DOWN')
--                 os.execute(MCFDB_PATH..' -d -i')
--                 return true -- discard
--             elseif type == hs.eventtap.event.types.keyUp then
--                 --log.i('intercepted Mission Control UP')
--                 os.execute(MCFDB_PATH..' -d -r')
--                 return true -- discard
--             end
--         end
--         return false -- propogate
--     end
--     trapMissionControl = hs.eventtap.new({hs.eventtap.event.types.keyDown, hs.eventtap.event.types.keyUp}, handleMissionControl)
--     trapMissionControl:start()
-- end

-- Set up my Logitech G600's ring finger button to F17.
-- Then here, remap F17 to the Mission Control button.
-- Note: assigned to global variable so it doesn't get garbage collected and mysteriously stop working :-(
myG600RingFingerButtonEventTap = hs.eventtap.new({hs.eventtap.event.types.keyDown, hs.eventtap.event.types.keyUp}, function (e)
    local code = e:getProperty(hs.eventtap.event.properties.keyboardEventKeycode)
    -- logger.i('caught keycode: ' .. code)
    if code == F17_KEYCODE then
        return true, { hs.eventtap.event.newKeyEvent(MISSION_CONTROL_KEYCODE, e:getType() == hs.eventtap.event.types.keyDown) }
    end
end)
myG600RingFingerButtonEventTap:start()

-- Mouse Button4/Button5 to Back/Forward in Chrome.
-- thanks to: https://tom-henderson.github.io/2018/12/14/hammerspoon.html
-- Note: assigned to global variable so it doesn't get garbage collected and mysteriously stop working :-(
myButton4Button5EventTap = hs.eventtap.new({hs.eventtap.event.types.otherMouseDown}, function (event)
    local button = event:getProperty(hs.eventtap.event.properties.mouseEventButtonNumber)
    local frontmostAppName = hs.application.frontmostApplication():name()
    -- logger.i('otherMouseDown event, button: ' .. button .. ', frontmostApp: ' .. frontmostAppName)
    if frontmostAppName == 'Google Chrome' then
        if button == 3 then
            hs.eventtap.keyStroke({'cmd'}, '[')
            return true
        elseif button == 4 then
            hs.eventtap.keyStroke({'cmd'}, ']')
            return true
        end
    elseif frontmostAppName == 'Slack' then
        if button == 3 then
            hs.eventtap.keyStroke({'cmd'}, 'left')
            return true
        elseif button == 4 then
            hs.eventtap.keyStroke({'cmd'}, 'right')
            return true
        end
    end
end)
myButton4Button5EventTap:start()

-- Grid
hs.grid.setGrid('4x6')
hs.grid.setMargins({0, 0})
hyper:bind({}, 'tab', function () hs.grid.show() end)
hyper:bind({}, 'pad7', function () hs.grid.set(hs.window.focusedWindow(), {0, 0, 2, 2}) end)
hyper:bind({}, 'pad4', function () hs.grid.set(hs.window.focusedWindow(), {0, 2, 2, 2}) end)
hyper:bind({}, 'pad1', function () hs.grid.set(hs.window.focusedWindow(), {0, 4, 2, 2}) end)
hyper:bind({}, 'pad9', function () hs.grid.set(hs.window.focusedWindow(), {2, 0, 2, 2}) end)
hyper:bind({}, 'pad6', function () hs.grid.set(hs.window.focusedWindow(), {2, 2, 2, 2}) end)
hyper:bind({}, 'pad3', function () hs.grid.set(hs.window.focusedWindow(), {2, 4, 2, 2}) end)

hs.notify.new({title='Hammerspoon', informativeText='Config loaded'}):send()
