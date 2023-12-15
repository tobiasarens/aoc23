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
    local fields = {}
    local lines = {}
    for line in io.lines(file) do
        if line == "" then
            --print("line empty")
            fields[#fields+1] = lines
            lines = {}
        else
            lines[#lines+1] = line
        end
    end
    fields[#fields+1] = lines
    return fields
end

local function transpose(field)
    local cpy ={}
    for x = 1, #field[1] do
        local s = ""
        for y = 1, #field do
            s = s .. field[y][x]
        end 
        cpy[x] = s
    end
    return cpy
end 

local function checkHorMirror(field, row)
    --print("check at row " .. row)
    local range = math.min(row -1, #field - row - 1)
    if range < 0 then
        return false
    end
    --print("range " .. range)
    for i = 0, range do
        --print("checking row " .. row - i .. " and " .. row + i + 1)
        if field[row - i] ~= field[row + i + 1] then
            return false
        end
    end
    return true
end

local function getHorMirrorRow(field, oldRef)
    oldRef = oldRef or -1
    for i = 1, #field do
        if i ~= oldRef then
        if checkHorMirror(field, i) then
            return i
        end
    end
    end
    --print("No mirror found")
    return -1
end

local function part1(file)
    local fields = read_input(file)

    local sum = 0

    for _, field in pairs(fields) do
        print_table(field)
        local row = getHorMirrorRow(field)
        if row > 0 then
            --print(row)
            sum = sum + 100 * row
        else
            local t = transpose(field)
            print_table(t)
            local col = getHorMirrorRow(t)
            --print(col)
            sum = sum + col
        end
    end
    return sum
end

local function flip(char)
    return (char == '#') and '.' or '#'
end

local function findSmudge(Ofield, oldRef)
    local field = table.copy(Ofield)
    oldRef = oldRef or -1
    --print(oldRef)
    for y = 1, #field do
        for x = 1, #field[1] do
            local old = field[y]
            local flip = flip(field[y][x])
            field[y] = field[y]:sub(1, x - 1) .. flip .. field[y]:sub(x + 1)
            --print(old)
            --print(field[y])
            local mir = getHorMirrorRow(field, oldRef)
            if mir > 0 then
                if mir ~= oldRef then
                --print_table(field)
                --print("smudge at " .. x .. ", " .. y)
                    return mir
                else 
                    --print("mirror found, but same as before")
                end
            end
            field[y] = old
        end
    end
    --print("no smudge found")
    return -1
end

local function part2(file)
    local fields = read_input(file)
    local sum = 0
    for i, field in pairs(fields) do
        local row = getHorMirrorRow(field)
        if row > 0 then
            --print(row)
            local smudge = findSmudge(field, row)
            if smudge > 0 then
                sum = sum + 100 * smudge
            else
                local t = transpose(field)
                smudge = findSmudge(t)
                if smudge > 0 then
                    sum = sum + smudge
                else
                    print_table(field)
                    print("No smuge found")
                    print("original row: " .. row)
                    sum = sum + 100 * row
                end
            end
        else
            --print("find row")
            local smudge = findSmudge(field)
            if smudge > 0 then
                sum = sum + 100 * smudge
            else
                local t = transpose(field)
                local col = getHorMirrorRow(t)
                --print("find col")
                --print_table(t)
                --print()
                --print_table(field)
                smudge = findSmudge(t, col)
                --print(smudge)
                --print()
                if smudge > 0 then
                    sum = sum + smudge
                else
                    print_table(field)
                    print("No smuge found")
                    print("original col: " .. col)
                    sum = sum + col
                end
            end
        end
    end

    print("sum = " .. sum)
    return sum

end

local file = "i.txt"
--local p1 = part1(file)
--print("result 1: " .. p1)

local p2  part2(file)