// Reload when any .js file in the v2 config directory changes. The v1 .lua files elsewhere in the
// repo don't trigger it. Hammerspoon 2 batches path events, so expect ~1 second of latency.
const watcher = hs.fs.createPathWatcher(hs.appinfo.configDir)
    .setCallback(paths => {
        if (paths.some(path => path.endsWith('.js'))) {
            hs.reload()
        }
    })
    .start()

module.exports = { watcher }
