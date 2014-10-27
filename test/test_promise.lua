local Game = require("Game")
local promise = import("app.utils.promise")
local PENDING = 1
local RESOLVED = 2
module( "test_promise", lunit.testcase, package.seeall )
function tet_promise1()
    assert_equal(PENDING, promise.new():state())
    assert_equal(RESOLVED, promise.new():resolve():state())

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
        end):done(function(...)
        end)
        return pp
    end):next(function(...)
        assert_equal(11, ...)
        return 0
    end):done(function(...)
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
function tst_promise2()
    local p = promise.new(function(...)
        assert_equal("start", ...)
        return 1
    end):next(function(...)
        assert_equal(2, ...)
        return 3
    end):catch(function(...)
        return 2
    end):next(function(...)
        assert_equal(2, ...)
        return 3
    end):next(function(...)
        assert_equal(3, ...)
        return "end"
    end):done(function(...)
        -- dump(...)
    end):resolve("start")
end
function test_promise_all()
    local p = promise.new(function(...)
        assert_equal("start", ...)
        return 1
    end):next(function(...)
        assert_equal(2, ...)
        return 3
    end):catch(function(...)
        return 2
    end):next(function(...)
        assert_equal(2, ...)
        return 3
    end):next(function(...)
        assert_equal(3, ...)
        return "end"
    end):done(function(...)
        -- dump(...)
    end)
    local p1 = promise.new(function(...)
        assert_equal("start", ...)
        return 1
    end):next(function(...)
        assert_equal(2, ...)
        return 3
    end):catch(function(...)
        return 2
    end):next(function(...)
        assert_equal(2, ...)
        return 3
    end):next(function(...)
        assert_equal(3, ...)
        return "end"
    end):done(function(...)
        -- dump(...)
    end)
    promise.all(p, p1):next(function(...)
        dump(...)
    end)

    p:resolve("start")
    p1:resolve("start")
end
































