require("lua-string")


local function print_table(t) 
    local entries = 0
    for k, v in pairs(t) do
        print(k, v)
        entries = entries + 1
    end
    print("entries: "..entries)
    
end

ORDER  = {
    T = 10,
    J = 1,
    Q = 12,
    K = 13,
    A = 14
}
for i = 2, 9 do
    ORDER[tostring(i)] = i
end

Hand = {cards = "", bid = 0}


function Hand:new(cards, bid)
    local hand = {}
    hand.cards = cards
    hand.bid = tonumber(bid)

    self.__tostring = function(h)
            return "<Hand: cards: " .. h.cards ..", bid: " .. h.bid .. ">"
        end
    

    setmetatable(hand, self)

    self.__index = self
    self.cards = cards or ""
    self.bid = bid or 0

    return hand
end

function Hand:cardCounts()
    local counts = {}
    for i = 1,5 do
        local c = self.cards[i]
        if not counts[c] then
            counts[c] = 1
        else 
            counts[c] = counts[c] + 1
        end
    end
    return counts
end

TS = {
    'high', 'pair', 'two pair', 'three', 'full', 'four', 'five'
}

function Hand:type()
    if self.typeval then
        return self.typeval
    end
    local counts = self:cardCounts()
    local cards = {}
    local jokers = 0
    for k, v in pairs(counts) do
        if k == 'J' then
            jokers = v
        else
            cards[#cards+1] = {
                ['name'] = k,
                ['count'] = v
            }
        end
    end
    table.sort(cards, function (a, b)
        return a.count > b.count
    end)

    if jokers == 5 then
        return 7
    end
    for i = 1, #cards do
        local card = cards[i]
        if card.count + jokers == 5 then
            self.typeval = 7
        elseif card.count + jokers == 4 then
            self.typeval = 6
        elseif card.count  + jokers == 3 then
            if cards[i+1] and cards[i+1].count == 2 then
                self.typeval = 5
            else
                self.typeval = 4
            end
        elseif card.count + jokers == 2 then
            if cards[i+1] and cards[i+1].count == 2 then
                self.typeval = 3
            else
                self.typeval = 2
            end
        end
        if self.typeval then
            return self.typeval
        end
    end
        if jokers > 0 then
            print("having jokers left")
        end
        self.typeval = 1
        return 1
end

function Hand.compare(h1, h2)
    local type1 = h1:type()
    local type2 = h2:type()
    if type1 ~= type2 then
        return type1 < type2
    end

    -- else compare kicker
    for i = 1,5 do
        local val1 = ORDER[h1.cards[i]]
        local val2 = ORDER[h2.cards[i]]
        --print(val1 .. " -- " .. val2)
        if val1 ~= val2 then
            return val1 < val2
        end
    end
    --print("end of comparing")
    --print(type1 .. " -- " .. type2)
    --print(h1.cards .. " -- " .. h2.cards)
    return false
end

local function read_input(file)
    local hands = {}
    for line in io.lines(file) do
        --print(line)
        local s = line:split(" ")
        hands[#hands+1] =  Hand:new(s[1], s[2])
    end
    return hands
end

local input = read_input("i.txt")
--print_table(input)

table.sort(input, Hand.compare)

--print_table(input)

local sum = 0

for k,hand in pairs(input) do
    --print(k, hand, TS[hand.typeval])
    sum = sum + (k * hand.bid)
end

print("sum: " .. sum)
-- sol1: 249726565
-- sol2: 251135960

-- part 2:
-- too low:
-- 250789028
-- 250661094
-- 250917800

