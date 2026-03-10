-- line up with cycle_parity.rs indexing
-- frameCount starts at 2
local OFFSET = -2
-- local TEST_LENGTH = 1794
-- local START_FRAMES = {265, 270, 274, 286}
local TEST_LENGTH = 2000
local START_FRAMES = {1794, 1800, 1900}

local BREAK_FRAME = nil

local rom = emu.getRomInfo()
local romPath, _ = string.gsub(rom.path, rom.name, "")
local filename = rom.name:gsub("%.%w+$", "") .. ".log"
local path = string.gsub(rom.path, rom.name, filename)
emu.log("Opening " .. path)
local file = io.open(path, "w")

-- workaround to get a global state
local startIdx = {1}
function logFrame()
    state = emu.getState()
    local frameCount = state.frameCount + OFFSET

    if BREAK_FRAME == frameCount then
        emu.breakExecution()
    end

    if startIdx[1] < #START_FRAMES then
        if frameCount == START_FRAMES[startIdx[1]] then
            emu.setInput({start = true})
            startIdx[1] = startIdx[1] + 1
        end
    end

    local rng_addr = emu.getLabelAddress('rng_seed')
    local rng_seed = emu.read16(rng_addr.address, rng_addr.memType)

    local fc_addr = emu.getLabelAddress('frameCounter')
    local frameCounter = emu.read16(fc_addr.address, fc_addr.memType)

    local gm_addr = emu.getLabelAddress('gameMode')
    local gameMode = emu.read(gm_addr.address, gm_addr.memType)

    local gc_addr = emu.getLabelAddress('generalCounter')
    local generalCounter = emu.read(gc_addr.address, gc_addr.memType)

    local sc_addr = emu.getLabelAddress('sleepCounter')
    local sleepCounter = emu.read(sc_addr.address, sc_addr.memType)
    file:write(
        string.format("%04d", frameCount) .. " "
        .. string.format("%04X", rng_seed) .. " "
        .. string.format("%04X", frameCounter) .. " "
        -- .. string.format("%02X", sleepCounter) .. " "
        -- .. string.format("%02X", generalCounter) .. " "
        .. string.format("%02X", gameMode) .. "\n"
    )

    if frameCount >= TEST_LENGTH then
        file:close()
        emu.breakExecution()
        emu.log("Wrote " .. frameCount + 1 .. " lines to " .. path)
    end
end

emu.addEventCallback(logFrame, emu.eventType.inputPolled);
