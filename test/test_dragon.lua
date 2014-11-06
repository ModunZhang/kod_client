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
function setup()
    test_city = City.new()
    test_city:InitTiles(5, 5, {
        { x = 1, y = 1},
        { x = 1, y = 2},
        { x = 2, y = 1},
        { x = 2, y = 2},
    })
    test_city:InitDecorators({})
    test_city:InitBuildings({
        DragonEyrieUpgradeBuilding.new({ x = 9, y = 9, building_type = "dragonEyrie", level = 1, w = 9, h = 10 }),
    })
	dragon_manager = test_city:GetFirstBuildingByType("dragonEyrie"):GetDragonManager()
	assert_equal(dragon_manager~=nil,true)
   	local dragon = Dragon.new("greenDragon",0,100,"idea",1,1) -- drag_type,strength,vitality,status,star,level
  	assert_equal(dragon:Level(),1)
  	assert_equal(dragon:Star(),1)
  	assert_equal(dragon:Ishated(),true)
  	assert_equal(dragon:GetMaxLevel(),10)
  	assert_equal(dragon:GetEquipmentByBody(Dragon.EQ_CATEGORY.armguardLeft):Star(),0)
  	assert_equal(dragon:GetEquipmentByBody(Dragon.EQ_CATEGORY.armguardLeft):IsReachMaxStar(),false)
  	dragon_manager:AddDragon(dragon)
end

function test_dragon_basic()
  	assert_equal(dragon_manager:GetDragon("greenDragon"):Type(),"greenDragon")
end

function test_dragon_vitality()
	local dragon = dragon_manager:GetDragon("greenDragon")
	assert_equal(dragon:Type(),"greenDragon")

	

	Game.new():OnUpdate(function(time)
        test_city:OnTimer(time)
        if time == 1000 then
			local resource = dragon_manager:AddVitalityResource(dragon:Type())
        	resource:UpdateResource(time,dragon:Vitality())
        	resource:SetProductionPerHour(time,test_city:GetFirstBuildingByType("dragonEyrie"):GetVitalityRecoveryPerHour())
            resource:SetValueLimit(dragon:GetMaxVitality())
            print(test_city:GetFirstBuildingByType("dragonEyrie"):GetVitalityRecoveryPerHour())
            print(resource:GetReallyTotalResource())
            print(resource:GetResourceValueByCurrentTime(time))
        end
       	if time == 1000*5 then
       		return false
       	end
        return true
    end)
end