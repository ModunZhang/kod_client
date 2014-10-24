local Game = require("Game")
local promise = import("app.utils.promise")

module( "test_promise", lunit.testcase, package.seeall )
function test_promise1()
    assert_equal("pending", promise.new():state())
    assert_equal("resolved", promise.new():resolve():state())

    local pp

    local p = promise.new(function(...)
        assert_equal(1, ...)
        return 2
    end)
    p:next(function(...)
        assert_equal(2, ...)
        return 3
    end):next(function(...)
        assert_equal(3, ...)
        pp = promise.new(function(...)
        	assert_equal(10, ...)
        	return 11
        end)
        return pp
    end):next(function(...)
    	assert_equal(11, ...)
    end)
    Game.new():OnUpdate(function(time)
        if time == 10 then
            p:resolve(1)
        elseif time == 20 then
        	pp:resolve(10)
        end
        return time <= 100
    end)

end
function test_promise()
-- local p = promise.new(function(...)
--     print(...)
--     return 1
-- end)
-- p:next(function(...)
--     print(...)
--     return 2
-- end):next(function(...)
--     print(...)
--     return 3
-- end):next(function(...)
--     print(...)
--     print("end")
-- end)
-- p:resolve("start")
-- dump(p)
end





















