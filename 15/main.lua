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
    local inp = {}

    for line in io.lines(file) do
        inp = line:split(",")
    end
    print("input length: ".. #inp)
    return inp
end

local function hash(str)
    local cv = 0
    for i = 1, #str do
        local code = str:byte(i, i)
        cv = cv + code
        cv = cv * 17
        cv = cv % 256
    end
    return cv
end

local function part1(file)
    local inp = read_input(file)
    local value = {}
    local sum = 0
    for _, v in pairs(inp) do
        local h = hash(v)
        sum = sum + h
    end
    print("sum: " .. sum)
    return sum
end

local function contains(box, label) 
    for k, v in pairs(box) do
        if v.label == label then
            return k
        end
    end
    return nil
end

local function moveAll(box) 
    if table.size(box) == 0 then
        return
    end
    local space = 0
    -- one further because it is called after deletion
    for i = 1, table.size(box) + 1 do
        if box[i] then
            if space > 0 then
                box[i-space] = box[i]
                box[i] = nil
                space = 1
            end
        else
            space = space + 1
        end
    end
end

local function print_box(boxes)
    for nr, box in pairs(boxes) do
        if table.size(box) > 0 then 
        print("Box " .. nr)
        local s = ""
        for i = 1, #box do
            s = s .. "[" .. box[i].label .. " " .. box[i].num .. "] "
        end

        print(s)
    end
    
    end
        print()
end

local function calcPower(boxes) 
    local power = 0
    local count = 0
    for id = 0, 255 do
        local box = boxes[id]
        --print(id)
        for slot, lens in pairs(box) do
            local lP = ((id + 1) * slot * lens.num)
            print(lens.label .. ": " .. (id+1) .. " * " .. slot .. ". slot *" .. lens.num .. " (focal length) = " .. lP)
            power = power + lP
            count = count + 1
        end
    end
    print("amount of lenses: " .. count)
    return power
end

local function part2(file)
    local inp = read_input(file)
    local boxes = {}
    for i = 0,255 do
        boxes[i] = {}
    end
    local differents = {}

    for _, step in pairs(inp) do
        local sep = string.find(step, "[=-]")
        local label = string.sub(step, 1, sep -1)
        local bid = hash(label)
        local box = boxes[bid]
        local op = step[sep]

        --print_box(boxes)

        if op == "-" then 
            local c = contains(box, label)
            if c then -- delete
                --print("delete " .. label)
                box[c] = nil
                moveAll(box)
                --print_box(box, bid)
                differents[label] = nil
            end
        elseif op == "=" then
            local num = step[sep+1]
            local c = contains(box, label)
            if c then -- replace
                --print("replace " .. label)
                box[c] = {label=label, num=num}
            else -- append
                differents[label] = 1
                --print("add " .. label)
                box[#box+1] = {label=label, num=num}
            end
        end
    end

    local power = calcPower(boxes)
    print("power ".. power)

    print(table.size(differents))

end

part2("i.txt")
-- too low:
-- 61535

-- too high:
-- 251996
