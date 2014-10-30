local Game = require("Game")
local promise = import("app.utils.promise")
local PENDING = 1
local RESOLVED = 2
module( "test_promise", lunit.testcase, package.seeall )
-- function test_promise1()
--     assert_equal(PENDING, promise.new():state())
--     assert_equal(RESOLVED, promise.new():resolve():state())

--     local pp
--     local p = promise.new(function(...)
--         assert_equal(1, ...)
--         return 2
--     end)
--     p:next(function(...)
--         assert_equal(2, ...)
--         return 3
--     end):next(function(...)
--         assert_equal(3, ...)
--         pp = promise.new(function(...)
--             assert_equal(10, ...)
--             return 11
--         end):done(function(...)
--             assert_equal(11, ...)
--         end)
--         return pp
--     end):next(function(...)
--         assert_equal(11, ...)
--         return 0
--     end):catch(function(...)
--         -- dump(...)
--         end)
--         :done(function(...)
--             assert_equal(0, ...)
--         end)
--     Game.new():OnUpdate(function(time)
--         if time == 10 then
--             p:resolve(1)
--         elseif time == 20 then
--             pp:resolve(10)
--         end
--         return time <= 100
--     end)
-- end



-- function test_promise2()
--     local p = promise.new(function(...)
--         assert_equal("start", ...)
--         return 1
--     end):next(function(...)
--         promise.reject("hell!!!")
--         assert_equal(2, ...)
--         return "end"
--     end):catch(function(err)
--         -- print(err:reason())
--         return "end"
--     end):next(function(...)
--         -- print("hello")
--         assert_equal("end", ...)
--         return "end_"
--     end):resolve("start")
-- end


-- function test_promise3()
--     local p = promise.new(function(...)
--         assert_equal("start", ...)
--         return 11
--     end)
--         :next(function(...)
--             assert_equal(11, ...)
--             return 22
--         end)
--         :next(function(...)
--             assert_equal(22, ...)
--             return 33
--         end):next(function(...)
--         assert_equal(33, ...)
--         return "end"
--         end):done(function(...)
--         assert_equal("end", ...)
--         end)

--     local p1 = promise.new(function(...)
--         assert_equal("aaa", ...)
--         return 1
--     end):next(function(...)
--         assert_equal(1, ...)
--         return 2
--     end):next(function(...)
--         assert_equal(2, ...)
--         return 3
--     end):next(function(...)
--         assert_equal(445, ...)
--         return "end1222"
--     end):done(function(...)
--         print("hello")
--         assert_equal("end1", ...)
--     end)

--     local p3 = promise.any(p, p1)
--         :next(function(results)
--             dump(results)
--         end):catch(function(err)
--         dump(err:reason())
--         end)

--     Game.new():OnUpdate(function(time)
--         if time == 10 then
--             p:resolve("start")
--         elseif time == 19 then
--             p1:resolve("aaa")
--         end
--         return time <= 100
--     end)
-- end

-- function test_promise4()
--     local pp
--     promise.new(function(...)
--         assert_equal("start", ...)
--         return 1
--     end):next(function(...)
--         assert_equal(1, ...)
--         return 2
--     end):next(function(...)
--         assert_equal(2, ...)
--         return 3
--     end):next(function(...)
--         assert_equal(3, ...)
--         pp = promise.new(function(...)
--             assert_equal(10, ...)
--             return 11
--         end):next(function(...)
--             assert_equal(11, ...)
--             promise.reject("你不应该调用这个", 500)
--             return 1
--         end):done(function(...)
--             assert_equal(1, ...)
--         end):fail(function()
--             -- print("hello11111")
--             end)
--         return pp
--     end):next(function(...)
--         assert_equal(1, ...)
--         return 4
--     end):catch(function(err)
--         promise.reject("你不应该调用这个222", 200)
--     end):catch(function(err)
--         return 4
--     end):next(function(...)
--         assert_equal(4, ...)
--         return 5
--     end):catch(function(err)
--         dump(err:reason())
--         return 5
--     end):next(function(...)
--         assert_equal(5, ...)
--         return "end"
--     end):done(function(...)
--         assert_equal("end", ...)
--     end):fail(function()
--         end)
--         :resolve("start")
--     pp:resolve(10)
-- end



-- function test_promise5()
--     local pp
--     local ppp
--     local p = promise.new(function(...)
--         return 1
--     end):next(function(...)
--         assert_equal(1, ...)
--         pp = promise.new(function(...)
--             assert_equal("s", ...)
--             return "return"
--         end):next(function(...)
--             assert_equal("return", ...)
--             ppp = promise.new(function(...)
--                 return 3
--             end):next(function(...)
--                 assert_equal(3, ...)
--                 promise.reject("nononononono")
--                 return "return 2"
--             end):done(function(...)
--                 print("done", ...)
--             end)
--             return ppp
--         end):fail(function()

--             end)
--         return pp
--     end):next(function(...)
--         assert_equal(111, ...)
--     end):catch(function(err)
--         -- print("catch222")
--         -- dump(err:reason())
--         promise.reject("sb")
--     end):catch(function(err)
--         -- dump(err:reason())
--         -- print("catch333")
--         end):next(function(...)
--         assert_equal(nil, ...)
--         return 1
--         end):done(function(...)
--         print("done---", ...)
--         end):fail(function()
--         -- print("fail")
--         end):resolve("start")

--     pp:resolve("s")
--     ppp:resolve("data")
-- end




function test_promise6()
    local p1 = promise.new(function(...)
        promise.reject("cuowu")
        return 1
    end)
    local p2 = promise.new(function(...)
        return 2
    end)



    promise.all(promise.any(promise.all(promise.any(p1, p2):next(function(...)
        print(...)
        return "any"
    end)):catch(function(err)
        dump(err:reason())
    end))):next(function()
    print("haha")
    end)




    Game.new():OnUpdate(function(time)
        if time == 10 then
            p1:resolve(1)
        elseif time == 19 then
            p2:resolve(2)
        end
        return time <= 100
    end)
end





































