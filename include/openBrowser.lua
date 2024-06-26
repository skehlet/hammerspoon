local hammer = require("lib.hammer")
local windowManagement = require("lib.windowManagement")

hammer:bind({}, 'g', function ()
    windowManagement.openNewCenteredHalfWidthWindowOnCurrentScreen("Google Chrome", function (app)
        app:selectMenuItem({"File", "New Window"})
    end)
end)

hammer:bind({}, 'b', function ()
    windowManagement.openNewCenteredHalfWidthWindowOnCurrentScreen("Brave Browser", function (app)
        -- app:selectMenuItem({"File", "New Window"})
        -- alternate, CLI-based approach: guaranteed to open a window using my Default profile (not whatever I have currently focused)
        os.execute('/Applications/Brave\\ Browser.app/Contents/MacOS/Brave\\ Browser --profile-directory="Default" --new-window')
    end)
end)
