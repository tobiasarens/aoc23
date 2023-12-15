require("lua-string")
package.path = '../util/?.lua;' .. package.path

require("util")


local function print_table(t) 
    local entries = 0
    for k, v in pairs(t) do
        print(k, v)
        entries = entries + 1
    end
    print("entries: "..entries)
    
end

local function read_input(file)
    local lines = {}
    for line in io.lines(file) do
        local split = line:split(" ")
        local spring = split[1]:trim()

        local blocks = {}
        for _, b in pairs(split[2]:split(",")) do
            blocks[#blocks+1] = tonumber(b)
        end

        lines[#lines+1] = {spring=spring, blocks=blocks}
    end
    return lines
end

local function validate(spring, blocks)
    local start
    local found = {}
    local inBlock = false
    for i=1, spring:len() do
        local c = spring[i]
        if c == '#' and not inBlock then
            inBlock = true
            start = i
        elseif c == '.' and inBlock then
            inBlock = false
            found[#found+1] = i - start
        end
    end
    if inBlock then
        found[#found+1] = spring:len() - start + 1 
    end
    if #found ~= #blocks then
        return false
    end
    for i=1, #found do
        if found[i] ~= blocks[i] then
            return false
        end
    end
    return true
end

local function createString(dic)
    local s = ""
    for _, c in pairs(dic) do
        s = s .. c
    end
    return s
end

local function allPossibilities(inp)
    local count = 0
    for i = 1, inp:len() do
        if inp[i] == '?' then
            count = count + 1
        end
    end
    local possibilities = {}
    local numPos = 2 ^ count - 1
    for i = 0, numPos do
        --print(i)
        local tmp = i
        local current = (numPos + 1) /2
        local str = {}
        for k = 1, inp:len() do
            str[#str+1] = inp[k]
        end
        for k = 1, #str do
            if str[k] == '?' then
                if tmp >= current then
                    str[k] = '#'
                    tmp = tmp - current
                else 
                    str[k] = '.'
                end
                current = current / 2
            end
        end 
        --print(createString(str))
        possibilities[#possibilities+1] = createString(str)
    end
    --print()
    return possibilities
end

local function fillKnown(spring, blocks)
    local yts = table.pack(blocks:unpack())
end

local function possibilities(spring, blocks)
    print(spring)
    print_table(blocks)
end

local function blockSize(spring, pos)
    local c = spring[pos]
    local length = 0
    repeat
        length = length +1
        pos = pos + 1
    until c ~= spring[pos]
    return length
end

local function splitAtMax(blocks)
    local argmax = table.argmax(blocks)
    local l = {}
    local r = {}
    for i = 1, #blocks do
        if i < argmax then
            l[#l+1] = blocks[i]
        elseif i > argmax then
            r[#r+1] = blocks[i]
        end
    end
    --r = (#r == 0) and nil or r
    --l = (#l == 0) and nil or r
    return {l = l, r = r}
end

local function part1(file)
    local result = 0

    local lines = read_input(file)
    for i, line in pairs(lines) do
        local pos = allPossibilities(line.spring)
        local count = 0
        for _, p in pairs(pos) do
            --print(p)
            local val = validate(p, line.blocks)
            count = val and count + 1 or count
        end
        
        print("spring " .. i ..": " .. count)
        result = result + count
    end

    return result
end

local function spaceSize(spring, pos)
    if spring[pos] == '.' then
        return 0
    end
    local length = 0
    repeat
        length = length +1
        pos = pos + 1
    until spring[pos] == '.'
    return length
end

local function fill(spring, blocks) 
    
    print("filling: " .. spring .. " with ")
    print_table(blocks)

    if string.count(spring, '?') == 0 then
        print("no space")
        return validate(spring, blocks) and 1 or 0
    end

    if #blocks == 0 then
        print("no blocks")
        return string.count(spring, '.') == string.len(spring) and 1 or 0
    end


    local max = table.max(blocks)
    local split = splitAtMax(blocks)

    local function splitCall(spring, pos, splitBlock)
        local leftS = string.sub(spring, 1, pos - 1) 
        local rightS = string.sub(spring, pos + max)
        print(leftS .. " - " .. rightS)
        return math.min(fill(leftS, splitBlock.l), fill(rightS, splitBlock.r))
    end

    local possible = 0
    for i = 1, string.len(spring) - max do
        if spaceSize(spring, i) >= max then
            possible = possible + splitCall(spring, i, split)
        end
    end
    print(possible)
    return possible
end

local function part2(file)
    local spring = ".??..??...?###."
    local blocks = {1, 1, 3}
    fill(spring, blocks)
    return 0
end

local file = "s.txt"
local result1 = part2(file)

print("Result1: " .. result1)
-- sol1: 7307