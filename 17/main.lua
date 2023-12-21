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


SEEN = {}
NODES = {}

local function read_input(file)
    local map = {}
    for line in io.lines(file) do
        local row = {}
        local sRow = {}
        local nRow = {}
        for x = 1, #line do
            row[#row+1] = line[x]
            sRow[#sRow+1] = "."
            nRow[#nRow+1] = {}
        end
        map[#map+1] = row
        SEEN[#SEEN+1] = sRow
        NODES[#NODES+1] = nRow
    end
    return map
end

local function print_cell(nodes)
    nodes = nodes or {}

    local parts = {
        tr = {
            d = '>',
            v = '..',
            u = ' '
        },
        tl = {
            d = '<',
            v = '..',
            u = ' '
        },
        br = {
            d = 'v',
            v = '..',
            u = ' '
        },
        bl = {
            d = '^',
            v = '..',
            u = ' '
        }
    }
    local function extract(node)
        return node.g
    end
    local function write_node(node, t)
        local v = extract(node)
        if v < 10 then
            t.v = '0'.. math.floor(v)
        elseif v >= 100 then
            t.v = math.floor(v % 100)
            t.u = 'O'
        else
            t.v = math.floor(v)
        end
    end
    for d, node in pairs(nodes) do
        
        if d == 'l' then
            write_node(node, parts.tl)
        elseif d == 'r' then
            write_node(node, parts.tr)
        elseif d == 'd' then
            write_node(node, parts.br)
        elseif d == 'u' then
            write_node(node, parts.bl)

        end
    end
    local tl = parts.tl
    local tr = parts.tr
    local bl = parts.bl
    local br = parts.br

    lines = {}
    lines[1] = "+-----+"
    lines[2] = "|".. tl.d .. tl.u .. '|' ..tr.d .. tr.u .. '|'
    lines[3] = "|".. tl.v .. '|' ..tr.v .. '|'
    lines[4] ="|--+--|"
    lines[5] = "|".. bl.d .. bl.u .. '|' ..br.d .. br.u .. '|'
    lines[6] = "|".. bl.v .. '|' ..br.v .. '|'
    lines[7] ="+-----+"

    return lines
end

function print_big()
    for y = 1, 3 do
        local cells = {}
        for x = 1, #WORLD[1] do
            local nodes = NODES[y][x]
            cells[#cells+1] = print_cell(nodes)
        end
        for l = 1, 7 do
            local s = ""
            for _, c in pairs(cells) do
                s = s .. c[l]
            end
            print(s)
        end
    end
end
TARGET = {}

local function euclid(n1, n2)
    return math.sqrt((n1.x - n2.x)^2 + (n1.y - n2.y)^2)
end

local function manhatten(n1, n2)
    return math.abs(n1.x - n2.x) + math.abs(n1.y - n2.y)
end

local function target_dist(node)
    local method = manhatten
    return method(TARGET, node)
end
local function is_target(node)
    return TARGET.x == node.x and TARGET.y == node.y
end

local function create_node(x, y,parent)
    --print("creating node " .. x .. ", " ..y)
    local node = {x=x, y=y,parent=parent}
    node.h = target_dist(node)
    node.g = parent.g +  WORLD[y][x]
    node.f = node.h + node.g
    local dir
    if parent.x < node.x then
        for x_ = parent.x+1, node.x-1 do
            node.g = node.g + WORLD[y][x_]
        end
        dir = 'r'
    elseif parent.x > node.x then
        for x_ = parent.x-1, node.x+1, -1 do
            node.g = node.g + WORLD[y][x_]
        end
        dir = 'l'
    elseif parent.y < node.y then
        for y_ = parent.y+1, node.y-1 do
            node.g = node.g + WORLD[y_][x]
        end
        dir = 'd'
    elseif parent.y > node.y then
        for y_ = parent.y-1, node.y+1, -1 do
            node.g = node.g + WORLD[y_][x]
        end
        dir = 'u'
    end
    node.f = node.h + node.g
    node.dir = dir

    if node.g ~= route_weight(node) then
        print("error")
        --io.read()
    end

    return node
end

MAX_FREEDOM = 3
MIN_STEP = 1

function freedom(node)
    MAX_FREEDOM = MAX_FREEDOM or 3

    for i = MAX_FREEDOM, 0, -1 do
        if not node.parent then
            return i
        elseif node.parent.dir ~= node.dir then
                return i
        end
    end
    return 1
end

local function add(node, open, closed)
    local free = freedom(node)
    for opened, _ in pairs(open) do
        if opened.x == node.x and opened.y == node.y then
            if opened.f <= node.f and opened.dir == node.dir then
                if  freedom(opened) >= free then
                    return
                end
            end
        end
    end
    print("close size : " .. table.size(closed))
    for close, _ in pairs(closed) do
        if close.x == node.x and close.y == node.y then
            if close.f <= node.f and close.dir == node.dir then
                if freedom(close) >= free then
                    return
                end
            else
                print("adding " .. close.f .. " vs " .. node.f)
            end
        end
    end
    print("adding node ("..node.x ..", " .. node.y .. ") (h, g, f)(" ..node.h.. ", " .. node.g .. ",".. node.f .. ")")
    SEEN[node.y][node.x] = "O"
    NODES[node.y][node.x][node.dir] = node
    open[node] = 1
end

local function prev3(node)
    local p = node
    for i = 1, MAX_FREEDOM do
        if not p.parent then
            return node
        end
        p = p.parent
    end
    return p
end

local function next(node, dir)
    if dir == 'r' then
        return create_node(node.x + 1, node.y, node)
    elseif dir == 'l' then
        return create_node(node.x - 1, node.y, node)
    elseif dir == 'u' then
        return create_node(node.x, node.y - 1, node)
    elseif dir == 'd' then
        return create_node(node.x, node.y + 1, node)
    end

end

local function openNodes(node, openlist, closed, steps, dir)
    for i = 1, steps do
        if dir == 'r' then
            
        end
    end
end

local function openNode(node, openlist, closelist)
    openlist[node] = nil

    local pre = prev3(node)    

    if node.x < #WORLD[1] and pre.x ~= node.x - MAX_FREEDOM and node.dir ~= 'l' then
        local succR = create_node(node.x + MIN_STEP, node.y, node)

        if is_target(succR) then
            return succR
        end

        add(succR, openlist, closelist)

    end
    if node.x > 1 and pre.x ~= node.x + MAX_FREEDOM and node.dir ~= 'r' then
        local succL = create_node(node.x - 1, node.y, node)

        if is_target(succL) then
            return succL
        end

        add(succL, openlist, closelist)
    end
    if node.y < #WORLD and pre.y ~= node.y - MAX_FREEDOM and node.dir ~= 'u' then
        local succD = create_node(node.x, node.y + 1, node)

        if is_target(succD) then
            return succD
        end
        add(succD, openlist, closelist)
    end
    if node.y > 1 and pre.y ~= node.y + MAX_FREEDOM and node.dir ~= 'd' then
        local succU = create_node(node.x, node.y - 1, node)
        if is_target(succU) then
            return succU
        end
        add(succU, openlist, closelist)
    end

    return false
end

local function write_route(finish, map)
    local node = finish
    local last = finish
    repeat
        local x = node.x
        local y = node.y
        local d = last.dir
        local c = 'X'
        if d == 'u' then
            c = '^'
        elseif d == 'd' then
            c = 'v'
        elseif d == 'r' then
            c = '>'
        elseif d == 'l' then
            c = '<'
        end
        map[y][x] = c
        last = node.parent
        node = node.parent
    until not node.parent
end

function route_weight(finish)
    local weight = 0
    local node = finish
    repeat
        weight = weight + WORLD[node.y][node.x]
        node = node.parent
    until not node.parent
    return weight
end

function nodeString(node)
    return "Node (".. node.x .. "," .. node.y.. ") (h, g, f)(" .. node.h .. ", " .. node.g .. ", " .. node.f .. ")"
end

function least_f(list)
    local min
    local minG
    local minK
    for k, _ in pairs(list) do
        if not min or k.f < min then
            min = k.f
            minK = k
            minG = k.g
        elseif k.f == min then
            if k.g < minG then
                minK = k
                minG = k.g
            end
        end
    end
    return minK
end

function least_g(list)
    local min
    local minG
    local minK
    for k, _ in pairs(list) do
        if not min or k.g < min then
            min = k.g
            minK = k
            minG = k.f
        elseif k.g == min then
            if k.f < minG then
                minK = k
                minG = k.f
            end
        end
    end
    return minK 
end

WORLD = {}

local function part1(file)

    local map =read_input(file)
    print_map(map)

    TARGET = {x=#map[1], y = #map}
    --TARGET = {x=9, y = 1}
    WORLD = map

    local opened = {}
    local closed = {}
    local finish

    local start = {x = 1, y = 1, g = 0, f = 0}
    start.h = target_dist(start)
    opened[start] = 1
    local i = 0

    local ff

    while table.size(opened) > 0  do
        i = i + 1
        print()
        print("open size " .. table.size(opened))

        local node = least_g(opened)

        SEEN[node.y][node.x] = "X"

        print("chosen " .. nodeString(node))

        opened[node] = nil


        finish = openNode(node, opened, closed)
        if finish then
            local newW = route_weight(finish)
            if not ff then
                ff = finish
            end
            print("ROUTE FOUND "..newW .. "( vs " .. route_weight(ff)..")")
            goto finish
            io.read()
            if newW < route_weight(ff) then

                ff = finish
            end
            --goto finish
        end
        closed[node] = 1
        print_map(SEEN)
        print("opened")
        for o, _ in pairs(opened) do
            print(nodeString(o))
        end
        --print_big()
        --io.read()
        print("--")
        if i < -3 then
            goto finish
        end
    end

    ::finish::
    print("finished")
    local w  = 0
    if ff then
        w = route_weight(ff)
        write_route(ff, map)
    end
    print_map(map)
    print()
    print("opened " .. table.size(opened))
    print("closed " .. table.size(closed))
    print()
    print_map(SEEN)

    print(is_target({x = 9, y = 1}))

    print("Weight " .. w)

end
local function part2(file)
    MAX_FREEDOM = 10
    MIN_STEP = 2
    local map =read_input(file)
    print_map(map)

    TARGET = {x=#map[1], y = #map}
    --TARGET = {x=9, y = 1}
    WORLD = map

    local opened = {}
    local closed = {}
    local finish

    local start = {x = 1, y = 1, g = 0, f = 0}
    start.h = target_dist(start)
    opened[start] = 1
    local i = 0

    local ff

    while table.size(opened) > 0  do
        i = i + 1
        print()
        print("open size " .. table.size(opened))

        local node = least_g(opened)

        SEEN[node.y][node.x] = "X"

        print("chosen " .. nodeString(node))

        opened[node] = nil


        finish = openNode(node, opened, closed)
        if finish then
            local newW = route_weight(finish)
            if not ff then
                ff = finish
            end
            print("ROUTE FOUND "..newW .. "( vs " .. route_weight(ff)..")")
            goto finish
            io.read()
            if newW < route_weight(ff) then

                ff = finish
            end
            --goto finish
        end
        closed[node] = 1
        print_map(SEEN)
        print("opened")
        for o, _ in pairs(opened) do
            print(nodeString(o))
        end
        --print_big()
        --io.read()
        print("--")
        if i < -3 then
            goto finish
        end
    end

    ::finish::
    print("finished")
    local w  = 0
    if ff then
        w = route_weight(ff)
        write_route(ff, map)
    end
    print_map(map)
    print()
    print("opened " .. table.size(opened))
    print("closed " .. table.size(closed))
    print()
    print_map(SEEN)

    print(is_target({x = 9, y = 1}))

    print("Weight " .. w)

end

local file = "s.txt"
part2(file)