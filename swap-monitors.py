#!/usr/bin/python

# Problem: you have a MacBook with two identical external monitors, one of which
# is intended to be your primary display, but upon waking from sleep, the
# monitors are randomly swapped. It's as if macOS couldn't physically tell the
# left monitor from the right, and it's a race condition based on whichever one
# came out of sleep first. Others have reported issues with macOS forgetting
# rotation, this is not that--this script will simply swap what's on your two
# external monitors.
#
# Based on the idea from this C code: http://www.dialxs.com/dev/main.c and
# Python+Quartz code from: https://stackoverflow.com/a/57435214/296829 Bind it
# to a Hammerspoon hotkey or use another tool to make it easy to run.

import Quartz

mainExternalDisplayId = Quartz.CGMainDisplayID()  # "Main" means "the one at 0,0"
otherExternalDisplayId = 0
builtinDisplayId = 0

(activeErr, activeDisplays, displayCount) = Quartz.CGGetActiveDisplayList(3, None, None)
for id in activeDisplays:
    print(
        str(id)
        + ", is main? "
        + (Quartz.CGDisplayIsMain(id) and "yes" or "no")
        + ", is built in? "
        + (Quartz.CGDisplayIsBuiltin(id) and "yes" or "no")
    )
    if Quartz.CGDisplayIsBuiltin(id):
        builtinDisplayId = id
    else:
        if id != mainExternalDisplayId:
            otherExternalDisplayId = id

print(
    "Swapping external monitor #"
    + str(mainExternalDisplayId)
    + " with #"
    + str(otherExternalDisplayId)
    + ", builtin is #"
    + str(builtinDisplayId)
)

(configErr, config) = Quartz.CGBeginDisplayConfiguration(None)

# Move the non-main display to 0,0
Quartz.CGConfigureDisplayOrigin(config, int(otherExternalDisplayId), 0, 0)

# Move the main display to the right
Quartz.CGConfigureDisplayOrigin(
    config,
    int(mainExternalDisplayId),
    int(Quartz.CGDisplayPixelsWide(int(otherExternalDisplayId))),
    0,
)

# It doesn't seem to be necessary to reposition the laptop display
# so I've commented this out.
# # Move the laptop below and to the left
# Quartz.CGConfigureDisplayOrigin(
#     config,
#     builtinDisplayId,
#     -1 * int(Quartz.CGDisplayPixelsWide(int(builtinDisplayId))),
#     int(Quartz.CGDisplayPixelsHigh(int(otherExternalDisplayId))),
# )

completeErr = Quartz.CGCompleteDisplayConfiguration(config, 2)
