require("lua-string")

function table.copy(t, copy_function)
    copy_function = copy_function or function(v) return v end
    local cpy = {}
    for k, v in pairs(t) do
        cpy[k] = copy_function(v)
    end
    return cpy
end

function table.containsValue(t, val)
    for _, v in pairs(t) do
        if v == val then
            return true
        end
    end
    return false
end

function table.maxKV(t, comp)
    comp = comp or function(a, b) return a > b end
    local maxk
    local maxv
    for k, v in pairs(t) do
        if not maxk then
            maxk = k
            maxv =v
        elseif comp(v, maxv) then
            maxk = k
            maxv = v
        end
    end
    return {maxk, maxv}
end

function table.maxKey(t, comp)
    comp = comp or function(a, b) return a > b end
    local maxk
    for k, v in pairs(t) do
        if not maxk then
            maxk = k
        elseif comp(k, maxk) then
            maxk = k
        end
    end
    return maxk
end

function table.max(t, comp)
    return table.maxKV(t, comp)[2]
end

function table.argmax(t, comp)
    return table.maxKV(t, comp)[1]
end

function table.getOneKey(t)
    for k, _ in pairs(t) do
        return k
    end
end

function table.size(t)
    local e = 0
    for _, _ in pairs(t) do
        e = e + 1
    end
    return e
end

function string.count(str, char)
    local count  = 0
    for i = 1, string.len(str) do
        if str[i] == char then
            count = count + 1
        end
    end
    return count
end
