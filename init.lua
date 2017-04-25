hs.window.animationDuration = 0

-- reload hammerspoon config automatically on save
local function reloadConfig(files)
    local doReload = false
    for _, file in pairs(files) do
        if file:sub(-4) == '.lua' then
            doReload = true
        end
    end
    if doReload then
        hs.reload()
    end
end

-- note myWatcher and other variables are deliberately global so they're never garbage collected
myWatcher = hs.pathwatcher.new(os.getenv('HOME')..'/.hammerspoon/', reloadConfig):start()

local function move(cb)
    local win = hs.window.focusedWindow()
    if win then
        local frame = win:frame()
        local screenFrame = win:screen():frame()
        frame.x, frame.y, frame.w, frame.h = cb(frame, screenFrame)
        local log = hs.logger.new('move', 'debug')
        log.d(win:title()..' to '..frame.x..','..frame.y..','..frame.w..','..frame.h)
        win:setFrame(frame)
  end
end

hyper = hs.hotkey.modal.new()

hyper:bind({}, 'f', function ()
    move(function (f, sf) return sf.x, sf.y, sf.w, sf.h end)
end)

hyper:bind({}, 'c', function ()
    move(function (f, sf)
        local x = sf.x + ((sf.w - f.w) / 2)
        local y = sf.y + ((sf.h - f.h) / 2)
        return x, y, f.w, f.h
    end)
end)

hyper:bind({}, 'left', function ()
    move(function (f, sf) return sf.x, sf.y, sf.w/2, sf.h end)
end)

hyper:bind({}, 'right', function ()
    move(function (f, sf) return (sf.x2 - sf.w/2), sf.y, sf.w/2, sf.h end)
end)

hyper:bind({}, 'up', function ()
    move(function (f, sf) return f.x, sf.y, f.w, sf.h/2 end)
end)

hyper:bind({}, 'down', function ()
    move(function (f, sf) return f.x, (sf.y2 - sf.h/2), f.w, sf.h/2 end)
end)

hyper:bind({}, 'r', hs.reload)
hyper:bind({}, 'e', hs.hints.windowHints)
hyper:bind({}, 't', function ()
    os.execute('/usr/bin/open -a Terminal ~')
end)
hyper:bind({}, 'l', function ()
    os.execute('/usr/local/bin/lockscreen')
end)

-- Use Karabiner-Elements to map caps_lock to f18.
f18 = hs.hotkey.bind({}, 'f18', function () hyper:enter() end, function () hyper:exit() end)

hs.notify.new({title='Hammerspoon', informativeText='Config loaded'}):send()
