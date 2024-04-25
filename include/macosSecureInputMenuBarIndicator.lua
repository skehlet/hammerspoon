local logger = hs.logger.new('macosSecureInputMenuBarIndicator.lua', 'debug')

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
