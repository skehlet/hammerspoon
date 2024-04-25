-- Caffeine from https://github.com/kbd/setup/blob/master/HOME/.hammerspoon/init.lua#L150

local logger = hs.logger.new('caffeine.lua', 'debug')

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
