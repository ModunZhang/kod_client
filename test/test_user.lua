local Game = require("Game")
local User = import("app.entity.User")

module( "test_user", lunit.testcase, package.seeall )
function test_user1()
    local user = User.new()
    user:AddListenOnType({
        OnRequestAllianceEvents = function(this, user, changed_map)
            dump(changed_map)
        end
    }, User.LISTEN_TYPE.REQUEST_TO_ALLIANCE)
    user:AddRequestEventWithNotify(User:CreateRequestEvent(0))
    user:DeleteRequestWithNotify(User:CreateRequestEvent(0))
end

