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
            print(string.rep("  ", depth)..k..":")
            util.dumpTable(v, depth+1)
        else
            print(string.rep("  ", depth)..k..": ",v)
        end
    end
end

function util.getKeys(tab)
    local keyset={}
    local n=0
    
    for k,v in pairs(tab) do
      n=n+1
      keyset[n]=k
    end

    return keyset
end

function util.getId(t)
    return string.format("%p", t)
end

function util.getCurrentMilliseconds()
    local now = hs.timer.absoluteTime() -- returns absolute time in nanoseconds since the last system boot
    return now // 1000000 -- convert to milliseconds
end

return util
