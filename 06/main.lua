require("lua-string")


local function print_table(t) 
    local entries = 0
    for k, v in pairs(t) do
        print(k, v)
        entries = entries + 1
    end
    print("entries: "..entries)
    
end

local function read_input(file) 
    local games = {}
    local lines = io.lines(file)
    local times = lines():split(":")[2]:trim():split("%s+", true)
    local distances = lines():split(":")[2]:trim():split("%s+", true)

    for i=1, #times do
        games[#games+1] = {
            ['time'] = tonumber(times[i]),
            ['distance'] = tonumber(distances[i])
        }
    end
    return games
end

local function newton(fn, df, start, dir)
    local dir = dir or "down"
    local xn = start

    local function check(xn)
        --print("xn, fn, df: " .. xn .. ", " .. fn(xn) .. ", " .. df(xn))
        --local cond = fn(xn) * fn(xn - 1) > 0
        local cond = math.abs(fn(xn)) < 0.001
        return cond
    end

    while not check(xn) do
        xn = xn - (fn(xn) / df(xn))
    end
    return xn
end

local function process_game(game)
    local function getValue(v)
        return (game.time - v) * v - game.distance -1
    end

    local function derivative(v) 
        return (game.time) - 2 * v 
    end

    local min = math.ceil(newton(getValue, derivative, 0))
    local max = math.floor(newton(getValue, derivative, game.time))

    --print("min " .. min .. ", max " .. max .. ", diff " .. max - min)

    return max - min +1 
end

local games = read_input("i2.txt")
--print_table(games)

local ranges = {}
local prod = 1

for i, game in pairs(games) do
    print("processing game " .. i)
    local range = process_game(game)
    ranges[#ranges+1] = range
    prod = prod * range
end

print("prod: " .. prod)

local sol2 = 30077773

print("correct: " .. ((prod == sol2) and "true" or "false"))

-- sol2: 30077773