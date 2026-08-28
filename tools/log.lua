-- line up with parity.rs indexing
-- frameCount starts at 2
local OFFSET = -2

-- local TEST_LENGTH = 1794
-- local START_FRAMES = {265, 270, 274, 286}
local TEST_LENGTH = 10000
local START_FRAMES = {265}
-- local START_FRAMES = {}

local BREAK_FRAME = nil

local COMPARE = true

local rom = emu.getRomInfo()
local romPath, _ = string.gsub(rom.path, rom.name, "")
local filename = rom.name:gsub("%.%w+$", "") .. ".log"
local path = string.gsub(rom.path, rom.name, filename)

emu.log("Opening " .. path)
local original_results = {}
local file
if COMPARE then
    local og_path = string.gsub(rom.path, rom.name, "clean.log")
    for line in io.lines(og_path) do
        line_nos = {}
        for num in string.gmatch(line, "%S+") do
            table.insert(line_nos, num)
        end
        table.insert(
            original_results,
            {
                tonumber(line_nos[2], 16),
                tonumber(line_nos[3], 16),
                tonumber(line_nos[4], 16)
            })
    end
    emu.log("Comparing.  Loaded " .. #original_results .. " lines")
end
local file = io.open(path, "w")
-- workaround to get a global state
local startIdx = {1}
local cmpIdx = {1}


function logFrame()
    state = emu.getState()
    local frameCount = state.frameCount + OFFSET

    if BREAK_FRAME == frameCount then
        emu.breakExecution()
    end

    if startIdx[1] < #START_FRAMES + 1 then
        if frameCount == START_FRAMES[startIdx[1]] then
            emu.log(string.format("%04d", frameCount) .. " pressing start")
            emu.setInput({start = true})
            startIdx[1] = startIdx[1] + 1
        end
    end

    local rng_seed = valueAtLabel16('rng_seed')
    local frameCounter = valueAtLabel16('frameCounter')
    local gameMode = valueAtLabel('gameMode')
    local generalCounter = valueAtLabel('generalCounter')
    local sleepCounter = valueAtLabel('sleepCounter')

    if COMPARE then
        if not original_results[cmpIdx[1]] then
            emu.log("Ran out of frames to compare")
            emu.breakExecution()
            return
        end
        expected_rng = original_results[cmpIdx[1]][1]
        expected_fc = original_results[cmpIdx[1]][2]
        expected_gm = original_results[cmpIdx[1]][3]
        cmpIdx[1] = cmpIdx[1] + 1

        if (
            expected_rng ~= rng_seed or
            expected_fc & 0xFF ~= frameCounter & 0xFF -- or
            -- expected_gm ~= gameMode
        ) then
        emu.log(
            "Expect: "
            .. string.format("%04X", expected_rng) .. " "
            .. string.format("%04X", expected_fc) .. " "
            .. string.format("%02X", expected_gm)
        )
        emu.log(
            "Actual: "
            .. string.format("%04X", rng_seed) .. " "
            .. string.format("%04X", frameCounter) .. " "
            .. string.format("%02X", gameMode)
        )
            emu.breakExecution()
        end
    else

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
end

function valueAtLabel(label)
    local addr = emu.getLabelAddress(label)
    return emu.read(addr.address, addr.memType)
end

function valueAtLabel16(label)
    local addr = emu.getLabelAddress(label)
    return emu.read16(addr.address, addr.memType)
end

emu.addEventCallback(logFrame, emu.eventType.inputPolled);
