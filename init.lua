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
if not hs.accessibilityState() then
    hs.alert("😱 WARNING! Privacy/Accessibility is NOT enabled for Hammerspoon. You need to turn it on.")
end
logger.i('hs.eventtap.isSecureInputEnabled(): ' .. (hs.eventtap.isSecureInputEnabled() and "true" or "false"))
if hs.eventtap.isSecureInputEnabled() then
    hs.alert([[
😱 WARNING! macOS Secure Input mode is currently activated!
Hammerspoon can't read keystrokes while this is on!
Figure out what's got it turned on and stop it.
ioreg -l -w 0 | grep SecureInput | ggrep -Po 'kCGSSessionSecureInputPID"=\d+']], 6)
end

--[[
Find the offending PID (kCGSSessionSecureInputPID) with:

    ioreg -l -w 0 | grep SecureInput | ggrep -Po 'kCGSSessionSecureInputPID"=\d+'

Careful, don't kill loginwindow.
Next time try locking screen (Menu Bar: Apple -> Lock Screen), then unlocking.
]]--

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

-- Convenience method to create and start an eventTap then store it in a global variable so it doesn't get garbage collected
myEventTaps = {} -- global
function createEventTap(types, handler)
    table.insert(myEventTaps, hs.eventtap.new(types, handler):start())
end

-- The Hammer key
-- Install com.stevekehlet.RemapCapsLockToF18.plist (see the README) to map Caps Lock to F18.
hammer = hs.hotkey.modal.new()

function hammer:entered()
    logger.i("Hammer down")
    self.isDown = true
end

onNextHammerUpCallbacks = {}
function onNextHammerUp(fn)
    table.insert(onNextHammerUpCallbacks, fn)
end

function hammer:exited()
    logger.i("Hammer up")
    self.isDown = false
    while #onNextHammerUpCallbacks > 0 do
        fn = table.remove(onNextHammerUpCallbacks, 1)
        fn()
    end
end

-- Capture presses and releases of F18 to activate the hammer
createEventTap({
    hs.eventtap.event.types.keyDown,
    hs.eventtap.event.types.keyUp
}, function(event)
    --logger.i('caught key: ' .. event:getKeyCode() .. ' of type: ' .. event:getType())
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

-- Window movement functions
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

function makeFullScreen()
    move(function (f, sf) return sf.x, sf.y, sf.w, sf.h end)
end

function makeHalfScreen()
    move(function (f, sf) return f.x, f.y, sf.w/2, sf.h end)
end

function makeHalfScreenCentered()
    move(function (f, sf)
        local w = sf.w / 2
        local h = sf.h
        local x = sf.x + ((sf.w - w) / 2)
        local y = sf.y + ((sf.h - h) / 2)
        return x, y, w, h
    end)
end

function moveToCenter()
    move(function (f, sf)
        local x = sf.x + ((sf.w - f.w) / 2)
        local y = sf.y + ((sf.h - f.h) / 2)
        return x, y, f.w, f.h
    end)
end

function stretchVertically()
    move(function (f, sf) return f.x, sf.y, f.w, sf.h end)
end

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

function moveUp()
    move(function (f, sf) return f.x, sf.y, f.w, sf.h/2 end)
end

function moveDown()
    move(function (f, sf) return f.x, (sf.y2 - sf.h/2), f.w, sf.h/2 end)
end

hammer:bind({},         'f',     makeFullScreen)
hammer:bind({},         'c',     moveToCenter)
hammer:bind({},         's',     stretchVertically)
hammer:bind({},         'left',  moveLeft)
hammer:bind({'shift'},  'left',  moveLeftBig)
hammer:bind({'option'}, 'left',  moveLeftSmall)
hammer:bind({'cmd'},    'left',  moveWest)
hammer:bind({},         'right', moveRight)
hammer:bind({'shift'},  'right', moveRightBig)
hammer:bind({'option'}, 'right', moveRightSmall)
hammer:bind({'cmd'},    'right', moveEast)
hammer:bind({},         'up',    moveUp)
hammer:bind({},         'down',  moveDown)

-- Application quick launch keys

hammer:bind({}, 't', function ()
    os.execute('/usr/bin/open -a Terminal ~')
end)

function openNewCenteredHalfWidthWindowOnCurrentScreen(applicationName, openNewWindowFn)
    local app = hs.application.find(applicationName)
    if app then
        -- go to great lengths to make sure the new window appears on the current screen
        local currentScreen = hs.screen.mainScreen()
        local preExistingAppWindowIds = {}
        for _, win in ipairs(app:visibleWindows()) do
            preExistingAppWindowIds[win:id()] = true
        end

        openNewWindowFn(app)

        for i, win in ipairs(app:visibleWindows()) do
            if not preExistingAppWindowIds[win:id()] then
                -- if it's a new window, and it's on the wrong screen...
                if win:screen() ~= currentScreen then
                    -- logger.i("Moving New " .. applicationName .. " window (" .. win:title() .. ") to current screen")
                    win:moveToScreen(currentScreen)
                end
                -- I've noticed sometimes it still gets buried under other windows, this helps:
                -- logger.i("Focusing on New " .. applicationName .. " window (" .. win:title() .. ")")
                win:focus()
                app:activate()
                makeHalfScreenCentered()
                break
            end
        end
    end
end

hammer:bind({}, 'g', function ()
    openNewCenteredHalfWidthWindowOnCurrentScreen("Google Chrome", function (app)
        app:selectMenuItem({"File", "New Window"})
    end)
end)

hammer:bind({}, 'b', function ()
    openNewCenteredHalfWidthWindowOnCurrentScreen("Brave Browser", function (app)
        -- app:selectMenuItem({"File", "New Window"})
        -- alternate, CLI-based approach: guaranteed to open a window using my Default profile (not whatever I have currently focused)
        os.execute('/Applications/Brave\\ Browser.app/Contents/MacOS/Brave\\ Browser --profile-directory="Default" --new-window')
    end)
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

hammer:bind({}, 'l', function()
    -- Wait for the release of the hammer key before activating screen lock.
    -- This solves issues I was having of the hammer key getting "stuck" since
    -- the release wouldn't be noticed once the screen was locked.
    onNextHammerUp(lockScreen)
end)
hammer:bind({'shift'}, 'l', function()
    onNextHammerUp(systemSleep)
end)
hs.hotkey.bind({}, 'f15', lockScreen) -- F15 (Pause on my PC keyboard)
-- hs.hotkey.bind({}, 'f19', lockScreen) -- Disabled, no longer using a (Mac) keyboard with F19

-- -- This one actually clicks on the "Login Window..." item on the Fast User
-- -- Switching menu bar item to switch to the login screen. This technique seems
-- -- to work better than locking the screen for restoring all spaces and their
-- -- windows to the correct monitors. Unfortunately however this requires typing
-- -- my username and password every time :-(. Note there does not seem to be any
-- -- better way to hotkey this (hence the AppleScript), there used to be a command
-- -- line utlity called CGSession but it was removed in Big Sur.
-- -- Source: https://forum.keyboardmaestro.com/t/tip-resolving-big-sur-accessibility-security-and-other-issues/20159/20
-- hammer:bind({}, 'f15', function ()
--     logger.i("Clicking Login Window...")
--     hs.applescript([[
--         tell application "System Events"
--             tell its application process "ControlCenter"
--                 tell its menu bar 1
--                     click its menu bar item "User"
--                 end tell
--                 tell its window "Control Center"
--                     set btns to its buttons
--                     repeat with btn in btns
--                         if name of btn = "Login Window..." then
--                             click btn
--                         end if
--                     end repeat
--                 end tell
--             end tell
--         end tell
--     ]])
-- end)

-- comment this out for now, I don't have a keyboard with eject anymore
-- -- https://github.com/Hammerspoon/hammerspoon/issues/1220#issuecomment-276941617
-- createEventTap({
--     hs.eventtap.event.types.systemDefined
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


-- if missionControlFullDesktopBar installed, intercept Mission Control (F3) keypresses and launch it instead
-- See https://github.com/briankendall/missionControlFullDesktopBar
local MISSION_CONTROL_KEYCODE = 0xa0
local MCFDB_PATH = '/Applications/missionControlFullDesktopBar.app/Contents/MacOS/missionControlFullDesktopBar'
local mcfdbSize = hs.fs.attributes(MCFDB_PATH, 'size')
if mcfdbSize then
    logger.i('missionControlFullDesktopBar found, intercepting Mission Control key events')
    createEventTap({
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
                if hammer.isDown then
                    logger.i('intercepted Hammer+Mission Control DOWN, finding and killing missionControlFullDesktopBar...')
                    local mcfdb = hs.application.find("missionControlFullDesktopBar")
                    if mcfdb then
                        mcfdb:kill()
                    end
                end
                -- os.execute(MCFDB_PATH..' -d -i')
                os.execute(MCFDB_PATH..' -d')
                return true -- discard
            else
                -- logger.i('intercepted Mission Control UP')
                os.execute(MCFDB_PATH..' -d -r')
                return true -- discard
            end
        end
        return false -- propogate
    end)
end

-- sometimes missionControlFullDesktopBar stops working, use this to easily restart it
hammer:bind({'shift'}, 'm', function ()
    local mcfdb = hs.application.find("missionControlFullDesktopBar")
    if mcfdb then
        mcfdb:kill()
    end
end)

-- Mouse buttons 4/5 to go Back/Forward in various apps, or move left/right if the hammer key is down
-- Thanks to: https://tom-henderson.github.io/2018/12/14/hammerspoon.html
createEventTap({
    hs.eventtap.event.types.otherMouseDown
}, function (event)
    local button = event:getProperty(hs.eventtap.event.properties.mouseEventButtonNumber)

    -- Make Hammer+mouse4/mouse5 behave like hammer+left/hammer+right.
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
    -- logger.i('otherMouseDown event, button: ' .. button .. ', frontmostApp: ' .. app:name())
    -- if app:name() == 'Google Chrome' then
    if app:name() == 'Google Chrome' or app:name() == 'Brave Browser' then
        local isRepeat = event:getProperty(hs.eventtap.event.properties.keyboardEventAutorepeat)
        if isRepeat == 1 then
            logger.i("Chrome/Brave: discarding repeat button 3/4")
            return true -- ignore and discard
        end
        if button == 3 then
            -- logger.i("Chrome/Brave: intercepted button3")
            app:selectMenuItem({"History", "Back"})
            return true
        elseif button == 4 then
            -- logger.i("Chrome/Brave: intercepted button4")
            app:selectMenuItem({"History", "Forward"})
            return true -- discard
        end
    -- 2023-09-05: Appears Slack added button3/4 support at some point, and I'm seeing double back/forward behavior, so comment it out.
    -- elseif app:name() == 'Slack' then
    --     -- Strangely, Hammerspoon can't see to get or otherwise work with the menu items.
    --     -- So another way is to fake typing the keyboard shortcuts.
    --     if button == 3 then
    --         --logger.i("Slack: intercepted button3")
    --         hs.eventtap.keyStroke({'cmd'}, 'left')
    --         return true -- discard
    --     elseif button == 4 then
    --         --logger.i("Slack: intercepted button4")
    --         hs.eventtap.keyStroke({'cmd'}, 'right')
    --         return true -- discard
    --     end
    elseif app:name() == 'Visual Studio' then
        if button == 3 then
            app:selectMenuItem({"Search", "Navigation History", "Navigate Back"})
            return true -- discard
        elseif button == 4 then
            app:selectMenuItem({"Search", "Navigation History", "Navigate Forward"})
            return true -- discard
        end

    elseif app:name() == 'Notes' then
        if button == 3 then
            -- logger.i("Notes: intercepted button3")
            hs.eventtap.keyStroke({'cmd', 'alt'}, '[')
            return true -- discard
        elseif button == 4 then
            -- logger.i("Notes: intercepted button4")
            hs.eventtap.keyStroke({'cmd', 'alt'}, ']')
            return true -- discard
        end

    end
end)

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

-- Example command:
--[[
 /opt/homebrew/bin/displayplacer \
	"id:6DF848C4-4A01-4378-8222-02DBF53E0627 origin:(0,0)" \
	"id:24B7AB28-EABA-46DE-90EA-2F69C91E67C5 origin:(2560,0)"
]]--

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
    screenLayoutWatcher()
end)


-- Caffeine from https://github.com/kbd/setup/blob/master/HOME/.hammerspoon/init.lua#L150
caffeine = hs.menubar.new()
function showCaffeine(awake)
    -- local title = awake and '☕' or '🍵'
    -- caffeine:setTitle(title)
    local icon = hs.image.imageFromPath(awake and 'cup-steaming.png' or 'cup-empty.png'):setSize({w=16,h=16})
    caffeine:setIcon(icon)
end

function toggleCaffeine()
    showCaffeine(hs.caffeinate.toggle("displayIdle"))
end

if caffeine then
    caffeine:setClickCallback(toggleCaffeine)
    showCaffeine(hs.caffeinate.get("displayIdle"))
end

-- -- On my laptops, add a menubar item to help me be sure my audio input and output are the expected devices (my AirPods)
-- if
--     hs.host.localizedName() == "Steve's MacBook Air"
--     or hs.host.localizedName() == "Steve’s MacBook Pro"
-- then
--     -- INPUT_PREFERRED_DEVICE = "External Microphone"
--     INPUT_PREFERRED_DEVICE = "AirPods Pro"
--     OUTPUT_PREFERRED_DEVICE = "AirPods Pro"

--     myAudioMenuBar = hs.menubar.new()

--     function setAudioToPreferredDevices()
--         local output = hs.audiodevice.findOutputByName(OUTPUT_PREFERRED_DEVICE)
--         if not output then
--             logger.w("Could not find preferred output device: " .. OUTPUT_PREFERRED_DEVICE)
--         else
--             if not output:setDefaultOutputDevice() then
--                 logger.w("Could not set the default output device to " .. OUTPUT_PREFERRED_DEVICE)
--             end
--         end

--         local input = hs.audiodevice.findInputByName(INPUT_PREFERRED_DEVICE)
--         if not input then
--             inputGood = false
--             logger.w("Could not find preferred input device: " .. INPUT_PREFERRED_DEVICE)
--         else
--             if not input:setDefaultInputDevice() then
--                 logger.w("Could not set the default input device to " .. INPUT_PREFERRED_DEVICE)
--             end
--         end

--         updateAudioDeviceIcon(true)
--     end

--     function updateAudioDeviceIcon(wasManual)
--         local outputGood
--         local inputGood
--         local tooltip

--         local audioDefaultOutput = hs.audiodevice.defaultOutputDevice()
--         logger.i("OUTPUT_PREFERRED_DEVICE: " .. OUTPUT_PREFERRED_DEVICE .. ", actual device: " .. audioDefaultOutput:name())
--         local outputGood = audioDefaultOutput:name() == OUTPUT_PREFERRED_DEVICE
--         tooltip = "Output: " .. audioDefaultOutput:name()

--         local audioDefaultInput = hs.audiodevice.defaultInputDevice()
--         logger.i("INPUT_PREFERRED_DEVICE: " .. INPUT_PREFERRED_DEVICE .. ", actual device: " .. audioDefaultInput:name())
--         local inputGood = audioDefaultInput:name() == INPUT_PREFERRED_DEVICE
--         tooltip = tooltip .. ", Input: " .. audioDefaultInput:name()

--         local title = '🎧' .. (outputGood and '👍' or (wasManual and '⛔️' or '⚠️')) ..
--             '🎤' .. (inputGood and '👍' or (wasManual and '⛔️' or '⚠️'))

--         myAudioMenuBar:setTitle(title)
--         myAudioMenuBar:setTooltip(tooltip)
--     end

--     if myAudioMenuBar then
--         hs.audiodevice.watcher.setCallback(function (event)
--             -- the space in "dIn " is intentional, see
--             -- [docs](https://www.hammerspoon.org/docs/hs.audiodevice.watcher.html#setCallback)
--             if event == "dOut" or event == "dIn " then
--                 updateAudioDeviceIcon()
--             end
--         end)
--         hs.audiodevice.watcher.start()
--         updateAudioDeviceIcon()
--         myAudioMenuBar:setClickCallback(setAudioToPreferredDevices)
--     end
-- end

-- On my work laptop, activate caffeine basically any time
if hs.host.localizedName() == "Steve’s MacBook Pro"
then
    caffeinateWatcher = hs.caffeinate.watcher.new(function (event)
        logger.i('caffeinate watcher caught:', event)
        -- On basically any screen event, make sure caffeine is on.
        -- This is to make sure my monitors don't go to sleep.
        if
            event == hs.caffeinate.watcher.screensaverDidStart
            or event == hs.caffeinate.watcher.screensaverDidStop
            or event == hs.caffeinate.watcher.screensDidLock
            or event == hs.caffeinate.watcher.screensDidUnlock
            or event == hs.caffeinate.watcher.screensDidWake
            or event == hs.caffeinate.watcher.sessionDidBecomeActive
            or event == hs.caffeinate.watcher.systemDidWake
        then
            if not hs.caffeinate.get("displayIdle") then
                toggleCaffeine()
            end            
        end
    end)
    caffeinateWatcher:start()
end

-- If using O365 Outlook or Calendar, intercept option-delete and
-- instead send: option-shift-left then delete
-- Currently this is a very annoying bug in O365:
-- https://answers.microsoft.com/en-us/msoffice/forum/all/mac-option-delete-keyboard-shortcut-to-delete-word/2907b079-e37d-4032-add3-ffb0d67cedd8
-- createEventTap({
--     hs.eventtap.event.types.keyDown
-- }, function(event)
--     if event:getKeyCode() == hs.keycodes.map['delete'] and event:getFlags().alt then
--         local win = hs.window.focusedWindow()
--         if win:title():find('- Outlook -') then
--             logger.i('O365 option-delete workaround firing!')
--             hs.eventtap.keyStroke({'alt', 'shift'}, 'left', 0)
--             hs.eventtap.keyStroke({}, 'delete', 0)
--             return true -- discard
--         end
--     end
-- end)


-- If using Excel, fix broken keybindings
createEventTap({
    hs.eventtap.event.types.keyDown
}, function(event)
    if hs.application.frontmostApplication():name() == "Microsoft Excel" then
        if event:getFlags().cmd then
            local flags = {}
            if event:getFlags().shift then
                table.insert(flags, 'shift')
            end
            -- util.dumpTable(flags)

            if event:getKeyCode() == hs.keycodes.map['left'] then
                hs.eventtap.keyStroke(flags, 'home', 0)
                return true -- discard
            elseif event:getKeyCode() == hs.keycodes.map['right'] then
                hs.eventtap.keyStroke(flags, 'end', 0)
                return true -- discard
            end
        end

        if event:getKeyCode() == hs.keycodes.map['delete'] and event:getFlags().alt then
            -- logger.i('Excel option-delete!')
            hs.eventtap.keyStroke({'alt', 'shift'}, 'left', 0)
            hs.eventtap.keyStroke({}, 'delete', 0)
            return true -- discard
        end

    end
end)

hs.hotkey.bind({"cmd", "alt"}, "v", function() hs.eventtap.keyStrokes(hs.pasteboard.getContents()) end)

-- myDoKeyStroke = function(modifiers, character)
--     local event = require("hs.eventtap").event
--     event.newKeyEvent(modifiers, string.lower(character), true):post()
--     event.newKeyEvent(modifiers, string.lower(character), false):post()
-- end

-- function slowPaste()
--     local str = hs.pasteboard.getContents()
--     for i = 1, #str do
--         local c = str:sub(i,i)
--         logger.i("do key stroke: " .. c)
--         myDoKeyStroke({}, c)
--         hs.timer.usleep(100000) 
--     end
-- end

-- hs.hotkey.bind({"cmd", "alt"}, "v", slowPaste)


-- -- Doesn't work

-- -- 1. Clicking the DJ button only works some of the time. Could be the
-- --    coordiantes are wrong, but seems more like a delay that the Spotify app
-- --    isn't focused yet. Maybe two clicks would solve this. Update: it does seem
-- --    to work, but then it doesn't move the mouse back.

-- -- 2. Doesn't properly focus back on the original window. It may require adding
-- --     some delay or something. Update: a delay does help

-- -- 3. Still not finding the button, maybe a percentage would help instead of a
-- --    fixed value. Update: no, percentage doesn't work. It's neither an exact
-- --    offset nor an exact percentage.

-- -- Spotify DJ button
-- function clickSpotifyDj()
--     local app = hs.application.find("Spotify")
--     if app ~= nil then
--         print('clickSpotifyDj: found Spotify app: ' .. app:name())
--         local win = app:findWindow("")
--         if win ~= nil then
--             local origFrame = win:frame()
--             print('clickSpotifyDj: found Spotify window: ' .. win:title()
--                 .. ', x: ' .. origFrame.x .. ', y: ' .. origFrame.y 
--                 .. ', w: ' .. origFrame.w .. ', h: ' .. origFrame.h)

--             local frame = win:frame()
--             frame.w = 1280
--             frame.h = 707
--             print('clickSpotifyDj: resizing Spotify to known size, w: ' .. frame.w .. ', h: ' .. frame.h)
--             win:setFrame(frame)

--             -- these are good for the DJ button
--             -- the button moves around, these numbers are not reliable
--             -- local clickX = frame.x + frame.w - 260
--             local clickX = frame.x + frame.w - 290
--             local clickY = frame.y + frame.h - 42

--             -- -- these are good for the Next track button (for debugging instead of repeatedly hitting the DJ button)
--             -- local clickX = frame.x + frame.w - 592
--             -- local clickY = frame.y + frame.h - 52

--             local origWin = hs.window.focusedWindow()
--             if origWin ~= nil then
--                 print('clickSpotifyDj: saving origWin: ' .. origWin:title())
--             end

--             local origMousePos = hs.mouse.absolutePosition()
--             print('clickSpotifyDj: saving origMousePos, x: ' .. origMousePos.x .. ', y: ' .. origMousePos.y)

--             win:focus()
--             print('clickSpotifyDj: clicking at: ' .. clickX .. ", " .. clickY)
--             hs.mouse.absolutePosition({x=clickX, y=clickY}) -- don't know why this is needed, but it is
--             -- hs.eventtap.leftClick({x=clickX, y=clickY}, 0)
--             -- hs.mouse.absolutePosition(origMousePos)

--             -- hs.timer.delayed.new(0.1, function()
--             --     print('clickSpotifyDj: restoring Spotify window size, w: ' .. origFrame.w .. ', h: ' .. origFrame.h)
--             --     win:setFrame(origFrame)
--             --     if origWin ~= nil then
--             --         print('clickSpotifyDj: focusing back on: ' .. origWin:title())
--             --         origWin:focus()
--             --     end
--             -- end):start()
--         end
--     end
-- end

-- createEventTap({
--     hs.eventtap.event.types.systemDefined
-- }, function(event)
--     local systemKey = event:systemKey()
--     local flags = event:getFlags()
--     if systemKey.key == 'FAST' and systemKey.down and flags.shift then
--         print('caught shift+FAST DOWN: ' .. systemKey.key)
--         clickSpotifyDj()
--     end
-- end)


-- Show macOS Secure Input status in a menubar icon
function updateSecureInputIndicatorIcon()
    local title = ""
    local tooltip = ""
    -- logger.i('hs.eventtap.isSecureInputEnabled(): ' .. (hs.eventtap.isSecureInputEnabled() and "true" or "false"))
    if hs.eventtap.isSecureInputEnabled() then
        title = '⛔️'
        tooltip = "macOS Secure Input is ENABLED"
    else
        title = '✅'
        tooltip = "macOS Secure Input is NOT enabled"
    end
    mySecureInputIndicator:setTitle(title)
    mySecureInputIndicator:setTooltip(tooltip)
    return true
end

mySecureInputIndicator = hs.menubar.new()
if mySecureInputIndicator then
    updateSecureInputIndicatorIcon()
    secureInputMonitorTimer = hs.timer.new(1, updateSecureInputIndicatorIcon)
    secureInputMonitorTimer:start()

    -- have to restart the timer after system sleep
    caffeinateWatcher2 = hs.caffeinate.watcher.new(function (event)
        -- logger.i('caffeinate watcher 2 caught:', event)

        if
            event == hs.caffeinate.watcher.screensaverDidStop
            or event == hs.caffeinate.watcher.screensDidUnlock
            or event == hs.caffeinate.watcher.screensDidWake
            or event == hs.caffeinate.watcher.sessionDidBecomeActive
            or event == hs.caffeinate.watcher.systemDidWake
        then
            if secureInputMonitorTimer:running()
            then
                logger.i('secureInputMonitorTimer is already running')
            else
                secureInputMonitorTimer:start()
                logger.i('secureInputMonitorTimer: RESTARTED!!!!!!!')
            end
        else
            logger.i('secureInputMonitorTimer: ignoring caffeinate event ' .. event)
        end


    end)
    caffeinateWatcher2:start()

end


hs.notify.new({title='Hammerspoon', informativeText='Config loaded'}):send()
