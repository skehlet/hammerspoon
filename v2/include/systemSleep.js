const hammer = require('../lib/hammer')

hammer.bind(['shift'], 'l', () => {
    hammer.onUpOnce(() => hs.power.systemSleep())
})

module.exports = {}
