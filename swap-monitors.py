#!/usr/bin/python

import Quartz

mainExternalDisplayId = Quartz.CGMainDisplayID() # "Main" means "the one at 0,0"
laptopDisplayId = 0
otherExternalDisplayId = 0

# Assumes three monitor setup: laptop screen plus two externals
(activeErr, activeDisplays, displayCount) = Quartz.CGGetActiveDisplayList(3, None, None)
for id in activeDisplays:
    print(
        str(id) + ', is main? ' +(Quartz.CGDisplayIsMain(id) and "yes" or "no") + 
        ', is built in? ' + (Quartz.CGDisplayIsBuiltin(id) and "yes" or "no")
    )
    if Quartz.CGDisplayIsBuiltin(id):
        laptopDisplayId = id
    else:
        if id != mainExternalDisplayId:
            otherExternalDisplayId = id

print(
    "Swapping external monitor #" + str(mainExternalDisplayId) +
    " with #" + str(otherExternalDisplayId) +
    ", laptop is #" + str(laptopDisplayId)
)

(configErr, config) = Quartz.CGBeginDisplayConfiguration(None)

# Move the non-main display to 0,0
Quartz.CGConfigureDisplayOrigin(
    config,
    int(otherExternalDisplayId),
    0,
    0
)

# Move the main display to the right
Quartz.CGConfigureDisplayOrigin(
    config,
    int(mainExternalDisplayId),
    int(Quartz.CGDisplayPixelsWide(int(otherExternalDisplayId))),
    0
)

# Move the laptop below and to the left
Quartz.CGConfigureDisplayOrigin(
    config,
    laptopDisplayId,
    -1 * int(Quartz.CGDisplayPixelsWide(int(laptopDisplayId))),
    int(Quartz.CGDisplayPixelsHigh(int(otherExternalDisplayId)))
)

completeErr = Quartz.CGCompleteDisplayConfiguration(config, 2)
