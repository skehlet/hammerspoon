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

function openBrowserBookmark(win, bookmarkPath)
    local success = win:application():selectMenuItem(bookmarkPath)
    if not success then
        hs.alert.show("Failed to open bookmark in " .. browserAppName)
        return nil
    end
    return win
end

hammer:bind({}, 'b', function ()
    windowManagement.openNewWindowCenteredHalfWidthOnCurrentScreen(openBrowser)
end)

hammer:bind({}, 'a', function ()
    windowManagement.openNewWindowCenteredHalfWidthOnCurrentScreen(
        openBrowser,
        function(win) openBrowserBookmark(win, {"Bookmarks", "AI", "Claude"}) end
    )
end)

hammer:bind({}, 'g', function ()
    windowManagement.openNewWindowCenteredHalfWidthOnCurrentScreen(
        openBrowser,
        function(win) openBrowserBookmark(win, {"Bookmarks", "AI", "Gemini"}) end
    )
end)

hammer:bind({}, 'u', function ()
    local win = hs.window.focusedWindow()
    if not win or win:application():name() ~= browserAppName then
        hs.alert.show("Not a " .. browserAppName .. " window")
        return
    end
    logger.i('Current window:', win)
    return win:application():selectMenuItem({"Bookmarks", "Copy Link"})
end)
