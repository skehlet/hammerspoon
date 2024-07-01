#!/bin/sh

# # 1. save current mouse position
# cliclick -m verbose -r m:1000,0

# # 2. move mouse to x:0 y:0
# cliclick -m verbose -r m:1000,0

# # 3. trigger mission control
# # hs.spaces.openMissionControl()
# osascript -e 'tell applications "System Events"' -e 'key code 160' -e 'end tell'

# # 4. delay 0.1 sec
# sleep 0.1

# # 5. restore saved mouse position




cliclick \
    -m verbose \
    -r \
    m:1000,0 \
    kp:f3 \
    w:10 \
    
