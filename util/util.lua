require("lua-string")

function table.copy(t, copy_function)
    copy_function = copy_function or function(v) return v end
    local cpy = {}
    for k, v in pairs(t) do
        cpy[k] = copy_function(v)
    end
    return cpy
end

function table.maxKV(t)
    local maxk
    local maxv
    for k, v in pairs(t) do
        if not maxk then
            maxk = k
            maxv =v
        elseif v > maxv then
            maxk = k
            maxv = v
        end
    end
    return {maxk, maxv}
end

function table.max(t)
    return table.maxKV(t)[2]
end

function table.argmax(t)
    return table.maxKV(t)[1]
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
