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
    -- os.execute('pmset displaysleepnow')
    -- As of Hammerspoon 0.9.76, this isn't bad, it shows the lock screen, which blanks after a few seconds:
    hs.caffeinate.lockScreen()
end

local function systemSleep()
    hs.caffeinate.systemSleep()
end

local function goldenRatioA(n)
    return math.floor(.62 * n)
end

local function goldenRatioB(n)
    return math.floor(.38 * n)
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
hyper:bind({'shift'}, 'left', function ()
    move(function (f, sf) return sf.x, sf.y, goldenRatioA(sf.w), sf.h end)
end)
hyper:bind({'option'}, 'left', function ()
    move(function (f, sf) return sf.x, sf.y, goldenRatioB(sf.w), sf.h end)
end)

hyper:bind({}, 'right', function ()
    move(function (f, sf) return (sf.x2 - sf.w/2), sf.y, sf.w/2, sf.h end)
end)
hyper:bind({'shift'}, 'right', function ()
    move(function (f, sf) return (sf.x2 - goldenRatioA(sf.w)), sf.y, goldenRatioA(sf.w), sf.h end)
end)
hyper:bind({'option'}, 'right', function ()
    move(function (f, sf) return (sf.x2 - goldenRatioB(sf.w)), sf.y, goldenRatioB(sf.w), sf.h end)
end)
-- hyper:bind({}, 'right', function () hs.grid.set(hs.window.focusedWindow(), {2, 0, 2, 6}) end)

hyper:bind({}, 'up', function ()
    move(function (f, sf) return f.x, sf.y, f.w, sf.h/2 end)
end)

hyper:bind({}, 'down', function ()
    move(function (f, sf) return f.x, (sf.y2 - sf.h/2), f.w, sf.h/2 end)
end)

hyper:bind({}, 'r', hs.reload)
-- turn this off, I don't use it, plus it's super slow on Catalina:
-- hyper:bind({}, 'e', hs.hints.windowHints)
hyper:bind({}, 't', function ()
    os.execute('/usr/bin/open -a Terminal ~')
end)
hyper:bind({}, 'l', lockScreen)
hyper:bind({'shift'}, 'l', systemSleep)

-- click menu item "New Tab" of menu "Window" of menu bar 1
-- click (first menu item whose name contains "New Tab") of menu "Window" of menu bar 1
hyper:bind({}, 'g', function ()
    local ok, object, descriptor = hs.osascript._osascript([[
        tell application "System Events"
            tell process "Google Chrome"
                click menu item "New Window" of menu "File" of menu bar 1
            end tell
        end tell
    ]], "AppleScript")
    if not ok then
        hs.alert.show('Error launching new Chrome window: '..descriptor)
        return
    end
    -- Commented out, super slow on Catalina, and the above, simple File -> New Window technique appears to work
    -- local firstNewWindow = hs.window.filter.new(false):setAppFilter('Google Chrome', {
    --     currentSpace = true,
    --     visible = true,
    --     allowTitles = 'New Tab'
    -- }):getWindows()[1]
    -- if firstNewWindow then
    --     logger.i('Found the new Chrome window and told it to focus')
    --     firstNewWindow:focus()
    -- else
    --     logger.i('Could not found the new Chrome window')
    -- end
end)

hs.hotkey.bind({}, 'f19', lockScreen)

-- https://github.com/Hammerspoon/hammerspoon/issues/1220#issuecomment-276941617
ejectKey = hs.eventtap.new({ hs.eventtap.event.types.NSSystemDefined, hs.eventtap.event.types.keyDown }, function(event)
    -- http://www.hammerspoon.org/docs/hs.eventtap.event.html#systemKey
    event = event:systemKey()
    -- http://stackoverflow.com/a/1252776/1521064
    local next = next
    -- Check empty table
    if next(event) then
        if event.key == 'EJECT' and event.down then
            -- logger.i('caught EJECT DOWN: ' .. event.key)
            lockScreen()
        end
    end
end)
ejectKey:start()

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

-- Mouse Button4/Button5 to Back/Forward in Chrome and Slack.
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
