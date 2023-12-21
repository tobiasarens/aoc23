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

MODULES = {}
LO = 'L'
HI = 'H'

COUNTER = {
    ['L'] = 0,
    ['H'] = 0
}

QUEUE = {}

function flip(state)
    return state == LO and HI or LO
end

function log(signal)
    --print("logging " .. signal)
    COUNTER[signal] = COUNTER[signal] + 1
end

function makeFlipFlop(id, targets)
    local FF = {state = LO, targets = targets, id = id}

    FF.push = function(sender, pulse)
            log(pulse)
            if pulse == LO then
                FF.state = flip(FF.state)
                FF.notice()
            end
        end
    FF.notice = function()
        local signal = FF.state
        for _, target in pairs(targets) do
            QUEUE[#QUEUE+1] = {sender=FF.id, target=target, signal = signal}
            --MODULES[target].push(FF.id, signal)
        end
    end

    MODULES[id] = FF

    return FF
end

function makeBroadcaster(id, targets)
    local B = {targets = targets, id = id}

    B.push = function(signal)
        log(signal)
        for _, target in pairs(targets) do
            
            QUEUE[#QUEUE+1] = {sender=B.id, target=target, signal = signal}
        end
    end

    MODULES[id] = B

    return B
end

function makeConjunction(id, targets)
    local C = {targets = targets, inputs = {}, id = id}

    C.allHigh = function()
        for _, inp in pairs(C.inputs) do
            if inp == LO then
                return false
            end
        end
        return true
    end

    C.push = function(sender, signal)
        log(signal)
        C.inputs[sender] = signal
        local send = C.allHigh() and LO or HI
        C.notice()
    end 

    C.notice = function()
        local signal = C.allHigh() and LO or HI
        for _, target in pairs(C.targets) do
            QUEUE[#QUEUE+1] = {sender=C.id, target=target, signal = signal}
        end
    end

    C.findInputs = function()
        for id, mod in pairs(MODULES) do
            if table.containsValue(mod.targets, C.id) then
                C.inputs[id] = LO
            end
        end 
    end

    MODULES[id] = C

    return C
end

local function read_input(file)

    local conjunctions = {}
    local broadcaster

    for line in io.lines(file) do
        local sp = line:split("->")

        
        local name = sp[1]:sub(2, -1):trim()
        local targets = sp[2]:trim():split(", ")
        --print(name)
        --print_table(targets)


        if line[1] == '%' then
            makeFlipFlop(name, targets)
        elseif line[1] == '&' then
            local c = makeConjunction(name, targets)
            conjunctions[#conjunctions+1] = c
        else
            broadcaster = makeBroadcaster(name, targets)
        end
    end

    for _, conj in pairs(conjunctions) do
        conj.findInputs()
    end

    return broadcaster
end

local function strQEntry(i)
    local e = QUEUE[i]
    return e.sender .." -".. e.signal .. " -> " .. e.target
end

local function printQ(from, to)
    from = from or 1
    to = to or #QUEUE
    for i = from, to do
        print(strQEntry(i))
    end
end

local function part1(file)

    local b = read_input(file)
    MODULES['output'] = makeConjunction('output', {})
    MODULES['rx'] = {
        push = function(sender, signal)
            if signal == LO then
                print("RX low received")
                io.read()
            end
        end
    } 

    --print_table(MODULES)

    for i = 1, 100000000 do
        b.push(LO) 

        local step = 1

        repeat
            --print(step .. " of " .. #QUEUE)
            --printQ(step, step)
            local next = QUEUE[step]
            --print(next.target)
            MODULES[next.target].push(next.sender, next.signal)

            --print("lo: " ..COUNTER[LO])
            --print("hi: " .. COUNTER[HI])
            --io.read()

            step = step + 1
        until step == table.size(QUEUE) + 1
        
        print("cycle complete ".. i .. "/ 1000")
        QUEUE = {}

    end


    print("lo: " ..COUNTER[LO])
    print("hi: " .. COUNTER[HI])

    print("result: " .. COUNTER[LO] * COUNTER[HI])

    ::ende::

end

local file = "i.txt"
part1(file)
