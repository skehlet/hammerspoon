const hammer = require('../lib/hammer')

hammer.bind([], 't', () => {
    // Since 1.0.0-beta.3, shell() rejects with an Error when the command fails.
    hs.task.shell('/usr/bin/open -a Terminal ~', {}).catch(e => {
        console.error(`openTerminal.js: ${e.message} (stderr: ${e.stderr})`)
        hs.ui.alert(`Failed to open Terminal: ${e.message}`).show()
    })
})

module.exports = {}
