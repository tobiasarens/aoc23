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
    
    for x =1,#map do
        s = ""
        for y = 1,#(map[x]) do
            s = s .. map[x][y]
        end
        print(s)
    end
end


function read_input(file)
    local map = {}
    local y = 1
    for line in io.lines(file) do
        map[y] = {}

        for x=1,#line do
            map[y][x] = line[x]

        end
        y = y+1
    end
    return map
end

local function tiltN(map) 
    for x = 1, #map[1] do
        local space = 0
        for y = 1, #map do
            if map[y][x] == '.' then
                space = space + 0
            elseif map[y][x] == '#' then
                space = 0
            elseif map[y][x] == 'O' and space > 0 then
                map[y - space][x] = 'O'
                map[y][x] = '.'
            end
        end
    end
end
local function tiltS(map) 
    for x = 1, #map[1] do
        local space = 0
        for y = #map, 1, -1 do
            if map[y][x] == '.' then
                space = space + 0
            elseif map[y][x] == '#' then
                space = 0
            elseif map[y][x] == 'O'  and space > 0 then
                map[y + space][x] = 'O'
                map[y][x] = '.'
            end
        end
    end
end
local function tiltE(map) 
    for y = 1, #map do
        for x = #map[1],1, -1  do
        local space = 0
            if map[y][x] == '.' then
                space = space + 0
            elseif map[y][x] == '#' then
                space = 0
            elseif map[y][x] == 'O' and space > 0 then
                map[y][x + space] = 'O'
                map[y][x] = '.'
            end
        end
    end
end

local function tiltW(map) 
    for y = 1, #map do
        for x = 1, #map[1]  do
        local space = 0
            if map[y][x] == '.' then
                space = space + 0
            elseif map[y][x] == '#' then
                space = 0
            elseif map[y][x] == 'O' and space > 0 then
                map[y][x - space] = 'O'
                map[y][x] = '.'
            end
        end
    end
end

local function tiltNorth(map) 
    local change = false
    for y =2, #map do
        for x = 1, #map[1] do
            if map[y][x] == 'O' then
                if map[y-1][x] == '.' then
                    map[y-1][x] = 'O'
                    map[y][x] = '.'
                    change = true
                end
            end
        end
    end
    if change then
        tiltNorth(map)
    end
end
local function tiltEast(map) 
    local change = false
    for y =1, #map do
        for x = 1, #map[1] - 1 do
            if map[y][x] == 'O' then
                if map[y][x + 1] == '.' then
                    map[y][x + 1] = 'O'
                    map[y][x] = '.'
                    change = true
                end
            end
        end
    end
    if change then
        tiltEast(map)
    end
end
local function tiltSouth(map) 
    local change = false
    for y =1, #map - 1 do
        for x = 1, #map[1] do
            if map[y][x] == 'O' then
                if map[y+1][x] == '.' then
                    map[y+1][x] = 'O'
                    map[y][x] = '.'
                    change = true
                end
            end
        end
    end
    if change then
        tiltSouth(map)
    end
end
local function tiltWest(map) 
    local change = false
    for y =1, #map do
        for x = 2, #map[1] do
            if map[y][x] == 'O' then
                if map[y][x -1] == '.' then
                    map[y][x-1] = 'O'
                    map[y][x] = '.'
                    change = true
                end
            end
        end
    end
    if change then
        tiltWest(map)
    end
end

local function spinCycle(map)
    tiltN(map)
    tiltW(map)
    tiltS(map)
    tiltE(map)
end

local function spinOld(map)
    tiltNorth(map)
    tiltWest(map)
    tiltSouth(map)
    tiltEast(map)
    
end

local function calcWeight(map) 
    local w = 0
    local height = #map
    for y = 1, height do
        for x = 1, #map[1] do
            if map[y][x] == 'O' then
                w = w + height - y + 1
            end
        end
    end
    return w
end

local function mapEquals(m1, m2)
    for k, row in pairs(m1) do
        for v, c in pairs(row) do
            if m2[k][v] ~= c then
                return false
            end
        end
    end
    return true
end

local function part1(file)
    local map = read_input(file)
    --print_map(map)
    --print()
    --tiltNorth(map)
    --tilt(map, 'n')
    --print_map(map)

    local w = calcWeight(map)
    print(w)
end

local function part2()
    local map = read_input(file)

    local cpy = table.copy(map, table.copy)

    local history = {cpy}
    local numCycles = 1000000000
    local dist = 0

    for i = 1, numCycles do
        if i % 1000 == 0 then
            print(i/numCycles .. "%")
        end
        spinOld(map)
        local w = calcWeight(map)

        --print("weight after " .. i .. " spins: " .. w)

        if numCycles % i == 0 then
            for k = #history, 1, -1 do
                local h = history[k]
                if mapEquals(map, h) then
                    --print("equal at i = " .. i .. " with " .. k)
                    history[#history+1] =  table.copy(map, table.copy)
                    --print("equal at i = " .. i .. " with " .. k .. " weight: " ..w)
                    --print("cycle length: " .. i - k .. " ,modulo: " .. numCycles% (i - k) )
                    for _ = 1, (numCycles % (i - k) ) do
                        spinOld(map)
                        i = i + 1
                        local w = calcWeight(map)
                        --print("weight after " .. i .. " spins: " .. w)
                    end
                    goto after
                end
            end
        end
        history[#history+1] =  table.copy(map, table.copy)
    end
    ::after::
    --print_map(map)
    for i = 0, dist do
        local m = history[#history - i] 
        local w = calcWeight(m)
        print("end minus " .. i .. " (" .. #history - i .. ") : " ..w)
    end

    local w = calcWeight(map)
    print("end weight: " .. w)
end

file = "i.txt"
--part1(file)
part2()