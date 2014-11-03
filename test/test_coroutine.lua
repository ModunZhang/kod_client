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

for p in permutations{1, 2, 3, 4, 5, 6, 7, 8, 9} do
    printResult(p)
end










