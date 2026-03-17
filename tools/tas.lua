-- https://tasvideos.org/7625S
-- local TASFILE = "tases/r57shell-Archanfel-Tetris-fastest999999.fm2"
local TASFILE = "heh.fm2"

local rom = emu.getRomInfo()
local romPath, _ = string.gsub(rom.path, rom.name, "")
local tasFile =  romPath .. TASFILE
local compareFile = tasFile:gsub("%.%w+$", "") .. "-clean.log"

local COMPARE_BYTES = {
    "rng_seed",
    "rng_seed_hi",
    "frameCounter",
    "frameCounterHi",
    "gameMode",
    "autorepeatX",
    "spawnCount",
}

local cmpIdx = {1 + #COMPARE_BYTES} -- skip a frame to line things up

local inputs = {}
for line in io.lines(tasFile) do
    local buttons = line:match("^|0|(........)|||$")
    if buttons then
        local input = {}
        local mapped = {
             "right",
             "left",
             "down",
             "up",
             "start",
             "select",
             "b",
             "a",
        }
        for i = 1, 8 do
            input[mapped[i]] = not (buttons:sub(i, i) == ".")
        end
        table.insert(inputs, input)
    end
end

-- extra input to force extra frame (so last input is processed)
table.insert(inputs, {})

local compareBytes = {}
for line in io.lines(compareFile) do
    for num in string.gmatch(line, "%S+") do
        table.insert(compareBytes, tonumber(num, 16))
    end
end


function applyInputs()
    local state = emu.getState()
    local input = inputs[state["frameCount"] + 1]
    if not input then
        emu.breakExecution()
        return
    else
        emu.setInput(input)
    end
    local expect = slice(compareBytes, cmpIdx[1], cmpIdx[1] + #COMPARE_BYTES)
    local actual = getValuesFromLabels()

    local expectStr = getHexString(expect)
    local actualStr = getHexString(actual)
    if expectStr ~= actualStr then
            emu.log("Expect: " .. expectStr)
            emu.log("Actual: " .. actualStr)
            emu.breakExecution()
    end
    cmpIdx[1] = cmpIdx[1] + #COMPARE_BYTES
end

function getHexString(numbers)
    result = {}
    for _, number in ipairs(numbers) do
        table.insert(result, string.format("%02X", number))
    end
    return table.concat(result, " ")

end

function slice(values, i, n)
    local result = {}
    local idx = i
    while idx < n do
        table.insert(result, values[idx])
        idx = idx + 1
    end
    return result
end

function getValuesFromLabels()
    local result = {}
    for _, label in ipairs(COMPARE_BYTES) do
        local value = valueAtLabel(label)
       table.insert(result, value )
    end
    return result
end

function valueAtLabel(label)
    local addr = emu.getLabelAddress(label)
    return emu.read(addr.address, addr.memType)
end

emu.addEventCallback(applyInputs, emu.eventType.inputPolled);
