local Game = require("Game")
-- function send(x)
--     coroutine.yield(x)
-- end
-- function receive(prod)
--     local status, value = coroutine.resume(prod)
--     return value
-- end
-- function producer()
--     return coroutine.create(function()
--         while true do
--             local x = io.read()
--             send(x)
--         end
--     end)
-- end
-- function filter(prod)
--     return coroutine.create(function()
--         while true do
--             local x = receive(prod)
--             x = string.format("%5d %s", 1, x)
--             send(x)
--         end
--     end)
-- end
-- function consumer(prod)
--     while true do
--         local x = receive(prod)
--         io.write(x, "\n")
--         -- assert(false)
--     end
-- end
-- consumer(filter(producer()))

-- function printResult(a)
--     for i = 1, #a do
--         io.write(a[i], " ")
--     end
--     io.write("\n")
-- end
-- function permgen(a, n)
--     n = n or #a
--     if n <= 1 then
--         coroutine.yield(a)
--     else
--         for i = 1, n do
--             a[n], a[i] = a[i], a[n]
--             permgen(a, n - 1)
--             a[n], a[i] = a[i], a[n]
--         end
--     end
-- end
-- function permutations(a)
--     local co = coroutine.create(function() permgen(a) end)
--     return function()
--         local code, res = coroutine.resume(co)
--         return res
--     end
-- end

-- for p in permutations{1, 2, 3, 4, 5, 6, 7, 8} do
--     printResult(p)
-- end


-- require "socket"
-- host = "www.w3.org"
-- file = "/TR/REC-html32.html"
-- c = assert(socket.connect(host, 80))
-- c:send("GET" .. file .. " HTTP/1.0\r\n\r\n")
-- while true do
--     local s, status, partial = c:receive(2^10)
--     io.write(s or partial)
--     if status == "closed" then break end
-- end
-- c:close()


-- function download(host, file)


--[[
local socket = require("socket")
local host = "www.baidu.com"
local file = "/"
-- 创建一个 TCP 连接，连接到 HTTP 连接的标准端口 -- 80 端口上
local sock = assert(socket.connect(host, 80))
sock:send("GET " .. file .. " HTTP/1.0\r\n\r\n")
repeat
    -- 以 1K 的字节块来接收数据，并把接收到字节块输出来
    local chunk, status, partial = sock:receive(1024)
    print(chunk or partial)
until status ~= "closed"
-- 关闭 TCP 连接
sock:close()
--]]

--[[
local http = require("socket.http")
local response = http.request("http://www.baidu.com/")
print(response)
--]]





-- for_ = coroutine.create(function(arg)
--  print(arg)
--  while true do
--      local index, is_loop_end = coroutine.yield()
--      print(index)
--      if is_loop_end then
--          break
--      end
--  end
-- end)

-- for i = 1, 100 do
--  coroutine.resume(for_, i, i == 100)
-- end

-- for k, v in pairs(coroutine) do
--  print(k, v)
-- end

-- coroutine.wrap(function(arg)
--  print(arg)
--  while true do
--      local index = coroutine.yield()
--      print(index)
--  end
-- end)

-- print("status", coroutine.status(for_))
-- print("resume", coroutine.resume(for_, 1))
-- print("status", coroutine.status(for_))
-- print("resume", coroutine.resume(for_, 2))
-- print("status", coroutine.status(for_))
-- print("resume", coroutine.resume(for_, 1))

local function zip(...)
    local t = {...}
    local val = {}
    local cur_i = 1
    return function()
        if cur_i > #t[1] then return nil end
        for index, v in ipairs(t) do
            val[index] = v[cur_i]
        end
        cur_i = cur_i + 1
        return cur_i - 1, unpack(val)
    end
end

local function kjoin(...)
    local t = {...}
    local val = {}
    local cur_i = 1
    return function()
        -- if cur_i > #t[1] then return nil end
        for k, v in pairs(t) do
            val[index] = v[cur_i]
        end
        cur_i = cur_i + 1
        return cur_i - 1, unpack(val)
    end
end

-- local function cat(...)
--     local t = {...}
--     local ti = 1
--     return function()
--         local len = 0
--         for i, v in ipairs(t) do
--             len = len + #v
--             if ti < len then
--                 ti - len
--             end
--         end
--         return ti, v
--     end
-- end

-- for i, v in pairs({1,2,3,4}) do
--  print(i, v)
-- end

-- for i, v1, v2, v3 in zip({1, 2, 3, 4}, {1,1, 2, 3}, {1, 2, 3, 4}) do
--  print(i, v1, v2, v3)
-- end
local Localize = import("app.utils.Localize")
local m = {
    __add = function(a, b)
        local r = {}
        for _, v in ipairs(a) do
            r[v.type] = v
        end
        for _, v in ipairs(b) do
            local av = r[v.type]
            if av then
                av.count = av.count + v.count
            else
                r[v.type] = v
            end
        end
        local r1 = {}
        for _, v in pairs(r) do
            r1[#r1 + 1] = v
        end
        setmetatable(r1, getmetatable(a))
        return r1
    end,
    __tostring = function(a)
        return table.concat(LuaUtils:table_map(a, function(k, v)
            local txt
            if v.type == "items" then
                txt = string.format("%s x%d", Localize_item.item_name[v.name], v.count)
            elseif v.type == "resources" then
                txt = string.format("%s x%d", Localize.fight_reward[v.name], v.count)
            end
            return k, txt
        end), ",")
    end,
    __concat = function(a, b)
        return string.format("%s%s", tostring(a), tostring(b))
    end,
}
local r = {
    {
        type = "resources",
        name = "wood",
        count = 1000
    }
}
local r2 = {
    {
        type = "resources",
        name = "food",
        count = 1000
    }
}
setmetatable(r, m)
setmetatable(r2, m)
-- print((r + r2).."a")
-- GameUtils:GetSoldierTypeByType("type_")


-- print(string.format("%x", 1))
-- print(string.format("%x", 31))
-- print(string.format("%x", 10))


local BitBaseN = import("app.utils.BitBaseN")


local b = BitBaseN.new(10)
b[1] = true
b[2] = true
b[5] = true
b[6] = true
b[7] = true
b[10] = true
b:decode(b:encode())
assert(b[1] == true)
assert(b[2] == true)
assert(b[5] == true)
assert(b[6] == true)
assert(b[7] == true)
assert(b[10] == true)




local w = 25
function get_index(x, y)
    return x + w * y + 1
end
function get_xy(index)
    return (index - 1) % w, math.floor((index - 1) / w)
end
local bitArr = BitBaseN.new(w * w)
-- bitArr[get_index(0,0)] = true
-- bitArr[bitArr:length()] = true


bitArr[get_index(11, 11)] = true
bitArr[get_index(12, 11)] = true
bitArr[get_index(13, 11)] = true

bitArr[get_index(11, 12)] = true
bitArr[get_index(12, 12)] = true
bitArr[get_index(13, 12)] = true

bitArr[get_index(11, 13)] = true
bitArr[get_index(12, 13)] = true
bitArr[get_index(13, 13)] = true

bitArr[get_index(11, 14)] = true
bitArr[get_index(12, 14)] = true
bitArr[get_index(13, 14)] = true

bitArr[get_index(11, 15)] = true
bitArr[get_index(12, 15)] = true
bitArr[get_index(13, 15)] = true

bitArr:decode(bitArr:encode())
    
assert(bitArr[get_index(11, 11)] == true)
assert(bitArr[get_index(12, 11)] == true)
assert(bitArr[get_index(13, 11)] == true)

assert(bitArr[get_index(11, 12)] == true)
assert(bitArr[get_index(12, 12)] == true)
assert(bitArr[get_index(13, 12)] == true)

assert(bitArr[get_index(11, 13)] == true)
assert(bitArr[get_index(12, 13)] == true)
assert(bitArr[get_index(13, 13)] == true)

assert(bitArr[get_index(11, 14)] == true)
assert(bitArr[get_index(12, 14)] == true)
assert(bitArr[get_index(13, 14)] == true)

assert(bitArr[get_index(11, 15)] == true)
assert(bitArr[get_index(12, 15)] == true)
assert(bitArr[get_index(13, 15)] == true)


-- for i = 1, bitArr:length() do
--     if bitArr[get_index(get_xy(i))] then
--         print(get_index(get_xy(i)), get_xy(i))
--     end
-- end

-- print(bitArr:encode())
-- 11  11  287
-- 11  12  312
-- 11  13  337
-- 12  11  288
-- 12  12  313
-- 12  13  338
-- 13  11  289
-- 13  12  314
-- 13  13  339
-- 11  14  362
-- 12  14  363
-- 13  14  364

-- local function hexToBinary(h)
--     h = string.upper(h)
-- end

-- a = {1,2,3,4,5}
-- b = {6,7,8,9,10}

-- dump({unpack(a), unpack(b)})


m = {}
m.__add = function(...) print("add","+",...) end
m.__sub = function(...) print("sub","-",...) end
m.__mul = function(...) print("mul","*",...) end
m.__div = function(...) print("div","/",...) end
m.__mod = function(...) print("mod","%",...) end
m.__pow = function(...) print("pow","^",...) end
m.__unm = function(...) print("unm","-",...) end
m.__concat = function(...) print("concat","..",...) end
m.__len = function(...) print("len","#",...) end --only func on obj is not string or table
m.__eq = function(...) print("eq","==",...) end
m.__lt = function(...) print("lt","<",...) end
m.__le = function(...) print("le","<=",...) end
m.__index = function(...) print("index",...) end
m.__newindex = function(...) print("newindex",...) end
m.__call = function(...) print("call","()",...) end


o = {1,2}
o2 = {}
setmetatable(o,m)
setmetatable(o2,m)
-- t=o+1
-- t=o-2
-- t=o*3
-- t=o/4
-- t=o%5
-- t=o^6
-- t=-o
-- t=o..8
t=#o --cause o is table,__len not be used
-- t=(o==o2) --must same type and can not be number or string
-- t=(o<o2)
-- t=(o<=o2)
-- t=o[9]
-- o[10] = 10
-- t=o(11)












