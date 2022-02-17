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

function util.dumpTable(table, depth)
    depth = depth or 0
    if (depth > 200) then
        print("Error: Depth > 200 in dumpTable()")
        return
    end
    for k,v in pairs(table) do
        if (type(v) == "table") then
            logger.i(string.rep("  ", depth)..k..":")
            dumpTable(v, depth+1)
        else
            logger.i(string.rep("  ", depth)..k..": ",v)
        end
    end
end

return util
