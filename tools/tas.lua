-- https://tasvideos.org/7625S
local rom = emu.getRomInfo()
local romPath, _ = string.gsub(rom.path, rom.name, "")
local filename =  romPath .. "r57shell-Archanfel-Tetris-fastest999999.fm2"

local inputs = {}
for line in io.lines(filename) do
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

function applyInputs()
    local state = emu.getState()
    local input = inputs[state["frameCount"]+1]
    if not input then
        emu.breakExecution()
    else
        emu.setInput(input)
    end
end

emu.addEventCallback(applyInputs, emu.eventType.inputPolled);
