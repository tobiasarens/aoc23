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

local function print_meta(map)
    
    for x =1,#map do
        s = ""
        for y = 1,#(map[x]) do
            local c = (table.size(map[x][y]) > 0) and '#' or '.'
            s = s .. c
        end
        print(s)
    end
end
local function read_input(file)
    local map = {}
    local meta = {}

    for line in io.lines(file) do
        local mm = {}
        local l = {}
        for x = 1, string.len(line) do
            mm[#mm+1] = {}
            l[#l+1] = line[x] 
        end
        map[#map+1] = l
        meta[#meta+1] = mm
    end
    return {map, meta}
end

local function print_ray(ray) 
    print("Ray ["..ray.x ..", " .. ray.y ..", " .. (ray.d and ray.d or '_') .. "]")
end

MOVE_TABLE = {
    r = {
        ['/'] = 'u',
        ['\\'] = 'd',
        ['-'] = 'r',
        ['|'] = 'ud',
        ['.'] = 'r'
    },
    d = {
        ['/'] = 'l',
        ['\\'] = 'r',
        ['-'] = 'lr',
        ['|'] = 'd',
        ['.'] = 'd'
    },
    l = {
        ['/'] = 'd',
        ['\\'] = 'u',
        ['-'] = 'l',
        ['|'] = 'ud',
        ['.'] = 'l'
    },
    u = {
        ['/'] = 'r',
        ['\\'] = 'l',
        ['-'] = 'lr',
        ['|'] = 'u',
        ['.'] = 'u'
    }
}

local function moveRay(ray, map, meta)
    if not ray.d then
        print("Error")
    end
    -- update pos
    if ray.d == 'r' then
        ray.x = ray.x + 1
    elseif ray.d == 'd' then
        ray.y = ray.y + 1
    elseif ray.d == 'l' then
        ray.x = ray.x - 1
    elseif ray.d == 'u' then
        ray.y = ray.y - 1
    end

    if ray.x < 1 or ray.y < 1 or ray.y > #map or ray.x > #map[1] then
        return "end"
    end

    --print_table(meta)
    --print(ray.x.. ", ".. ray.y .. ", " .. ray.d)
    --print_table(meta[ray.y])

    if meta[ray.y][ray.x][ray.d] then
        return "end"
    end
    meta[ray.y][ray.x][ray.d] = 1

    local c = map[ray.y][ray.x]

    local next = MOVE_TABLE[ray.d][c]
    --print(c .. " next " .. next)

    if next == "ud" then
       ray.d = 'u'
       return {x=ray.x, y = ray.y, d = 'd'} 
    elseif next == "lr" then
        ray.d = 'l'
        return {x=ray.x, y = ray.y, d = 'r'} 
    else
        ray.d = next
    end
end

local function count_energized(meta)
    local count = 0
    for _, m in pairs(meta) do
        for _, e in pairs(m) do
            if table.size(e) > 0 then
            count = count + 1
            end
        end
    end
    return count
end

local function newMeta(map)
    local meta = {}
    for y, row in pairs(map) do
        local mm = {}
        for x, _ in pairs(row) do
            mm[#mm+1] = {}
        end
        meta[#meta+1] = mm
    end
    return meta
end

local function allStarts(map)
    local starts = {}

    for y = 1, #map  do
        starts[#starts+1] = {x = 0, y = y, d = 'r'}
        starts[#starts+1] = {x = #map + 1, y = y, d = 'l'}
    end
    for x = 1, #map[1] do
        starts[#starts+1] = {x = x, y = 0, d = 'd'}
        starts[#starts+1] = {x = x, y = #map[1] +1, d = 'u'}
    end

    return starts
end

local function part1(file)
    local inp = read_input(file)
    local map = inp[1]
    local meta = inp[2]
    --print_map(map)

    local rays = {{x = 0, y = 1, d = 'r'}}

    while table.size(rays) > 0 do
        for k, ray in pairs(rays) do
            local res = moveRay(ray, map, meta)
            if res then
                --print(res)
                if res == 'end' then
                    --print("ray died")
                    rays[k] = nil
                else
                    --print("ray started")
                    --print_ray(res)
                    rays[#rays+1] = res
                end
            else
                --print("no change")
                --print_ray(ray)
            end
        end
    end

    --print_meta(meta)

    local count = count_energized(meta)
    print("energized count: " .. count)

end

local function part2(file) 
    local inp = read_input(file)
    local map = inp[1]
    --print_map(map)

    local starts = allStarts(map)
    local energized = {}

    for _, start in pairs(starts) do
    local meta = newMeta(map)
    local rays = {start}

    while table.size(rays) > 0 do
        for k, ray in pairs(rays) do
            local res = moveRay(ray, map, meta)
            if res then
                --print(res)
                if res == 'end' then
                    --print("ray died")
                    rays[k] = nil
                else
                    --print("ray started")
                    --print_ray(res)
                    rays[#rays+1] = res
                end
            else
                --print("no change")
                --print_ray(ray)
            end
        end
    end

    energized[#energized+1] = count_energized(meta)

end

    --print_meta(meta)

    local count = table.max(energized)
    print("energized count: " .. count)
end

local file = "i.txt"
part2(file)