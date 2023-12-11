require("lua-string")


local function print_table(t) 
    local entries = 0
    for k, v in pairs(t) do
        print(k, v)
        entries = entries + 1
    end
    print("entries: "..entries)
    
end

local function print_map(map)
    
    for x =1,#map do
        s = ""
        for y = 1,#(map[x]) do
            s = s .. map[x][y]
        end
        print(s)
    end
end


function read_input(file)
    local inp = {}
    local map = {}
    local y = 1
    for line in io.lines(file) do
        map[y] = {}

        for x=1,#line do
            map[y][x] = line[x]

            if line[x] == 'S' then
                inp.startx = x
                inp.starty = y
                map[y][x] = '-'
            end

        end
        y = y+1
        --print_table(seq)
    end
    inp.map = map
    return inp
end

local function posString(pos)
    return "("..pos.x..","..pos.y..")"
end
local function printPos(pos)
    print(posString(pos))
end

function getNext(map, pos, cpos)
    local cx = cpos.x
    local cy = cpos.y
    local c = map[cy][cx]
    local x = pos.x
    local y = pos.y

    local nx = x
    local ny = y

    local lx
    local ly
    local rx 
    local ry 
    local r = {}
    local l = {}

    if c == '-' then
        if pos.x < cpos.x then
            -- l to r
            return {x=cpos.x + 1, y=cpos.y, l = {{x = x, y = y - 1}}, r ={{x = x, y = y + 1}}}
        else
            -- r to l
            return {x=cpos.x-1, y=cpos.y, l = {{x = x, y = y + 1}}, r = {{x = x, y = y-1}}}
        end
    elseif c == '|' then
        if pos.y < cpos.y then
            -- down
            return {x = cpos.x, y = cpos.y + 1, l = {{x = x + 1, y = y}}, r = {{ x = x - 1, y = y}}}
        else 
            -- up
            nx = cx
            ny = cy - 1
            l[#l+1] = {x = x - 1, y = y}
            r[#r+1] = {x = x +1,y = y}

        end
    elseif c == 'F' then
        if x > cx then
            -- r to b
            nx = cx
            ny = cy + 1
            r[#r+1] = {x = cx - 1, y = cy}
            r[#r+1] = {x = cx, y = cy - 1}
            
        elseif y > cy then
            -- b to r
            nx = cx + 1
            ny = cy
            l[#l+1] = {x = cx - 1, y = cy}
            l[#l+1] = {x = cx, y = cy - 1}
        else
            print("invalid F")
        end
    elseif c == '7' then
        if x < cx then
            -- l to b
            nx = cx
            ny = cy +1 
            l = {{x = cx + 1, y = cy}, {x = cx, y = cy - 1}}
        elseif y > cy then
            -- b to l
            nx = cx -1
            ny = cy
            r = {{x = cx + 1, y = cy}, {x = cx, y = cy - 1}}
        else
            print("invalid 7")
        end
    elseif c == 'J' then
        if x < cx then
            -- l to t
            nx = cx
            ny = cy -1
            r = {{x = cx + 1, y = cy}, {x = cx, y = cy + 1}}
        elseif y < cy then
            -- t to l
            nx = cx - 1
            ny = cy
            l = {{x = cx + 1, y = cy}, {x = cx, y = cy + 1}}
        else
            print("invalid J")
        end
    elseif c == 'L' then
        if x > cx then
            -- r to t
            nx = cx
            ny = cy - 1
            l = {{x = cx - 1, y = cy}, {x = cx, y = cy + 1}}
        elseif y < cy then
            -- t to r
            nx = cx + 1
            ny = cy
            r = {{x = cx - 1, y = cy}, {x = cx, y = cy + 1}}
        else
            print("invalid L")
        end

    end

    return {x = nx, y = ny, r = r, l = l}
end

local function cpyMap(map)
    local cpy = {}
    for y=1, #map do
        cpy[y] = {}
        for x=1, #(map[y]) do
            cpy[y][x] = map[y][x]
        end
    end
    return cpy
end

local function getChar(map, pos) 
    --print(pos.x .. ", " .. pos.y)
    return map[pos.y][pos.x]
end

local function setChar(map, pos, char)
    map[pos.y][pos.x] = char
end

function flood(map, startx, starty)
    local steps = 0
    local current = {x = startx, y = starty}

     -- since S = - -> goto left
    local next = {x = startx -1, y = starty}

    while getChar(map, current) ~= '_' do
        local nn = getNext(map, current, next)

        --print(posString(current) .."->"..posString(next).."("
        --..getChar(map,next)..") => ".. posString(nn))

        setChar(map, current, '_')
        current = next
        next = nn
        --print_map(map)
        --print()
        steps = steps + 1
    end

    return steps
end

function colorFlood(map, start, char)
    local c = char or '@'
    if start.x == 0 or start.y == 0 or start.y > #map or start.x > #(map[1]) then
        return 0
    end
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

function filterPipe(map, original)
    for y=1,#map do
        for x=1, #(map[y]) do
            if map[y][x] ~= "_" then
                map[y][x] = '.'
            else
                map[y][x] = original[y][x]
            end
        end
    end
end

function count_inside(map, start, next)
    local steps = 0
    local current = start

    while getChar(map, current) ~= '_' do
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

local inp = read_input("i.txt")
local start = {x = inp.startx, y = inp.starty}
--print_map(inp.map)

local original_map = cpyMap(inp.map)

local steps = flood(inp.map, inp.startx, inp.starty)
--print_map(inp.map)
print(steps)
print(steps / 2)

local map = inp.map


filterPipe(inp.map, original_map)
--print_map(inp.map)

local next = {x = start.x -1, y = start.y}
count_inside(map, start, next)


--print(colorFlood(map, {x=1, y=6}))
--print_map(map)

local cI = 0
local cO = 0

for y = 1, #map do
    for x = 1, #map[y] do
        if map[y][x] == 'I' then
            cI = cI + 1
        end
        if map[y][x] == 'O' then
            cO = cO + 1
        end
    end
end

print("Count I: " .. cI)
print("Count O: " ..cO)

--| is a vertical pipe connecting north and south.
--- is a horizontal pipe connecting east and west.
--L is a 90-degree bend connecting north and east.
-- J is a 90-degree bend connecting north and west.
-- 7 is a 90-degree bend connecting south and west.
-- F is a 90-degree bend connecting south and east.
-- . is ground; there is no pipe in this tile.
-- S (is - in input) is the starting position of the animal; there is a pipe on this tile, but your sketch doesn't show what shape the pipe has.
