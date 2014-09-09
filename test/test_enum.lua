local Game = require("Game")
local Enum = import("app.utils.Enum")



module( "test_enum", lunit.testcase, package.seeall )

-- function ENUM(...)
-- 	local enum = {}
-- 	for i, v in pairs({...}) do
-- 		enum[v] = i
-- 	end
-- 	return enum
-- end

function test_enum()
    local enum = Enum("ENUM1", "ENUM2", "ENUM3", "ENUM4")
    assert_equal(1, enum.ENUM1)
    assert_equal(2, enum.ENUM2)
    assert_equal(3, enum.ENUM3)
    assert_equal(4, enum.ENUM4)
end

