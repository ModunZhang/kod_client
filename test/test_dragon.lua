--
-- Author: Danny He
-- Date: 2014-10-28 09:50:45
--
local Game = require("Game")
local property = import("app.utils.property")
local Dragon = import("app.entity.Dragon")
local DragonEyrieUpgradeBuilding = import("app.entity.DragonEyrieUpgradeBuilding")
local City = import("app.entity.City")




module( "test_dragon", lunit.testcase, package.seeall )

function test1( ... )
  print(string.utf8len("你好"))
  print(string.utf8len("ab"))
  print(string.utf8len("12"))
end