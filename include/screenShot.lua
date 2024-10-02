-- Make F13 (the button where PrintScreen is on PC keyboards) send ctrl-shift-cmd-4
-- For reference: Apple Style Guide says the proper order is Control, Option, Shift, Command
hs.hotkey.bind({}, 'f13', function()
    hs.eventtap.keyStroke({'ctrl', 'shift', 'cmd'}, '4', 0)
end)
