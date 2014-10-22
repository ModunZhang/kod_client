local Game = require("Game")
local Promise = class("Promise")
function Promise:ctor(resolver)
    self.state = "pending"
    self.resolver = resolver == nil and function(...) return ... end or resolver
    self.thens = {}
end
function Promise:Then(next_promise)
    table.insert(self.thens, next_promise)
    return self
end
function Promise:Resolve(value)
    if self.state == "resolved" then
        assert(false, "不能重复解决问题!:Promise:Resolve")
    end
    self.state = "resolved"
    self.result = self.resolver(value)
    return self
end

module( "test_promise", lunit.testcase, package.seeall )
function test_promise()
    Promise.new(function(data)
        print(data)
        return 1
    end):Then(function(data)
        print(data)
        return 2
    end):Then(function(data)
        print(data)
        return 3
    end):Resolve("start")
end




