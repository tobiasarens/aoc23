require("lua-string")

local function read_input(file)
    local lines = {}
    for line in io.lines(file) do
        lines[#lines+1] = line
    end
    return lines
end

local function print_table(t) 
    local entries = 0
    for k, v in pairs(t) do
        print(k, v)
        entries = entries + 1
    end
    print("entries: "..entries)
    
end

local function number_list(text)
    local solutions = text:trim():split(" ")
    for k, v in pairs(solutions) do
        solutions[k] = tonumber(v)
    end
    return solutions
end

local sum = 0
local card_count = {}

local function add_card(id, amount) 
    if not card_count[id] then
        card_count[id] = amount
    else
        card_count[id] = card_count[id] + amount
    end

end

function process_numbers(line, id)
    local numbers = line:split("|")
    local solutions = number_list(numbers[1])
    local dict = {}
    for k, v in pairs(solutions) do
        local n = tonumber(v)
        dict[n] = 1
    end

    local guessed = number_list(numbers[2])
    local value = 1
    local matches = 0
    for _, v in pairs(guessed) do
        local n = tonumber(v)
        if dict[n] then
            value = value * 2
            matches = matches + 1
        end
    end
    value = math.floor(value / 2)
    sum = sum + value
    --print("Matches for id " .. id .. ": " .. matches)
    local amount = card_count[id]
    for i = 1, matches do
        --print(i)
        add_card(id + i, amount)
    end
end

local input = read_input("i.txt")

for k, line in pairs(input) do
    local l = line:split(":")
    local id = tonumber(l[1]:trim():split("%s+", true)[2])
    --print_table(l[1]:trim():split("%s+", true))
    --print(id)
    add_card(id, 1)
    process_numbers(l[2], id)
end

local card_sum = 0

for _, v in pairs(card_count) do
    card_sum = card_sum + v
end

--print_table(card_count)

print("sum: " .. sum)
print("Card sum: " .. card_sum)