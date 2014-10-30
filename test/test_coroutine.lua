
function send(x)
    coroutine.yield(x)
end
function receive(producer)
    local status, value = coroutine.resume(producer)
    return value
end

function producer()
    return coroutine.create(function()
        while true do
            local x = io.read()
            send(x)
        end
    end)
end

function consumer(producer)
    while true do
        local x = receive(producer)
        io.write(x, "\n")
    end
end

function filter(producer)
    return coroutine.create(function()
        while true do
            local x = receive(producer)
            x = string.format("%5 %s", 1, x)
            send(x)
        end
    end) 
end

consumer(filter(producer()))

-- producer = coroutine.create(function()
--     while true do
--         local x = io.read()
--         print("receive", x)
--         send(x)
--     end
-- end)


-- receive()
-- receive()





