local Game = require("Game")



module( "test_coroutine", lunit.testcase, package.seeall )

function test_coroutine()
    local co = coroutine.create(function() print("hello") end)
    print(coroutine.resume(co))
    print(coroutine.resume(co))
    print(coroutine.status(co))

    print("===")
   	co = coroutine.create(function(f) 
   		print(f)
   		for i = 1, 10 do
   			-- print("co", i)
   			print(coroutine.yield(i))
   		end
   		return 111
   	end)

   	print(coroutine.running())

   	-- print(coroutine.resume(co, 3))
    -- -- print(coroutine.status(co))
   	-- print(coroutine.resume(co, 2))
    -- -- print(coroutine.status(co))
   	-- print(coroutine.resume(co, 1))
   	-- print(coroutine.resume(co, 1))
   	-- print(coroutine.resume(co, 1))
   	-- print(coroutine.resume(co, 1))
   	-- print(coroutine.resume(co, 1))
   	-- print(coroutine.resume(co, 1))
   	-- print(coroutine.resume(co, 1))
   	-- print(coroutine.resume(co, 1))
   	-- print(coroutine.resume(co, 1))
   	-- print(coroutine.resume(co, 1))
    -- print(coroutine.status(co))

    for k, v in pairs(coroutine) do
    	print(k, v)
    end



end

