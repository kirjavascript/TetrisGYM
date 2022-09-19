waitForVBlankTrigger = false
lastCycles = nil
highestShort = 0
highCountShort = 0
highestLong = 0
highCountLong = 0

function startFrame(address, value)
    state = emu.getState()
    waitForVBlankTrigger = false
    lastCycles = state.cpu.cycleCount
    highCountShort = highCountShort + 1
    highCountLong = highCountLong + 1
    if highCountShort > 30 then
        highCountShort = 0
        highestShort = 0
    end
    if highCountLong > 60*2 then
        highCountLong = 0
        highestLong = 0
    end
end

function cyclePCT(cycles)
    return string.format(" (%d%%)", math.floor((cycles / 29780.5)*100))
end

function vblankCheck(address, value)
    if waitForVBlankTrigger == false then
        waitForVBlankTrigger = true
        state = emu.getState()
        diff = state.cpu.cycleCount - lastCycles
        if diff > highestShort then
            highestShort = diff
        end
        if diff > highestLong then
            highestLong = diff
        end
        emu.drawRectangle(8, 8, 150, 36, 0x000000, true, 1)
        emu.drawString(12, 9, "used cycles - " .. diff .. cyclePCT(diff), 0xFFFFFF, 0xFF000000, 1)
        emu.drawString(12, 21, "highest/sec/2 - " .. highestShort .. cyclePCT(highestShort), 0xFFFFFF, 0xFF000000, 1)
        emu.drawString(12, 33, "highest/2sec - " .. highestLong .. cyclePCT(highestLong), 0xFFFFFF, 0xFF000000, 1)
    end
end
emu.addMemoryCallback(vblankCheck, emu.memCallbackType.cpuRead, 0x33)
emu.addEventCallback(startFrame, emu.eventType.startFrame)
