local util = {}

function util.dumpWindows(appName, filter)
    if not filter then
        filter = {currentSpace = true}
    end
    local windows = hs.window.filter.new(false):setAppFilter(appName, filter):getWindows()
    local logger = hs.logger.new('dumpWindows', 'debug')
    for idx, window in ipairs(windows) do
        logger.d('window '..idx..': '..window:title())
    end
end

return util
