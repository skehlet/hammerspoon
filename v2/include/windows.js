const hammer = require('../lib/hammer')
const windowManagement = require('../lib/windowManagement')

hammer.bind([],        'f',     windowManagement.makeFullScreen)
hammer.bind([],        'c',     windowManagement.moveToCenter)
hammer.bind([],        's',     windowManagement.stretchVertically)
hammer.bind([],        'left',  windowManagement.moveLeft)
hammer.bind(['shift'], 'left',  windowManagement.moveLeftBig)
hammer.bind(['alt'],   'left',  windowManagement.moveLeftSmall)
hammer.bind(['cmd'],   'left',  windowManagement.moveWest)
hammer.bind([],        'right', windowManagement.moveRight)
hammer.bind(['shift'], 'right', windowManagement.moveRightBig)
hammer.bind(['alt'],   'right', windowManagement.moveRightSmall)
hammer.bind(['cmd'],   'right', windowManagement.moveEast)
hammer.bind([],        'up',    windowManagement.moveUp)
hammer.bind([],        'down',  windowManagement.moveDown)

module.exports = {}
