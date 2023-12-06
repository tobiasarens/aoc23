require("lua-string")

local function read_input(file)
    local lines = {}
    for line in io.lines(file) do
        lines[#lines+1] = line
    end
    return lines
end

local function print_table(t) 
    local entries = 0
    for k, v in pairs(t) do
        print(k, v)
        entries = entries + 1
    end
    print("entries: "..entries)
    
end

local function create_block(source, dest, length) 
    return {
        ['_source'] = source,
        ['_dest'] = dest,
        ['_length'] = length,
        ['get'] = function (input)
            if (input < source) or (input > source + length - 1) then
                return nil
            else
                return dest + (input - source)
            end
        end,
        ['back'] = function(input)
            if (input < dest) or (input > dest + length - 1) then
                return nil
            else
                return source + (input - dest)
            end
        end,
        ['get_operation'] = function ()
            return dest - source
        end,
        ['contains'] = function(n)
            return n >= source and n < source + length
        end,
        ['split'] = function(n)
            return {
                create_block(source, source, n - source),
                create_block(n, n, dest - n - 1)
            }
        end
    }
end

local function block_list(blocks)
    return {
        ['get'] = function(input)
            for _, block in pairs(blocks) do
                if block.get(input) then
                    return block.get(input)
                end
            end
            return input
        end,
        ['back'] = function(input)
            for _, block in pairs(blocks) do
                if block.back(input) then
                    return block.back(input)
                end
            end
            return input
        end,
        ['get_block'] = function(n)
            for _, block in pairs(blocks) do
                if block.contains(n) then
                    return block
                end
            end
            return create_block(n, n, 1)
        end,
        ['blocks'] = function () return blocks end
    }
end

local function number_list(str) 
    local d = {}
    for _, v in pairs(str:trim():split(" ")) do
        d[#d+1] = tonumber(v)
    end
    return d
end

local function process_numbers(numbers, fn)

    local newNumbers = {}
    for _, number in pairs(numbers) do
        newNumbers[#newNumbers+1] = fn(number)
    end
    return newNumbers
end

local function getMin(table)
    local min = nil
    for _, v in pairs(table) do
        if not min then
            min = v
        end
        if v < min then
            min = v
        end
    end
    return min
end



local input = read_input("i.txt")


-- read seeds:
print(input[1])

local numbers = number_list(input[1]:split(":")[2])

local seedRanges = {}

local part2 = true
if part2 then
    local realNumbers = {}
    local k = 1
    while numbers[k] do
        print("creating range " .. k)
        seedRanges[numbers[k]] = create_block(numbers[k], numbers[k], numbers[k+1])
        k = k + 2
    end
end

local function isSeed(id)
   return block_list(seedRanges).get(id)
end

local function forward(blocks, numbers)
    for i= 1, #blocks do
        numbers = process_numbers(numbers, blocks[i].get)
    end
    return numbers
end

local function getCriticals(blocks)
    local criticals = {}
    for _, block in pairs(blocks) do
        criticals[block._source] = 1
        criticals[block._source + block._length] = 1
    end
    return criticals
end

local function reverse(blocks, numbers)
    print(#blocks)
    for i= #blocks, 1, -1 do
        numbers = process_numbers(numbers, blocks[i].back)
        --print_table(numbers)
    end
    return numbers
end

local function process_ranges_step(ranges, superblock)
    local blocks = superblock.blocks()
    local crits = getCriticals(blocks)

    print("crits")
    print_table(crits)

    for crit, _ in pairs(crits) do
        local new = {}
        for k, range in pairs(ranges) do
            if range.contains(crit) then
                print("crit " .. crit .. " inside range " .. k .. " with length " .. range._length)
                local splits = range.split(crit)
                --range[k] = nil
                new[splits[1]._source] = splits[1]
                new[splits[2]._source] = splits[2]
            else 
                new[k] = range
            end
        end
        ranges = new
    end

    local new_ranges = {}
    for k, range in pairs(ranges) do
        local s = range._source
        local block = superblock.get_block(s)
        local op = block.get_operation(s)
        print("operation: " .. op)
        local new = create_block(s + op, s + op, range._length)
        new_ranges[new._source] = new
    end
    return new_ranges
end

--print_table(numbers)
local currentLine = 4

local step_blocks = {}

-- 7 transformation steps
for i=1,7 do 
    --print("process step " .. i)
    local blocks = {}
    --built blocklist
    while input[currentLine] and input[currentLine] ~= "" do
        --print(input[currentLine])

        local values = number_list(input[currentLine])
        blocks[#blocks+1] = create_block(values[2], values[1], values[3])

        currentLine = currentLine + 1
    end

    local bb = block_list(blocks)
    step_blocks[i] = bb

    --numbers = process_numbers(numbers, bb.get)
    --print_table(numbers)

    currentLine = currentLine +2 

end

numbers = forward(step_blocks, numbers)
--print_table(numbers)

local min = getMin(numbers)

print("Minimum: " .. min)
-- sol1: 175622908

--numbers = {81, 82, 83}
for i=55, 68 do
    --numbers[#numbers+1] = i
end

print_table(seedRanges)
print_table(step_blocks[1])
--local updated = process_ranges_step(seedRanges, step_blocks[1])
local updated = seedRanges
for i=1, #step_blocks do
    updated = process_ranges_step(updated, step_blocks[i])
    print_table(updated)
    print()
end

--local binary_solution = reverse_binary_search(step_blocks, 0, 93)

--print("Part 2 sol: " .. binary_solution)