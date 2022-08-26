waitForVBlankTrigger = false
lastCycles = nil
highest = 0
highCount = 0

function startFrame(address, value)
    state = emu.getState()
    waitForVBlankTrigger = false
    lastCycles = state.cpu.cycleCount
    highCount = highCount + 1
    if highCount > 30 then
        highCount = 0
        highest = 0
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
        if diff > highest then
            highest = diff
        end
        emu.drawRectangle(8, 8, 150, 24, 0x000000, true, 1)
        emu.drawString(12, 9, "used cycles - " .. diff .. cyclePCT(diff), 0xFFFFFF, 0xFF000000, 1)
        emu.drawString(12, 21, "highest/sec/2 - " .. highest .. cyclePCT(highest), 0xFFFFFF, 0xFF000000, 1)

    end
end
emu.addMemoryCallback(vblankCheck, emu.memCallbackType.cpuRead, 0x33)
emu.addEventCallback(startFrame, emu.eventType.startFrame)
