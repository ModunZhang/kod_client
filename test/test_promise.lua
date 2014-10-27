local Game = require("Game")
local promise = import("app.utils.promise")
local PENDING = 1
local RESOLVED = 2
module( "test_promise", lunit.testcase, package.seeall )
function test_promise1()
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
            assert_equal(11, ...)
        end)
        return pp
    end):next(function(...)
        assert_equal(11, ...)
        return 0
    end):catch(function(...)
        dump(...)
    end)
        :done(function(...)
            assert_equal(0, ...)
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
function test_promise2()
    local p = promise.new(function(...)
        assert_equal("start", ...)
        return 1
    end):next(function(...)
        assert_equal(2, ...)
        return "end"
    end):always(function( ... )
        end):done(function( ... )
        end)
        :fail(function()
            end):catch(function(...)
        return "end"
            end):next(function(...)
        assert_equal("end", ...)
        return "end_"
            end)
        :resolve("start")
end
function test_promise_all()
    local p = promise.new(function(...)
        assert_equal("start", ...)
        return 1
    end):next(function(...)
        assert_equal(1, ...)
        return 2
    end):next(function(...)
        assert_equal(2, ...)
        return 3
    end):next(function(...)
        assert_equal(3, ...)
        return "end"
    end):done(function(...)
        assert_equal("end", ...)
    end)

    local p1 = promise.new(function(...)
        assert_equal("start", ...)
        return 1
    end):next(function(...)
        assert_equal(1, ...)
        return 2
    end):next(function(...)
        assert_equal(2, ...)
        return 3
    end):next(function(...)
        assert_equal(3, ...)
        return "end1"
    end):done(function(...)
        assert_equal("end1", ...)
    end)

    promise.any(p, p1):next(function(...)
        dump(...)
    end):catch(function(err)
        dump(err:reason())
    end)

    p1:resolve("start")
    Game.new():OnUpdate(function(time)
        if time == 10 then
            p:resolve("start")
        end
        return time <= 100
    end)
end

function test_promise_all1()
    promise.new(function(...)
        assert_equal("start", ...)
        return 1
    end):next(function(...)
        assert_equal(1, ...)
        return 2
    end):next(function(...)
        assert_equal(2, ...)
        return 3
    end)
        :next(function(...)
            assert_equal(3, ...)
            pp = promise.new(function(...)
                assert_equal(10, ...)
                return 11
            end):next(function(...)
                assert_equal(11, ...)
                -- promise.reject("你不应该调用这个", 500)
                return 1
            end):done(function(...)
                assert_equal(1, ...)
            end)
            return pp
        end)
        :next(function(...)
            assert_equal(1, ...)
            return 4
        end)
        :catch(function(err)
            print(err:reason())
            return 4
        end)
        :next(function(...)
            assert_equal(4, ...)
            return 5
        end)
        :next(function(...)
            assert_equal(5, ...)
            return "end"
        end)
        :done(function(...)
            assert_equal("end", ...)
        end)
        :resolve("start")
    pp:resolve(10)
end































