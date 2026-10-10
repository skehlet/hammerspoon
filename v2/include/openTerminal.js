const hammer = require('../lib/hammer')

hammer.bind([], 't', () => {
    hs.task.shell('/usr/bin/open -a Terminal ~', {})
})

module.exports = {}
