-- macOS sanity checks

local logger = hs.logger.new('hammerspoonSetup.lua', 'debug')

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
