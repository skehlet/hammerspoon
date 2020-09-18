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

-- "stretch" the window vertically
hyper:bind({}, 's', function ()
    move(function (f, sf) return f.x, sf.y, f.w, sf.h end)
end)

hyper:bind({}, 'left', function ()
    move(function (f, sf) return sf.x, sf.y, sf.w/2, sf.h end)
end)
hyper:bind({'shift'}, 'left', function ()
    move(function (f, sf) return sf.x, sf.y, .7*sf.w, sf.h end)
end)
hyper:bind({'option'}, 'left', function ()
    move(function (f, sf) return sf.x, sf.y, .3*sf.w, sf.h end)
end)

hyper:bind({}, 'right', function ()
    move(function (f, sf) return (sf.x2 - sf.w/2), sf.y, sf.w/2, sf.h end)
end)
hyper:bind({'shift'}, 'right', function ()
    move(function (f, sf) return (sf.x2 - .7*sf.w), sf.y, .7*sf.w, sf.h end)
end)
hyper:bind({'option'}, 'right', function ()
    move(function (f, sf) return (sf.x2 - .3*sf.w), sf.y, .3*sf.w, sf.h end)
end)

hyper:bind({}, 'up', function ()
    move(function (f, sf) return f.x, sf.y, f.w, sf.h/2 end)
end)

hyper:bind({}, 'down', function ()
    move(function (f, sf) return f.x, (sf.y2 - sf.h/2), f.w, sf.h/2 end)
end)

hyper:bind({}, 't', function ()
    os.execute('/usr/bin/open -a Terminal ~')
end)

hyper:bind({}, 'g', function ()
    local chrome = hs.application.find("Google Chrome")
    if chrome then
        chrome:selectMenuItem({"File", "New Window"})
        chrome:activate()
    end
end)

-- Lock screen: map various keys
local function lockScreen()
    -- built-in screensaver:
    -- hs.caffeinate.startScreensaver()
    -- this one just blanks the screen, no photos/etc
    --os.execute('/usr/local/bin/lockscreen')
    -- To lock screen, the following requires you have "Require password immediately after sleep or screen saver begins" 
    -- set under System Preferences, Security & Privacy, General.
    -- os.execute('pmset displaysleepnow')
    -- As of Hammerspoon 0.9.76, this technique is great: it shows the lock screen, which blanks after a few seconds.
    -- However the docs warn:
    -- "This function uses private Apple APIs and could therefore stop working in any given release of macOS without warning"
    hs.caffeinate.lockScreen()
end

local function systemSleep()
    hs.caffeinate.systemSleep()
end

hyper:bind({}, 'l', lockScreen)
hyper:bind({'shift'}, 'l', systemSleep)
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

hs.notify.new({title='Hammerspoon', informativeText='Config loaded'}):send()
