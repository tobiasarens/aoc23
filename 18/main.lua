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

local function print_map(map)
    
    local compMin = function(a, b) return a < b end
    local maxY = table.maxKey(map)
    local minY = table.maxKey(map, compMin)

    local maxXList = {}
    local minXList = {}
    for y = minY, maxY do
        if not map[y] then
            map[y] = {}
        end
        maxXList[#maxXList+1] = table.maxKey(map[y])
        minXList[#minXList+1] = table.maxKey(map[y], compMin)
    end

    local maxX = table.max(maxXList)
    local minX = table.max(minXList, compMin)

    print("printing")
    print("y range " .. minY .. " - " .. maxY)
    print("x range " .. minX .. " - " .. maxX)
    
    for y = minY,maxY do
        local s = ""
        for x =minX,maxX do
            s = s .. map[y][x]
        end
        print(s)
    end
end


function read_input(file)
    local inp = {}
    for line in io.lines(file) do
        local sp = line:split(" ")
        inp[#inp+1] = {d = sp[1], l = sp[2], c = string.sub(sp[3], 3, 8)}
    end
    return inp
end

function next(pos, dir)
    local x = pos.x
    local y = pos.y
    if dir == 'R' then
        x = x + 1
    elseif dir == 'L' then
        x = x -1
    elseif dir == 'U' then
        y = y - 1
    elseif dir == 'D' then
        y = y + 1
    end
    return {x = x, y = y, c = pos}

end

local function addToMap(map, pos)
    if not map[pos.y] then
        map[pos.y] = {}
    end
    map[pos.y][pos.x] = '#'
end

local compMin = function(a, b) return a < b end
local function fillMap(map)
    local maxY = table.maxKey(map)
    local minY = table.maxKey(map, compMin)

    local maxXList = {}
    local minXList = {}
    for y = minY, maxY do
        if not map[y] then
            map[y] = {}
        end
        maxXList[#maxXList+1] = table.maxKey(map[y])
        minXList[#minXList+1] = table.maxKey(map[y], compMin)
    end

    local maxX = table.max(maxXList)
    local minX = table.max(minXList, compMin)

    print("y range " .. minY .. " - " .. maxY)
    print("x range " .. minX .. " - " .. maxX)

    
    for y = minY, maxY do
        for x = minX, maxX do
            if not map[y][x] then
                map[y][x] = '.'
            end
        end
    end

end

function getChar(map, pos)
    if not map[pos.y] then
        return " "
    end
    if not map[pos.y][pos.x] then
        return " "
    end
    return map[pos.y][pos.x]
end
function setChar(map, pos, c)
    if not map[pos.y] then
        return 
    end
    if not map[pos.y][pos.x] then
        return 
    end
    map[pos.y][pos.x] = c
end

function colorFlood(map, start, char)
    local c = char or '@'
    if getChar(map, start) ~= '.' then
        return 0
    end
    setChar(map, start, c)
    local count = 1
    count = count + colorFlood(map, {x=start.x + 1, y = start.y}, c)
    count = count + colorFlood(map, {x=start.x - 1, y = start.y}, c)
    count = count + colorFlood(map, {x=start.x , y = start.y + 1}, c)
    count = count + colorFlood(map, {x=start.x , y = start.y - 1}, c)

    return count
end

function count_inside(map, start, next)
    local steps = 0
    local current = start

    while getChar(map, current) ~= '#' do
        local nn = getNext(map, current, next)

        -- flood left
        for l = 1,#nn.l do
            local p = nn.l[l]
            colorFlood(map, p, 'I')
        end
        -- flood right
        for r = 1, #nn.r do
            local p = nn.r[r]
            colorFlood(map, p, 'O')
        end

        setChar(map, current, '_')
        current = next
        next = nn
        --print_map(map)
        --print()
        steps = steps + 1
    end

end

RIGHT = {
    R = 'D',
    L = 'U',
    D = 'L', 
    U = 'R'
}
LEFT = {
    R = 'U',
    L = 'D',
    D = 'R',
    U = 'L'
}

local function part1(file)
    local commands = read_input(file)
    local map = {}
    local pos = {x = 100, y = 100}

    local rights = {}
    local lefts = {}

    addToMap(map, pos)

    for _, com in pairs(commands) do
        for i = 1, com.l do
            pos = next(pos, com.d)
            addToMap(map, pos)
            rights[#rights+1] = next(pos, RIGHT[com.d])
            lefts[#lefts+1] = next(pos, LEFT[com.d])
            --print(i)
        end
    end
    fillMap(map)

    

    for _, r in pairs(lefts) do
        if getChar(map, r) ~= '#' then
            colorFlood(map, r, 'O')
        end
    end

    local iCount = 0
    local oCount = 0

    for _, row in pairs(map) do
        for _, c in pairs(row) do
            if c == '#' then
                iCount = iCount + 1
                oCount = oCount + 1
            elseif c == '.' then
                iCount = iCount + 1
            elseif c == 'O' then
                oCount= oCount + 1
            else
                --print("dot")
            end
        end
    end

    print_map(map)

    print("iCount " .. iCount)
    print("oCount " .. oCount)
end

HEX_DIR = {
    ['0'] = 'R',
    ['1'] = 'D',
    ['2'] = 'L',
    ['3'] = 'U'
}


local function part2(file)
    local commands = read_input(file)
    local map = {}
    local pos = {x = 100, y = 100}

    local rights = {}
    local lefts = {}

    addToMap(map, pos)

    for _, com in pairs(commands) do
        com.l = tonumber(string.sub(com.c, 1, 5), 16)
        com.d = HEX_DIR[com.c[-1]]
        print(com.l .. ", " .. com.d)
        for i = 1, com.l do
            pos = next(pos, com.d)
            addToMap(map, pos)
            rights[#rights+1] = next(pos, RIGHT[com.d])
            lefts[#lefts+1] = next(pos, LEFT[com.d])
            --print(i)
        end
    end
    fillMap(map)

    

    for _, r in pairs(lefts) do
        if getChar(map, r) ~= '#' then
            colorFlood(map, r, 'O')
        end
    end

    local iCount = 0
    local oCount = 0

    for _, row in pairs(map) do
        for _, c in pairs(row) do
            if c == '#' then
                iCount = iCount + 1
                oCount = oCount + 1
            elseif c == '.' then
                iCount = iCount + 1
            elseif c == 'O' then
                oCount= oCount + 1
            else
                --print("dot")
            end
        end
    end

    --print_map(map)

    print("iCount " .. iCount)
    print("oCount " .. oCount)
end

local function nextPoint(pos, dir, dist)
    if dir == 'R' then
        return {x = pos.x + dist, y = pos.y}
    elseif dir == 'L' then
        return {x = pos.x - dist, y = pos.y}
    elseif dir == 'U' then
        return {x = pos.x, y = pos.y + dist}
    elseif dir == 'D' then
        return {x = pos.x, y = pos.y - dist}
    end
    return pos
end

local function polyArea(p1, p2)
    local xdiff = p2.x - p1.x
    local ydiff = p2.y - p1.y

    if xdiff == 0 or p2.y == 0 then
        return 0
    end

    local x = math.abs(xdiff) + 1
    local y = math.abs(p2.y) + xdiff > 0 and 1 or 0



    local a =  (x * y)
    print(a)
    return xdiff > 0 and a or -a
end


local function getOffset(oldDir, dir)
    if oldDir == 'R' and dir == 'D' then
        return 1
    elseif oldDir == 'L' and dir == 'D' then
        return -1
    end
    return 0
end

OFF = {
    --R = 'D',
    L = 'D',
    D = 'L',
    U = 'R'
}

local function part1_2(file)
    local commands = read_input(file)

    local point = {x = 0, y =  0}

    local area = 0
    local od = '_'
    local ol = 0

    for _, com in pairs(commands) do

        print(point.x .. ", " .. point.y)

        local next = nextPoint(point, com.d, com.l)

        area = area + polyArea(point, next)
        point = next
        od = com.d
        ol = com.l
    end
    print("area " .. area)
end

local file = "i.txt"
part1(file)