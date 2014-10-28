--
-- Author: Danny He
-- Date: 2014-10-28 09:50:45
--
local Game = require("Game")
local property = import("app.utils.property")
local Dragon = import("app.entity.Dragon")

module( "test_dragon", lunit.testcase, package.seeall )

function test_dragon_basic()
  	local dragon = Dragon.new("greenDragon",0,0,0,1,1)
  	assert_equal(dragon:Level(),1)
  	assert_equal(dragon:Star(),1)
  	assert_equal(dragon:Ishated(),true)
  	assert_equal(dragon:GetMaxLevel(),10)
  	assert_equal(dragon:GetEquipmentByCategory(Dragon.EQ_CATEGORY.armguardLeft):Star(),0)
  	assert_equal(dragon:GetEquipmentByCategory(Dragon.EQ_CATEGORY.armguardLeft):IsReachMaxStar(),false)

end