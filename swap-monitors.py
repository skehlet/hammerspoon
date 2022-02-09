#!/usr/bin/python

import Quartz

mainDisplayId = Quartz.CGMainDisplayID() # "Main" means "the one at 0,0"
laptopId = 0
otherExternalDisplayId = 0

(activeErr, activeDisplays, displayCount) = Quartz.CGGetActiveDisplayList(3, None, None)
for id in activeDisplays:
    vendorId = Quartz.CGDisplayVendorNumber(id)
    print(str(id) + ', is main? ' + (Quartz.CGDisplayIsMain(id) and "yes" or "no") + ', is built in? ' + (Quartz.CGDisplayIsBuiltin(id) and "yes" or "no"))
    if Quartz.CGDisplayIsBuiltin(id):
        laptopId = id
    else:
        if id != mainDisplayId:
            otherExternalDisplayId = id

print("Swapping external monitor #" + str(mainDisplayId) + " with #" + str(otherExternalDisplayId) + ", laptop is #" + str(laptopId))

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
    int(mainDisplayId),
    int(Quartz.CGDisplayPixelsWide(int(otherExternalDisplayId))),
    0
)

# Move the laptop below and to the left
Quartz.CGConfigureDisplayOrigin(
    config,
    laptopId,
    -1 * int(Quartz.CGDisplayPixelsWide(int(laptopId))),
    int(Quartz.CGDisplayPixelsHigh(int(otherExternalDisplayId)))
)

completeErr = Quartz.CGCompleteDisplayConfiguration(config, 2)
