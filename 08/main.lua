require("lua-string")


local function print_table(t) 
    local entries = 0
    for k, v in pairs(t) do
        print(k, v)
        entries = entries + 1
    end
    print("entries: "..entries)
    
end


function read_input(file)
    local inst = ""
    local lines = {}
    for line in io.lines(file) do
        lines[#lines+1] = line
    end
    inst = lines[1]
    local entries = {}

    for i=3, #lines do
        local line = lines[i]
        local entry = {}
        local split = line:split("=")
        local key = split[1]:trim()
        local dest = split[2]:split(", ")
        local left = string.sub(dest[1]:trim(), 2)
        local right = string.sub(dest[2]:trim(), 1, 3)

        entries[key] = {
            ['left'] = left,
            ['right'] = right,
            ['goLeft'] = function() return left end,
            ['goRight'] = function() return right end,
            ['go'] = function (c) return (c == 'L') and left or right end
        }
    end
    return {inst, entries}
end

local input = read_input("i.txt")

local instr = input[1]
local entries = input[2]

local count = 0
local node = 'AAA'
local target = 'ZZZ'
local posInIstr = 1

-- part 2:
local nodes = {}
for k, _ in pairs(entries) do
    if k[-1] == 'A' then
        nodes[#nodes+1] = k
    end
end

local start = nodes

local function allEnd(nodes)
    --print_table(nodes)
    for i, k in pairs(nodes) do
        if k[-1] ~= 'Z' then
            if i > 2 then 
            print(i .. " is in " .. k .. " (count " .. count .. ")")
            print_table(nodes)
            end
            return false
        end
    end
    return true
end
 
table.sort(nodes)

print_table(nodes)
--nodes = {'AAA', 'RHA', 'LHA'}

local e = false

while e and not allEnd(nodes) do

    if count % 100000 == 0 then
        --print(count)
    end
    if count == 20093 then
        --print_table(start)
        --print_table(nodes)
        --e = false
    end

    count = count + 1
    posInIstr = (posInIstr <= string.len(instr)) and posInIstr or 1
    local ins = instr[posInIstr]
    posInIstr = posInIstr+1
    for k, node in pairs(nodes) do
        nodes[k] = entries[node].go(ins)
    end


end
function part1(node, target)
    local posInIstr = 1
    local count = 0
    while node ~= target do
        count = count + 1
        posInIstr = (posInIstr <= string.len(instr)) and posInIstr or 1
        local ins = instr[posInIstr]
        --print(ins, posInIstr)
        posInIstr = posInIstr+1

        node = entries[node].go(ins)
        --print(node)

    end
    return count
end
function part2(node, start)
local posInIstr = start
local count = 0
while not allEnd({node}) do
    count = count + 1
    posInIstr = (posInIstr <= string.len(instr)) and posInIstr or 1
    local ins = instr[posInIstr]
    --print(ins, posInIstr)
    posInIstr = posInIstr+1

    node = entries[node].go(ins)
    --print(node)

end
return count
end

local times = {}
for _, k in pairs(nodes) do
    times[k] = part2(k, 1)
end

print_table(times)


-- sol part 2:
-- least common multiple of entries in times (not done in lua)

print("amount of steps: " .. count)

-- sol1: 20093