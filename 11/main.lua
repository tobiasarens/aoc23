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


local function print_galaxies(gs)
    for _, g in pairs(gs) do
        print("Galaxy " .. g.id .. "at (" .. g.x .. ", " .. g.y .. ")")
    end
end

local function read_input(file)
    local inp = {}
    local map = {}
    local id = 1
    local y = 1
    for line in io.lines(file) do

        for x = 1, #line do
            local char = line[x]
            if char == '#' then
                if not map[y] then
                    map[y] = {}
                end    
                map[y][x] = id
                id = id + 1
            end
        end
        y = y + 1
    end
    inp.map = map
    return inp
end

local function transpose(map)
    local tr = {}
    for y, row in pairs(map) do
        for x, e in pairs(row) do
            if not tr[x] then
                tr[x] = {}
            end
            tr[x][y] = e
        end
    end
    return tr
end

local function getGalaxies(map)
    local g = {}
    for y, row in pairs(map) do
        for x, e in pairs(row) do
            g[#g+1] = {e, x, y, id=e, x = x, y = y}
        end
    end
    return g
end

local function expandSpace_vert(map)
    local ymax = 0
    for y, _ in pairs(map) do
        if y > ymax then
            ymax = y
        end
    end
    local i = 1
    while i <= ymax do
        if not map[i] then
            -- empty row
            --print("Row is empyt: " .. i)

            -- move 1 further
            for k = ymax, i+1, -1 do
                map[k + 1] = map[k]
            end
            map[i+1] = nil
            ymax = ymax + 1
            i = i+1
        end
        i = i + 1
    end
end
local function expandSpace_vert_p2(map)
    local ymax = 0
    local exp = 1000000 - 1
    for y, _ in pairs(map) do
        if y > ymax then
            ymax = y
        end
    end
    local i = 1
    while i <= ymax do
        if not map[i] then
            -- empty row
            --print("Row is empyt: " .. i)

            -- move exp  further
            for k = ymax, i+1, -1 do
                map[k + exp ] = map[k]
            end
            for k = i, i+exp do
                map[k] = nil
            end
            ymax = ymax + exp
            i = i+exp

        end
        i = i + 1
    end
end

local function dist(g1, g2)
    return math.abs(g1.x - g2.x) + math.abs(g1.y - g2.y)
end

local function part1(file)
    local result = 0
    local inp = read_input(file)
    local map = inp.map
    expandSpace_vert(map)
    local tr = transpose(map)
    expandSpace_vert(tr)
    tr = transpose(tr)
    local gs = getGalaxies(tr)
    --print_galaxies(gs)

    print("galaxy count: " .. #gs)

    local sum = 0

    for i = 1, #gs-1 do
        for k = i+1, #gs do
            --print(i .. " - " .. k)
            sum = sum + dist(gs[i], gs[k])
        end
    end

    return sum
end

local function part2(file)
    local result = 0
    local inp = read_input(file)
    local map = inp.map
    expandSpace_vert_p2(map)
    local tr = transpose(map)
    expandSpace_vert_p2(tr)
    tr = transpose(tr)
    local gs = getGalaxies(tr)
    --print_galaxies(gs)

    print("galaxy count: " .. #gs)

    local sum = 0

    for i = 1, #gs-1 do
        for k = i+1, #gs do
            --print(i .. " - " .. k)
            sum = sum + dist(gs[i], gs[k])
        end
    end

    return sum

end

local file = "i.txt"
local result1 = part1(file)
print("result1: " .. result1)
-- sol1: 10231178

local result2 = part2(file)
print("result2: " .. result2)