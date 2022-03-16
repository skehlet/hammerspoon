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

function hammer:entered()
    -- logger.i("Hammer down")
    self.isDown = true
end

function hammer:exited()
    -- logger.i("Hammer up")
    self.isDown = false
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
f14 = hs.hotkey.bind({}, 'f14', function () hammer:enter() end, function () hammer:exit() end)

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
            hammer:enter()
            return true
        else
            hammer:exit()
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

function moveLeft()
    move(function (f, sf) return sf.x, sf.y, sf.w/2, sf.h end)
end

function moveLeftBig()
    move(function (f, sf) return sf.x, sf.y, .7*sf.w, sf.h end)
end

function moveLeftSmall()
    move(function (f, sf) return sf.x, sf.y, .3*sf.w, sf.h end)
end

function moveWest()
    local win = hs.window.focusedWindow()
    if win then
        win:moveOneScreenWest()
    end
end

function moveRight()
    move(function (f, sf) return (sf.x2 - sf.w/2), sf.y, sf.w/2, sf.h end)
end

function moveRightBig()
    move(function (f, sf) return (sf.x2 - .7*sf.w), sf.y, .7*sf.w, sf.h end)
end

function moveRightSmall()
    move(function (f, sf) return (sf.x2 - .3*sf.w), sf.y, .3*sf.w, sf.h end)
end

function moveEast()
    local win = hs.window.focusedWindow()
    if win then
        win:moveOneScreenEast()
    end
end

hammer:bind({},         'left',  moveLeft)
hammer:bind({'shift'},  'left',  moveLeftBig)
hammer:bind({'option'}, 'left',  moveLeftSmall)
hammer:bind({'cmd'},    'left',  moveWest)
hammer:bind({},         'right', moveRight)
hammer:bind({'shift'},  'right', moveRightBig)
hammer:bind({'option'}, 'right', moveRightSmall)
hammer:bind({'cmd'},    'right', moveEast)

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
        -- go to great lengths to make sure the new window appears on the current screen
        local currentScreen = hs.screen.mainScreen()
        local preExistingChromeWindowIds = {}
        for _,win in ipairs(chrome:visibleWindows()) do
            preExistingChromeWindowIds[win:id()] = true
        end

        chrome:selectMenuItem({"File", "New Window"})

        for i,win in ipairs(chrome:visibleWindows()) do
            -- if it's a new window, and it's on the wrong screen...
            if not preExistingChromeWindowIds[win:id()] and win:screen() ~= currentScreen then
                win:moveToScreen(currentScreen)
                print("Moving New Chrome window (" .. win:title() .. ") to current screen")
            end
        end

        chrome:activate()
    end
end)

-- hammer:bind({'shift'}, 'f', function ()
--     logger.i("Frontmost application: " .. hs.application.frontmostApplication():name())
--     local chrome = hs.application.find("Google Chrome")
--     if chrome then
--         chrome:setFrontmost()
--     end
-- end)



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
-- hs.hotkey.bind({}, 'f19', lockScreen) -- Remove, no longer using a (Mac) keyboard with F19

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


-- if missionControlFullDesktopBar installed, intercept Mission Control (F3) keypresses and launch it instead
-- See https://github.com/briankendall/missionControlFullDesktopBar
local MISSION_CONTROL_KEYCODE = 0xa0
local MCFDB_PATH = '/Applications/missionControlFullDesktopBar.app/Contents/MacOS/missionControlFullDesktopBar'
local mcfdbSize = hs.fs.attributes(MCFDB_PATH, 'size')
if mcfdbSize then
    logger.i('missionControlFullDesktopBar found, intercepting Mission Control key events')
    -- trapMissionControl must be a global variable so Lua doesn't garbage collect it
    trapMissionControl = hs.eventtap.new({
        hs.eventtap.event.types.keyDown,
        hs.eventtap.event.types.keyUp
    }, function (event)
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
                os.execute(MCFDB_PATH..' -d -i')
                return true -- discard
            else
                -- logger.i('intercepted Mission Control UP')
                os.execute(MCFDB_PATH..' -d -r')
                return true -- discard
            end
        end
        return false -- propogate
    end)
    trapMissionControl:start()
end

-- Mouse Button4/Button5 to Back/Forward in Chrome and Slack.
-- thanks to: https://tom-henderson.github.io/2018/12/14/hammerspoon.html
-- Note: assigned to global variable so it doesn't get garbage collected and mysteriously stop working :-(
myButton4Button5EventTap = hs.eventtap.new({
    hs.eventtap.event.types.otherMouseDown
}, function (event)
    local button = event:getProperty(hs.eventtap.event.properties.mouseEventButtonNumber)

    -- Make Hammer+mouse4/mouse5 behave like hammer+left/hammer+right.
    -- This fells hacky to duplicate the logic like this... would be nice to abstract this somehow,
    -- and do the same thing whether via a hammer binding or here via mouse4/mouse5.
    if hammer.isDown then
        local flags = event:getFlags()
        if button == 3 then
            if flags.shift then
                moveLeftBig()
            elseif flags.alt then
                moveLeftSmall()
            elseif flags.cmd then
                moveWest()
            else
                moveLeft()
            end
        elseif button == 4 then
            if flags.shift then
                moveRightBig()
            elseif flags.alt then
                moveRightSmall()
            elseif flags.cmd then
                moveEast()
            else
                moveRight()
            end
        end
        return true -- discard
    end

    local app = hs.application.frontmostApplication()
    -- logger.i('otherMouseDown event, button: ' .. button .. ', frontmostApp: ' .. app)
    if app:name() == 'Google Chrome' then
        if button == 3 then
            app:selectMenuItem({"History", "Back"})
            return true
        elseif button == 4 then
            app:selectMenuItem({"History", "Forward"})
            return true -- discard
        end
    elseif app:name() == 'Slack' then
        -- Strangely, Hammerspoon can't see to get or otherwise work with the menu items.
        -- So another way is to fake typing the keyboard shortcuts.
        if button == 3 then
            hs.eventtap.keyStroke({'cmd'}, 'left')
            return true -- discard
        elseif button == 4 then
            hs.eventtap.keyStroke({'cmd'}, 'right')
            return true -- discard
        end
    elseif app:name() == 'Visual Studio' then
        if button == 3 then
            app:selectMenuItem({"Search", "Navigation History", "Navigate Back"})
            return true -- discard
        elseif button == 4 then
            app:selectMenuItem({"Search", "Navigation History", "Navigate Forward"})
            return true -- discard
        end
    end
end)
myButton4Button5EventTap:start()


-- Switch monitors
-- This is a workaround to deal with macOS getting confused on which of my external monitors is left and right.
-- Hit the key binding and it will swap them.
-- Note I tried built-in Hammerspoon APIs, a C program, and a Python script, but 
-- found just calling out to `displayplacer` to be the simplest/most effective and it's a
-- maintained solution.
-- See https://github.com/Hammerspoon/hammerspoon/issues/1462#issuecomment-568534028

-- Unneeded, but keeping, where else am I going to store this:
-- local VIRTUALLY_LEFT_MONITOR_UUID = "4CE08EDE-BF77-49A0-8F23-6453DBAF6DCD"
-- local VIRTUALLY_RIGHT_MONITOR_UUID = "DEBC10C3-DF73-4222-B5D1-3027F6954EBC"
-- local PHYSICALLY_LEFT_MONITOR_SERIAL = "M5LMQS070425"
-- local PHYSICALLY_RIGHT_MONITOR_SERIAL = "M5LMQS064778"

local EXT_MONITOR_NAME_PATTERN = 'VG27A'
local DISPLAYPLACER_PATH = '/opt/homebrew/bin/displayplacer'

function screenLayoutWatcher()
    local d1, d2 = hs.screen.find(EXT_MONITOR_NAME_PATTERN)
    local currentPrimary = hs.screen.primaryScreen()
    local newPrimary
    if d1 == currentPrimary then
        newPrimary = d2
    else
        newPrimary = d1
    end

    local cmd = string.format(
        '%s "id:%s origin:(%d,%d)" "id:%s origin:(%d,%d)"',
        DISPLAYPLACER_PATH,
        newPrimary:getUUID(), 0, 0,
        currentPrimary:getUUID(), newPrimary:fullFrame().w, 0
    )

    print(cmd)
    print(hs.execute(cmd))
end

-- A screen watcher might be nice but for now just handling manually.
--   screenWatcher = hs.screen.watcher.new(screenLayoutWatcher)
--   screenWatcher:start()
--   screenLayoutWatcher()

hammer:bind({'shift'}, 's', function ()
    logger.i("Swapping monitors")
    -- os.execute(hs.fs.currentDir() .. '/swap-monitors.py')
    screenLayoutWatcher()
end)


-- Caffeine from https://github.com/kbd/setup/blob/master/HOME/.hammerspoon/init.lua#L150
caffeine = hs.menubar.new()
function showCaffeine(awake)
    local title = awake and '☕' or '🍵'
    caffeine:setTitle(title)
end

function toggleCaffeine()
    showCaffeine(hs.caffeinate.toggle("displayIdle"))
end

if caffeine then
    caffeine:setClickCallback(toggleCaffeine)
    showCaffeine(hs.caffeinate.get("displayIdle"))
end

-- On my laptops, add a menubar item to confirm my headset's mic is the current input.
if
    hs.host.localizedName() == "NXGN31966"
    or hs.host.localizedName() == "Steve's MacBook Air"
    or hs.host.localizedName() == "Steve’s MacBook Pro"
then
    -- MIC_PREFERED_DEVICE = "External Microphone"
    MIC_PREFERED_DEVICE = "Steven’s AirPods Pro" -- note the funny non-ascii single quote
    micMenuItem = hs.menubar.new()

    function setInputToExternalMic()
        local externalMic = hs.audiodevice.findDeviceByName(MIC_PREFERED_DEVICE)
        if externalMic then
            externalMic:setDefaultInputDevice()
        else
            logger.w("Could not find " .. MIC_PREFERED_DEVICE .. ", cannot make it the default input")
            micMenuItem:setTitle('🎤⛔️')
        end
    end

    function updateAudioInputIcon()
        local audioDefaultInput = hs.audiodevice.defaultInputDevice()
        logger.i("MIC_PREFERED_DEVICE: " .. MIC_PREFERED_DEVICE .. ", actual device: " .. audioDefaultInput:name())
        if audioDefaultInput:name() == MIC_PREFERED_DEVICE then
            micMenuItem:setTitle('🎤👍')
        else
            micMenuItem:setTitle('🎤⚠️')
        end
        micMenuItem:setTooltip("Default input device is: " .. audioDefaultInput:name())
    end

    if micMenuItem then
        hs.audiodevice.watcher.setCallback(function (event)
            -- the space in "dIn " is intentional, see
            -- [docs](https://www.hammerspoon.org/docs/hs.audiodevice.watcher.html#setCallback)
            if event == "dIn " then
                updateAudioInputIcon()
            end
        end)
        hs.audiodevice.watcher.start()
        updateAudioInputIcon()
        micMenuItem:setClickCallback(setInputToExternalMic)
    end
end

hs.notify.new({title='Hammerspoon', informativeText='Config loaded'}):send()
