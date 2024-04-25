-- -- On my laptops, add a menubar item to help me be sure my audio input and output are the expected devices (my AirPods)
-- if
--     hs.host.localizedName() == "Steve's MacBook Air"
--     or hs.host.localizedName() == "Steve’s MacBook Pro"
-- then
--     -- INPUT_PREFERRED_DEVICE = "External Microphone"
--     INPUT_PREFERRED_DEVICE = "AirPods Pro"
--     OUTPUT_PREFERRED_DEVICE = "AirPods Pro"

--     myAudioMenuBar = hs.menubar.new()

--     function setAudioToPreferredDevices()
--         local output = hs.audiodevice.findOutputByName(OUTPUT_PREFERRED_DEVICE)
--         if not output then
--             logger.w("Could not find preferred output device: " .. OUTPUT_PREFERRED_DEVICE)
--         else
--             if not output:setDefaultOutputDevice() then
--                 logger.w("Could not set the default output device to " .. OUTPUT_PREFERRED_DEVICE)
--             end
--         end

--         local input = hs.audiodevice.findInputByName(INPUT_PREFERRED_DEVICE)
--         if not input then
--             inputGood = false
--             logger.w("Could not find preferred input device: " .. INPUT_PREFERRED_DEVICE)
--         else
--             if not input:setDefaultInputDevice() then
--                 logger.w("Could not set the default input device to " .. INPUT_PREFERRED_DEVICE)
--             end
--         end

--         updateAudioDeviceIcon(true)
--     end

--     function updateAudioDeviceIcon(wasManual)
--         local outputGood
--         local inputGood
--         local tooltip

--         local audioDefaultOutput = hs.audiodevice.defaultOutputDevice()
--         logger.i("OUTPUT_PREFERRED_DEVICE: " .. OUTPUT_PREFERRED_DEVICE .. ", actual device: " .. audioDefaultOutput:name())
--         local outputGood = audioDefaultOutput:name() == OUTPUT_PREFERRED_DEVICE
--         tooltip = "Output: " .. audioDefaultOutput:name()

--         local audioDefaultInput = hs.audiodevice.defaultInputDevice()
--         logger.i("INPUT_PREFERRED_DEVICE: " .. INPUT_PREFERRED_DEVICE .. ", actual device: " .. audioDefaultInput:name())
--         local inputGood = audioDefaultInput:name() == INPUT_PREFERRED_DEVICE
--         tooltip = tooltip .. ", Input: " .. audioDefaultInput:name()

--         local title = '🎧' .. (outputGood and '👍' or (wasManual and '⛔️' or '⚠️')) ..
--             '🎤' .. (inputGood and '👍' or (wasManual and '⛔️' or '⚠️'))

--         myAudioMenuBar:setTitle(title)
--         myAudioMenuBar:setTooltip(tooltip)
--     end

--     if myAudioMenuBar then
--         hs.audiodevice.watcher.setCallback(function (event)
--             -- the space in "dIn " is intentional, see
--             -- [docs](https://www.hammerspoon.org/docs/hs.audiodevice.watcher.html#setCallback)
--             if event == "dOut" or event == "dIn " then
--                 updateAudioDeviceIcon()
--             end
--         end)
--         hs.audiodevice.watcher.start()
--         updateAudioDeviceIcon()
--         myAudioMenuBar:setClickCallback(setAudioToPreferredDevices)
--     end
-- end
