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

function printResult(a)
    for i = 1, #a do
        io.write(a[i], " ")
    end
    io.write("\n")
end
function permgen(a, n)
    n = n or #a
    if n <= 1 then
        coroutine.yield(a)
    else
        for i = 1, n do
            a[n], a[i] = a[i], a[n]
            permgen(a, n - 1)
            a[n], a[i] = a[i], a[n]
        end
    end
end
function permutations(a)
    local co = coroutine.create(function() permgen(a) end)
    return function()
        local code, res = coroutine.resume(co)
        return res
    end
end

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

-- local socket = require("socket")
-- local host = "www.baidu.com"
-- local file = "/"
-- -- 创建一个 TCP 连接，连接到 HTTP 连接的标准端口 -- 80 端口上
-- local sock = assert(socket.connect(host, 80))
-- sock:send("GET " .. file .. " HTTP/1.0\r\n\r\n")
-- repeat
--     -- 以 1K 的字节块来接收数据，并把接收到字节块输出来
--     local chunk, status, partial = sock:receive(1024)
--     print(chunk or partial)
-- until status ~= "closed"
-- -- 关闭 TCP 连接
-- sock:close()

local http = require("socket.http")
local response = http.request("http://www.baidu.com/")
print(response)



