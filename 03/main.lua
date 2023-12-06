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

local total_number_count = 0
local total_part_count = 0
local total_sum = 0
local total_diff = 0
local total_numbers = {}
local gear_sum = 0

local function split_line(line)
    local dict = {}
    local numbers = string.gmatch(line, "%d+")
    local last = 1
    for number in numbers do
        total_number_count = total_number_count + 1
        local pos = string.find(line, number, last)
        local len = string.len(number)
        --print("number " .. number .. " at position " .. pos)

        total_sum = total_sum + tonumber(number)
        total_diff = total_diff + tonumber(number)

        if not total_numbers[tonumber(number)] then
            total_numbers[tonumber(number)] = 1
        else
            total_numbers[tonumber(number)] = total_numbers[tonumber(number)] + 1
        end

        for i = pos,pos+len-1 do
            dict[i] = tonumber(number, 10)
        end

        last = pos + len
    end
    --print_table(dict)
    return dict
end

-- s: 4361
-- p1: 553825
local input = read_input("i.txt")

local number_lines = {}
number_lines[0] = {}
number_lines[1] = split_line(input[1])
number_lines[#input+1] = {}

local OPERATORS = "[^%d%.]"
local op_list = {}

local sum = 0

for k, line in pairs(input) do
    print(k, line)
    if not number_lines[k+1] then
        number_lines[k+1] = split_line(input[k+1])
    end

    local op = 0
    repeat
        local parts = {}
        op = string.find(line, OPERATORS, op+1)
        if op then
            if not op_list[line[op]] then
                op_list[line[op]] = 1
            end
            --print("operator found at " .. op .. ": " .. line[op])
            parts.t = number_lines[k-1][op]
            if not parts.t then
                parts.tl = number_lines[k-1][op-1]
                parts.tr = number_lines[k-1][op+1]
            end
            parts.l = number_lines[k][op-1]
            parts.r = number_lines[k][op+1]
            parts.b = number_lines[k+1][op]
            if not parts.b then
                parts.bl = number_lines[k+1][op-1]
                parts.br = number_lines[k+1][op+1]
            end

            --print_table(parts)
            if line[op] == "*" then
                local c = 0
                local ratio = 1
                for _, v in pairs(parts) do
                    c = c +1
                    ratio = ratio * v
                end
                if c == 2 then
                gear_sum = gear_sum + ratio
                end
            end

            for _, v in pairs(parts) do
                total_part_count = total_part_count + 1
                sum = sum + v
                total_diff = total_diff - v
                total_numbers[v] = total_numbers[v] - 1
            end

        end
    until not op

    print()
    ::continue::
end

print_table(op_list)
print("sum: " .. sum)
print("number count: " .. total_number_count)
print("part count: " .. total_part_count)
print("total sum: " .. total_sum)
print("total diff: " .. total_diff)
print("gear sum: " .. gear_sum)

for k, v in pairs(total_numbers) do
    if v == 0 then
        total_numbers[k] = nil
    end
end

--print_table(total_numbers)