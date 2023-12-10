require("lua-string")


local function print_table(t) 
    local entries = 0
    for k, v in pairs(t) do
        print(k, v)
        entries = entries + 1
    end
    print("entries: "..entries)
    
end


function read_input(file)
    local lines = {}
    for line in io.lines(file) do
        local split = line:split(" ")
        local seq = {}
        for _, s in pairs(split) do
            seq[#seq+1] = tonumber(s)
        end
        lines[#lines+1] = seq
        --print_table(seq)
    end
    return lines
end

function calc_diff(seq) 
    local diff = {}
    for i=1, #seq-1 do
        diff[#diff+1] = seq[i+1] - seq[i]
    end
    return diff
end

function allZero(seq)
    for _, v in pairs(seq) do
        if v ~= 0 then
            return false
        end
    end
    return true
end

function extrapolate(seq)

    --print_table(seq)
    if allZero(seq) then
        return 0
    end

    local diff = calc_diff(seq)
    local new = extrapolate(diff)

    --print("adding "..new .. " to " .. diff[#diff])

    return seq[#seq] + new


end

function extrapolate_left(seq)

    --print_table(seq)
    if allZero(seq) then
        return 0
    end

    local diff = calc_diff(seq)
    local new = extrapolate_left(diff)

    --print("adding "..new .. " to " .. diff[#diff])

    return seq[1] - new


end

local input = read_input("i.txt")

local next = extrapolate(input[1])

local ext = {}
local sum = 0

for _, seq in pairs(input) do
    local n= extrapolate_left(seq)
    ext[#ext+1] = n
    sum = sum + n
end

print(sum)