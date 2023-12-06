require "lua-string"

-- sol 1: 2061

local max = {
    red = 12,
    green = 13,
    blue = 14
}
local correct_games = {}
local game_pows = {}
local min = {}

function parse_input(file)
    local f = io.open(file)
    if f == nil then
        print("no file")
        return
    end
    local lines = {}
    for line in f:lines("l") do
        lines[#lines+1] = line
    end
    return lines
end

function game_power(game) 
    local pow = 1
    for _, v in pairs(game) do
        --print(_, v)
        pow = pow * v
    end
    return pow
end

local input = parse_input('i.txt')
if input then
    for _, line in pairs(input) do
        --print(line)

        local game_game = (line):split(": ")

        local id = game_game[1]:split(" ")[2]
--
  --      print(id .. ": " .. game_game[2])

        local subgames = game_game[2]:split("; ")
        local possible = true
        local game_min = {}

        for _, v in pairs(subgames) do
            local draws = v:split(", ")

            for _, draw in pairs(draws) do
                local dr = draw:split(" ")

                local col = dr[2]
                local amount = tonumber(dr[1])

                if max[dr[2]] then
                    if tonumber(dr[1]) > max[dr[2]] then
                        possible = false
                    end
                else 
                    print("color " .. dr[2] .. " not in max table")
                end

                -- port 2
                if not game_min[col] then
                    game_min[col] = amount
                else
                    if amount > game_min[col] then

                        game_min[col] = amount
                    else
                        --print(amount .. " -- " .. col .. " -- " .. game_min[col])
                    end
                end
            end

        end

        game_pows[#game_pows+1] = game_power(game_min)

        if possible then
            correct_games[#correct_games+1] = id
        end

        ::next_game::
        --print()
    end
end

local sum = 0
local sum2 = 0

for _, game in pairs(correct_games) do
    --print(game)
    sum = sum + tonumber(game)
end

for _, pow in pairs(game_pows) do
    --print(pow)
    sum2 = sum2 + pow
end

print("sum: " .. sum)
print("sum2: " .. sum2)