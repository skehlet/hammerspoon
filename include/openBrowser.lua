local hammer = require("lib.hammer")
local windowManagement = require("lib.windowManagement")
local util = require("lib.util")
local logger = hs.logger.new('openBrowser.lua', 'debug')

local browserAppName = "Brave Browser"

function openBrowser()
    local app = hs.application.find(browserAppName)
    if not app then
        hs.alert.show("Application not found: " .. browserAppName)
        return nil
    end
    logger.i('Found ' .. browserAppName .. ":", app)
    local success = app:selectMenuItem({"File", "New Window"})
    if not success then
        hs.alert.show("Failed to open new " .. browserAppName .. " window")
        return nil
    end
    return app:findWindow("New Tab")
end

function openBrowserBookmark(bookmarkPath)
    local newWindow = openBrowser()
    if not newWindow then
        return nil
    end
    logger.i('Found new window:', newWindow)

    local success = newWindow:application():selectMenuItem(bookmarkPath)
    if not success then
        hs.alert.show("Failed to open bookmark in " .. browserAppName)
        return nil
    end

    return newWindow
end

hammer:bind({}, 'b', function ()
    windowManagement.openNewCenteredHalfWidthWindowOnCurrentScreen(openBrowser)
end)

hammer:bind({}, 'a', function ()
    windowManagement.openNewCenteredHalfWidthWindowOnCurrentScreen(function ()
        return openBrowserBookmark({"Bookmarks", "AI", "Claude"})
    end)
end)

hammer:bind({}, 'g', function ()
    windowManagement.openNewCenteredHalfWidthWindowOnCurrentScreen(function ()
        return openBrowserBookmark({"Bookmarks", "AI", "Gemini"})
    end)
end)
