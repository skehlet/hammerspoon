local logger = hs.logger.new('init.lua', 'debug')
local util = require('util')

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

-- sanity checks
logger.i('Is Hammerspoon enabled under Privacy/Accessibility: ' .. (hs.accessibilityState() and "true" or "false"))
logger.i('hs.eventtap.isSecureInputEnabled(): ' .. (hs.eventtap.isSecureInputEnabled() and "true" or "false"))

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
hammer = hs.hotkey.modal.new()

local function hammerDown()
    logger.i("Hammer down")
    hammer:enter()
end

local function hammerUp()
    logger.i("Hammer up")
    hammer:exit()
end

-- If the weird Caps lock issue happens again
-- Try F14 ("Scroll Lock" on my PC keyboard) as an alternate hammer key
-- Try hidutil to see if it changes the behavior (https://stackoverflow.com/a/46460200/296829):
-- hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x70000006D}]}'
-- To clear:
-- hidutil property --set '{"UserKeyMapping":[]}'
-- See https://www.naseer.dev/post/hidutil/ to make it set on reboot
-- Update: it happened again. F14/Scroll Lock+g did NOT work (typed a 'g' into my window)
--     I ran the hidutil command, and that didn't help. I ran the clear command.
--     Some time later, unexplainably, Caps Lock started working again.
-- 2021-06-30: this time, it was busted until I added logging to the F18 down and up functions. That reloaded hammerspoon,
-- and then it started working again. I KNOW I restarted hammerspoon earlier and that did NOT help though. So not sure
-- why this helped.
-- Update 2021-08-20:
-- I've found that locking the screen then unlocking clears the problem.
-- I found using Karabiner-Elements EventViewer that it stops seeing CapsLock events.
-- Once I lock screen and return, it then begins showing {"key_code":"f18"} down/up events.
-- So this implies it's something either with Karabiner-Elements or upstream of it.
-- But then why doesn't F14/Scroll Lock work?? Try that next time.
-- 2021-08-25: Today, Caps Lock stopped working, but only in Chrome.
-- Karabiner EventViewer saw Caps Lock, and Caps+f worked in all apps but Chrome.
-- Restarting Hammerspoon fixed it.
--
-- 2022-02-03: This is the issue: https://github.com/Hammerspoon/hammerspoon/issues/1743
-- Occasionally some process on macOS will put the system into a state where "secure input" is enabled and this prevents
-- hs.eventtap (or hs.hostkey.bind) from working.
-- You can prove this is the case with: ioreg -l -w 0 | grep SecureInput
-- Then find the PID with: ps axo pid,command | grep <PID>
-- For me, today it was Google Chrome. The WD MyCloud UI had auto-logged me out and was sitting at a password prompt.
-- Once I entered a password, then it released the secure input hold, and my hammer key started working again.
-- Now that I have a better idea what the problem is, there are lots of hits googling for "secure input" and
-- tools like TextExpander, Keyboard Maestro, Alfred, etc.
-- [This reddit posts](https://www.reddit.com/r/TextExpander/comments/440yal/little_tip_if_you_use_lastpass_textexpander/)
-- suggests just clicking on the LastPass icon in Chrome, and that might clear it up.
-- I tried turning off LastPass' auto-fill feature, maybe this will stop it from triggering.
-- Chrome -> LastPass -> Account Options -> Extension Preferences, uncheck Automatically fill login information

-- f18 = hs.hotkey.bind({}, 'f18', hammerDown, hammerUp)
f14 = hs.hotkey.bind({}, 'f14', hammerDown, hammerUp)

-- 2022-01-27 "Better" way to capture f18, this way it'll trigger whether or not
-- you already had shift, alt, cmd, etc held down. With hd.hotkey.bind, I'd have
-- to create bindings for all the combinations of modifier keys.
f18 = hs.eventtap.new({
    -- hs.eventtap.event.types:
    -- https://github.com/Hammerspoon/hammerspoon/blob/master/extensions/eventtap/libeventtap_event.m#L1305
    hs.eventtap.event.types.keyDown,
    hs.eventtap.event.types.keyUp
}, function(event)
    -- logger.i('caught key: ' .. event:getKeyCode() .. ' of type: ' .. event:getType())
    if event:getKeyCode() == hs.keycodes.map['f18'] then
        local isRepeat = event:getProperty(hs.eventtap.event.properties.keyboardEventAutorepeat)
        if isRepeat > 0 then
            return true -- ignore and discard
        end
        if event:getType() == hs.eventtap.event.types.keyDown then
            hammerDown()
            return true
        else
            hammerUp()
            return true
        end
    end
end)
f18:start()

hammer:bind({}, 'f', function ()
    move(function (f, sf) return sf.x, sf.y, sf.w, sf.h end)
end)

hammer:bind({}, 'c', function ()
    move(function (f, sf)
        local x = sf.x + ((sf.w - f.w) / 2)
        local y = sf.y + ((sf.h - f.h) / 2)
        return x, y, f.w, f.h
    end)
end)

-- "stretch" the window vertically
hammer:bind({}, 's', function ()
    move(function (f, sf) return f.x, sf.y, f.w, sf.h end)
end)

hammer:bind({}, 'left', function ()
    move(function (f, sf) return sf.x, sf.y, sf.w/2, sf.h end)
end)
hammer:bind({'shift'}, 'left', function ()
    move(function (f, sf) return sf.x, sf.y, .7*sf.w, sf.h end)
end)
hammer:bind({'option'}, 'left', function ()
    move(function (f, sf) return sf.x, sf.y, .3*sf.w, sf.h end)
end)
hammer:bind({'cmd'}, 'left', function ()
    local win = hs.window.focusedWindow()
    if win then
        win:moveOneScreenWest()
    end
end)

hammer:bind({}, 'right', function ()
    move(function (f, sf) return (sf.x2 - sf.w/2), sf.y, sf.w/2, sf.h end)
end)
hammer:bind({'shift'}, 'right', function ()
    move(function (f, sf) return (sf.x2 - .7*sf.w), sf.y, .7*sf.w, sf.h end)
end)
hammer:bind({'option'}, 'right', function ()
    move(function (f, sf) return (sf.x2 - .3*sf.w), sf.y, .3*sf.w, sf.h end)
end)
hammer:bind({'cmd'}, 'right', function ()
    local win = hs.window.focusedWindow()
    if win then
        win:moveOneScreenEast()
    end
end)

hammer:bind({}, 'up', function ()
    move(function (f, sf) return f.x, sf.y, f.w, sf.h/2 end)
end)

hammer:bind({}, 'down', function ()
    move(function (f, sf) return f.x, (sf.y2 - sf.h/2), f.w, sf.h/2 end)
end)

hammer:bind({}, 't', function ()
    os.execute('/usr/bin/open -a Terminal ~')
end)

hammer:bind({}, 'g', function ()
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

hammer:bind({}, 'l', lockScreen)
hammer:bind({'shift'}, 'l', systemSleep)
hs.hotkey.bind({}, 'f15', lockScreen) -- Pause on my PC keyboard is F15 on macOS
hs.hotkey.bind({}, 'f19', lockScreen)

-- comment this out for now, I don't have a keyboard with eject anymore
-- -- https://github.com/Hammerspoon/hammerspoon/issues/1220#issuecomment-276941617
-- ejectKey = hs.eventtap.new({
--     hs.eventtap.event.types.NSSystemDefined
-- }, function(event)
--     -- http://www.hammerspoon.org/docs/hs.eventtap.event.html#systemKey
--     event = event:systemKey()
--     -- http://stackoverflow.com/a/1252776/1521064
--     local next = next
--     -- Check empty table
--     if next(event) then
--         if event.key == 'EJECT' and event.down then
--             -- logger.i('caught EJECT DOWN: ' .. event.key)
--             lockScreen()
--         end
--     end
-- end)
-- ejectKey:start()

-- Mouse Button4/Button5 to Back/Forward in Chrome and Slack.
-- thanks to: https://tom-henderson.github.io/2018/12/14/hammerspoon.html
-- Note: assigned to global variable so it doesn't get garbage collected and mysteriously stop working :-(
myButton4Button5EventTap = hs.eventtap.new({hs.eventtap.event.types.otherMouseDown}, function (event)
    local button = event:getProperty(hs.eventtap.event.properties.mouseEventButtonNumber)
    local app = hs.application.frontmostApplication()
    -- logger.i('otherMouseDown event, button: ' .. button .. ', frontmostApp: ' .. app)
    if app:name() == 'Google Chrome' then
        if button == 3 then
            app:selectMenuItem({"History", "Back"})
            return true
        elseif button == 4 then
            app:selectMenuItem({"History", "Forward"})
            return true
        end
    elseif app:name() == 'Slack' then
        -- Strangely, Hammerspoon can't see to get or otherwise work with the menu items.
        -- So another way is to fake typing the keyboard shortcuts.
        if button == 3 then
            hs.eventtap.keyStroke({'cmd'}, 'left')
            return true
        elseif button == 4 then
            hs.eventtap.keyStroke({'cmd'}, 'right')
            return true
        end
    elseif app:name() == 'Visual Studio' then
        if button == 3 then
            app:selectMenuItem({"Search", "Navigation History", "Navigate Back"})
            return true
        elseif button == 4 then
            app:selectMenuItem({"Search", "Navigation History", "Navigate Forward"})
            return true
        end
    end
end)
myButton4Button5EventTap:start()

hs.notify.new({title='Hammerspoon', informativeText='Config loaded'}):send()

function dumpTable(table, depth)
    if (depth > 200) then
        print("Error: Depth > 200 in dumpTable()")
        return
    end
    for k,v in pairs(table) do
        if (type(v) == "table") then
            logger.i(string.rep("  ", depth)..k..":")
            dumpTable(v, depth+1)
        else
            logger.i(string.rep("  ", depth)..k..": ",v)
        end
    end
end
