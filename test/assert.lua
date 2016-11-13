local M = {}

local function compare(a, b)
    for k, v in pairs(a) do
        if type(b[k]) == "table" and type(v) == "table" then
            return compare(b[k], v)
        end
        if b[k] ~= v then
            return nil, "args: ".. tostring(b[k]) .. ", " .. tostring(v)
        end
    end
    return true
end

local escape = function(str)
    local esc = function(char)
        return string.format("\\%02x", string.byte(char)) 
    end
    return string.gsub(str, "[^%g ]", esc)
end

local errorf = function(msg, ...)
    return error(string.format(msg, ...), 2)
end

M.compare = function(a, b)
    return a == b or compare(a, b)
end

M.compareboth = function(a, b)
    return a == b or (compare(a, b) and compare(b, a))
end

M.diff = function(a, b)
    local fd_a, err = type(a) == "string" and io.open(a) or a
    if not fd_a then
        return nil, err
    end
    local fd_b, err = type(b) == "string" and io.open(b) or b
    if not fd_b then
        return nil, err
    end
    local line = 1
    repeat
        local res_a, res_b = fd_a:read("*l"), fd_b:read("*l")
        if res_a ~= res_b then
            res_a, res_b = escape(res_a or ""), escape(res_b or "")
            return nil, string.format("line %d:\n%s\n%s", line, res_a, res_b)
        end
        line = line + 1
    until not res_a and not res_b
    fd_a:close()
    fd_b:close()
    return true
end

M.equal = function(a, b)
    return a == b 
end

M.error = function(fn, ...)
    local ok, out = pcall(fn, ...)
    return (not ok) and out 
end

M.match = function(a, b)
    return type(a) == "string" and a:match(b) 
end

M.order = function(a, ...)
    for i = 1, select("#", ...) do
        if not a[i] == select(i, ...) then
            return false
        end
    end
    return true
end

M.type = function(a, b)
    return type(a) == b 
end

local idx = function(t, key)
    local realkey = string.match(key, "^not_(.+)")
    local invert = true
    if not realkey then
        realkey, invert = key, false
    end
    return M[realkey] and function(...)
        local ok, err = M[realkey](...)
        if (ok and not invert) or (invert and not ok) then 
            return ok or true
        end
        if err and not invert then
            errorf("assert.%s failed: %s", key, err)
        end
        local args = {}
        for i = 1, select('#', ...) do
            args[i] = tostring(select(i, ...))
        end
        errorf("assert.%s failed; args: %s", key, table.concat(args, ", "))
    end
end

local call = function(self, cond, ...) 
    return assert(cond, ...) 
end

local mt = { 
    __index = idx, 
    __call  = call
}

return setmetatable({}, mt) 
