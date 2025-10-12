local hammer = require("lib.hammer")
local windowManagement = require("lib.windowManagement")
local util = require("lib.util")
local logger = hs.logger.new('openBrowser.lua', 'debug')

local braveAppName = "Brave Browser"
local braveExe = '/Applications/Brave Browser.app/Contents/MacOS/Brave Browser'
local defaultProfilePath = os.getenv("HOME") .. "/Library/Application Support/BraveSoftware/Brave-Browser/Default"

function openBrave()
    local app = hs.application.find(braveAppName)
    if not app then
        hs.alert.show("Application not found: " .. braveAppName)
        return nil
    end
    logger.i('Found ' .. braveAppName .. ":", app)
    local success = app:selectMenuItem({"File", "New Window"})
    if not success then
        hs.alert.show("Failed to open new " .. braveAppName .. " window")
        return nil
    end
    return app:findWindow("New Tab")
end

function openBraveBookmark(bookmarkPath)
    local newWindow = openBrave()
    if not newWindow then
        return nil
    end
    logger.i('Found new window:', newWindow)

    local success = newWindow:application():selectMenuItem(bookmarkPath)
    if not success then
        hs.alert.show("Failed to open bookmark in " .. braveAppName)
        return nil
    end

    return newWindow
end

hammer:bind({}, 'b', function ()
    windowManagement.openNewCenteredHalfWidthWindowOnCurrentScreen(openBrave)
end)

hammer:bind({}, 'a', function ()
    windowManagement.openNewCenteredHalfWidthWindowOnCurrentScreen(function ()
        return openBraveBookmark({"Bookmarks", "AI", "Claude"})
    end)
end)

hammer:bind({}, 'g', function ()
    windowManagement.openNewCenteredHalfWidthWindowOnCurrentScreen(function ()
        return openBraveBookmark({"Bookmarks", "AI", "Gemini"})
    end)
end)
