
function read_input(file)
    local f = io.open(file, "r")
    if f == nil then
        print("file not found")
    end
    local lines = {}
    for line in io.lines(file) do
        table.insert(lines, line)
    end
    return lines
end

LITERALS = {'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine'}

function test_literals(str, lit)
    local pos = {}
    for k, v in pairs(lit) do
        pos[k] = string.find(str, v)
    end
    pos[0] = string.find(str, "%d")
    return pos

end

function get_min(numbers, str)
    m = string.len(str) +1
    m_k = 0
    for k, v in pairs(numbers) do
        --print(k, v)
        if v < m then
            m = v
            m_k = k
        end
    end
    return (m_k ~= 0) and tostring(m_k) or string.sub(str, m, m)
end


function first_int(str)
    local i = string.find(str, "%d")
    local r = (i ~= nil) and 0 or 1
    for k, digit in pairs(LITERALS) do
        local found = string.find(str, digit)
        if found ~= nil then
            i = math.min(i, found)
            r = k
        end
    end
    return (r == 0) and string.sub(str, i, i) or r
end

function last_int(str)
    return first_int(string.reverse(str))
end

inp = read_input('input.txt')
sum = 0

REVERSED = {}
for k, v in pairs(LITERALS) do
    REVERSED[k] = string.reverse(v)
end

for _, line in pairs(inp) do
    numbers = test_literals(line, LITERALS)
    first = get_min(numbers, line)
    rev = string.reverse(line)
    numbers = test_literals(rev, REVERSED)
    last = get_min(numbers, rev)
    --print()
    n = first..last
    --print(n)
    --n = first_int(line)..last_int(line)
    --print(n)
    n = tonumber(n)
    --print(n)
    --print(n)
    sum = sum + n
end

print(sum)
