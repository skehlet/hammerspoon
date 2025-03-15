local hammer = require("lib.hammer")
local windowManagement = require("lib.windowManagement")
local util = require("lib.util")

local braveExe = '/Applications/Brave Browser.app/Contents/MacOS/Brave Browser'
local defaultProfilePath = os.getenv("HOME") .. "/Library/Application Support/BraveSoftware/Brave-Browser/Default"

hammer:bind({}, 'g', function ()
    windowManagement.openNewCenteredHalfWidthWindowOnCurrentScreen("Google Chrome", function (app)
        app:selectMenuItem({"File", "New Window"})
    end)
end)

hammer:bind({}, 'b', function ()
    windowManagement.openNewCenteredHalfWidthWindowOnCurrentScreen("Brave Browser", function (app)
        -- Open Brave with the Default profile, if it exists; or fall back to File -> New Window
        if util.exists(defaultProfilePath) then
            local shellCmd = util.shellEscape(braveExe) .. ' --profile-directory=Default --new-window'
            hs.execute(shellCmd)
            print("Opened Brave with Default profile")
        else
            app:selectMenuItem({"File", "New Window"})
        end
    end)
end)

hammer:bind({}, 'a', function ()
    windowManagement.openNewCenteredHalfWidthWindowOnCurrentScreen("Brave Browser", function (app)
        local shellCmd = util.shellEscape(braveExe) .. ' --profile-directory=Default --new-window https://claude.ai/new'
        hs.execute(shellCmd)
    end)
end)
