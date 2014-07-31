LuaUtils = {}

function LuaUtils:Warning(str)
    print(" Warning: " .. str)
end

function LuaUtils:Error(str)
    print(" Error: " .. str)
end

function LuaUtils:printTab(n)
    for i = 1, n do
        io.write('\t')
    end
end

function LuaUtils:printValue(v, depth)
    if type(v) == 'string' then
        io.write(string.format('%q', v))
    elseif type(v) == 'number' then
        io.write(v)
    elseif type(v) == 'boolean' then
        io.write((v and 'true') or 'false')
    elseif type(v) == 'table' then
        self:printTable(v, depth)
    elseif type(v) == 'userdata' then
        io.write("userdata")
    elseif type(v) == 'function' then
        io.write("function")
    else
        self:Warning("invalid type " .. type(v))
    end
end

function LuaUtils:printTable(t, depth)
    if (t == nil) then
        print("printTable: nil table")
        return
    end
    local depth = depth or 1
    if (depth > 9) then
        self:Warning("too many depth; ignore")
        return
    end
    io.write('{\n')
    for k, v in pairs(t) do
        if (k ~= 'superNode') then
            self:printTab(depth)
            io.write('[')
            self:printValue(k, depth + 1)
            io.write('] = ')
            self:printValue(v, depth + 1)
            io.write(',\n')
        end
    end

    self:printTab(depth - 1)
    io.write('}\n')
end

function LuaUtils:outputTable(name, t)
    io.write(name .. ' = ')
    self:printTable(t)
end


function LuaUtils:hexToRgb(hex)
    if string.len(hex) ~= 6 then
        return 0, 0, 0
    else
        red = string.sub(hex, 1, 2)
        green = string.sub(hex, 3, 4)
        blue = string.sub(hex, -2)
        red = tonumber(red, 16)
        green = tonumber(green, 16)
        blue = tonumber(blue, 16)
        return red, green, blue
    end
end

function LuaUtils:decToHex(IN)
    local B, K, OUT, I, D = 16, "0123456789ABCDEF", "", 0
    while IN > 0 do
        I = I + 1
        IN, D = math.floor(IN / B), math.fmod(IN, B) + 1
        OUT = string.sub(K, D, D) .. OUT
    end
    return OUT
end

function LuaUtils:rgbToHex(c)
    local output = decToHex(c[1]) .. decToHex(c[2]) .. decToHex(c[3])
    return output
end

function LuaUtils:getDocPathFromFilePath(filePath)
    local getPath = function(str, sep)
        sep = sep or '/'
        return str:match("(.*" .. sep .. ")")
    end
    return getPath(filePath)
end