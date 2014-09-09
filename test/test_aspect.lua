local Game = require("Game")
local Observer = import("app.entity.Observer")
module( "test_aspect", lunit.testcase, package.seeall )
function setup()
    
end

a = {
	
	func_a = function(self)
		print("hello")
	end

}


function test_aspect()
	for k, v in pairs(Observer.new()) do
        print(k, v)
    end
end