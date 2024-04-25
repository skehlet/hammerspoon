local hammer = require("lib.hammer")

hammer:bind({}, 't', function ()
    os.execute('/usr/bin/open -a Terminal ~')
end)
