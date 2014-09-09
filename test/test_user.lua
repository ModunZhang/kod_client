local Game = require("Game")
local User = import("app.entity.User").new()

module( "test_user", lunit.testcase, package.seeall )
function setup()
    
end


function test_user_gem()
    User:AddListenOnType({
        OnGemChanged = function(self, old_gem, new_gem)
            assert_equal(0, old_gem)
            assert_equal(100, new_gem)

        end},
    User.LISTEN_TYPE.GEM_CHANGED)
    User:SetGem(100)
end
