for file in hs.fs.dir("include/") do
    if file:sub(-4) == '.lua' then
        local name = "include." .. file:sub(1, -5) -- name.lua -> include.name
        require(name)
    end
end

hs.notify.new({title='Hammerspoon', informativeText='Config loaded'}):send()
