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

local function print_item(item)
    print("{x="..item.x.. ", m=" .. item.m .. ", a=" .. item.a .. ", s=" .. item.s .. "}")
end

local function strRange(item)
    local rn = function (t) return "["..t.min .."-"..t.max.."]" end
    return "{x="..rn(item.x).. ", m=" .. rn(item.m) .. ", a=" .. rn(item.a) .. ", s=" .. rn(item.s) .. "}"

end

local function print_range(item)
    print(strRange(item))
end

local function accept(item) 
    return item.x + item.m + item.a + item.s
end

WF = {
    A = accept,
    R = function(item) return 0 end

}


local function getFn(str)
    -- px{a<2006:qkq,m>2090:A,rfg}
    
    local cond = str:split(":")
    if table.size(cond) == 1 then
        return function(item)
            --print("running target: " .. cond[1])
            return WF[cond[1]](item)
        end
    end

    local target = cond[2]
    cond = cond[1]

    local splits = {
        ['>'] = function(a, b) return a > b end,
        ['<'] = function(a, b) return a < b end
    }
    local var
    local val

    for op, fn in pairs(splits) do
        
        local sp = cond:split(op)
        if table.size(sp) == 2 then
            var = sp[1]
            val = sp[2]
            return function(item)
                if fn(item[var], tonumber(val)) then
                    --print("run function " .. target)
                    return WF[target](item)
                end
                return nil
            end
        end
    end

    print("Shouldn't be here")

    local cond = str:split(":")
    if table.size(cond) == 1 then
        return function(item)
            --print("running target: " .. cond[1])
            return WF2[cond[1]](item)
        end
    end

    local target = cond[2]
    cond = cond[1]

    local splits = {
        ['>'] = function(a, b) return a > b end,
        ['<'] = function(a, b) return a < b end
    }
    local var
    local val

    for op, fn in pairs(splits) do
        
        local sp = cond:split(op)
        if table.size(sp) == 2 then
            var = sp[1]
            val = sp[2]
            return function(item)
                if fn(item[var], tonumber(val)) then
                    --print("run function " .. target)
                    return WF[target](item)
                end
                return nil
            end
        end
    end

end

WF2 = {
    ['A'] = function(item) return {item} end,
    ['R'] = function(item) return {} end
}

function needSplit(item, k, v)
    return item[k].min < v and item[k].max > v
end

function splitMin(item, k, minV)

    if item[k].min > minV then
        return {item}
    end

    local items = {
        table.copy(item, table.copy),
        table.copy(item, table.copy)
    }
    items[1][k].min = minV + 1
    items[2][k].max = minV
    return items
end

function splitMax(item, k, maxV)
    if item[k].max < maxV then
        return {item}
    end
    local items = {
        table.copy(item, table.copy),
        table.copy(item, table.copy)
    }
    items[1][k].max = maxV - 1
    items[2][k].min = maxV
    return items
end

function process2(line)
    -- px{a<2006:qkq,m>2090:A,rfg}
    local sp = line:split("{")
    local name = sp[1]
    local cond = sp[2]:sub(1, -2)

    sp = cond:split(",")

    local fns = {}

    for i, s in pairs(sp) do
        local com = s:split(":")


        if table.size(com) == 1 then
            fns[i] = {
                fn = function(item)
                    print("calling " .. com[1] .. " on " .. strRange(item))
                    return WF2[com[1]](item)
                end,
            t = 'a'

        }
        goto cont
        end

        local c = com[1]:split('<')
        if table.size(c) == 2 then
            fns[i] = {
                fn = function(item)
                    return WF2[com[2]](item)
                end,
                maxK = c[1],
                maxV = tonumber(c[2]),
                t = 'l',
                rule = s,
            }
        else
            c = com[1]:split('>')
            if table.size(c) == 2 then
                fns[i] = {
                    fn = function(item)
                        return WF2[com[2]](item)
                    end,
                    minK = c[1],
                    minV = tonumber(c[2]),
                    t = 'g',
                    rule = s
                }
            else
                print("Invalid operator " .. s)
            end
        end
        ::cont::
    end

    WF2[name] = function(item)
        local result = {}
        local rem = item
        print("running " .. name .. " on " .. strRange(item))
        for i, fn in pairs(fns) do
            if fn.t == 'g' then
                print(fn.rule)
                local items = splitMin(rem, fn.minK, fn.minV)
                print("with " .. strRange(items[1]))
                    for _, it in pairs(fn.fn(items[1])) do
                        result[#result+1] = it
                    end
                if table.size(items) == 1 then
                    print("full match on " .. fn.rule)
                    return result
                end
                rem = items[2]
            elseif fn.t == 'l' then
                print(fn.rule)
                local items = splitMax(rem, fn.maxK, fn.maxV)
                print("with " .. strRange(items[1]))
                    for _, it in pairs(fn.fn(items[1])) do
                        result[#result+1] = it
                    end
                if table.size(items) == 1 then
                    print("full match on " .. fn.rule)
                    return result
                end
                rem = items[2]
            else
                for _, it in pairs(fn.fn(rem)) do
                    result[#result+1] = it
                end
                return result

            end
        end
        print("Shouldn't be here")
    end
end

local function read_input(file)
    local wf = {}
    local items = {}

    local mode = 'wf'

    for line in io.lines(file) do
        if line == '' then
            mode = 'it'
            goto skip
        end
        if mode == 'wf' then
            --print("reading rule " .. line)
            
            process2(line)

            local sp = line:split("{")
            local name = sp[1]
            local cond = sp[2]:sub(1, -2)

            sp = cond:split(",")

            local fn = {}
            for _, s in pairs(sp) do
                fn[#fn+1] = getFn(s)
            end

            --print_table(fn)

            wf[name] = function(item)
                for _, f in pairs(fn) do
                    --print(f)
                    local v = f(item)
                    if v then 
                        return v
                    end
                end
            end

            WF[name] = wf[name]

        else  -- read items
            local item = {}
            line = line:sub(2, -2)
            local sp = line:split(",")
            item.x = tonumber(sp[1]:split("=")[2])
            item.m = tonumber(sp[2]:split("=")[2])
            item.a = tonumber(sp[3]:split("=")[2])
            item.s = tonumber(sp[4]:split("=")[2])
            --print_item(item)
            items[#items+1] = item
        end
        ::skip::
    end
    return {wf = wf, items = items}
end

local function part1(file)
    local inp = read_input(file)
    
    local items = inp.items
    --print_table(items)
    local sum = 0
    for _, item in pairs(items) do
        --print("Item: ")
        --print_item(item)
        local v = WF['in'](item)

        --print("value: " ..v)

        sum = sum + v
    end

    print("sum " .. sum)

end

local function part2(file)
    read_input(file)
    local start = {
        x = {min = 1, max = 4000}, 
        a = {min = 1, max = 4000}, 
        m = {min = 1, max = 4000}, 
        s = {min = 1, max = 4000}}

    local split = splitMin(start, 'x', 3000)
    print_range(split[1])
    print_range(split[2])

    print()

    local result = WF2['in'](start)

    local diff = function (t) return t.max - t.min + 1 end
    local values = function (item) return diff(item.x) * diff(item.a) * diff(item.m) * diff(item.s) end

    local val = 0
    print_table(result)
    for _, i in pairs(result) do
        val = val + values(i)
        print(strRange(i) .. " = " .. values(i))
    end

    print("result: " .. val)

end

local file = "i.txt"
part2(file)