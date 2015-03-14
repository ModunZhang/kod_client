local Game = require("Game")
local Resource = import("app.entity.Resource")
local AutomaticUpdateResource = import("app.entity.AutomaticUpdateResource")
local WoodResourceUpgradeBuilding = import("app.entity.WoodResourceUpgradeBuilding")
local PopulationResourceUpgradeBuilding = import("app.entity.PopulationResourceUpgradeBuilding")
local WarehouseUpgradeBuilding = import("app.entity.WarehouseUpgradeBuilding")
local DragonEyrieUpgradeBuilding = import("app.entity.DragonEyrieUpgradeBuilding")
City = import("app.entity.City").new()


module( "test_resource", lunit.testcase, package.seeall )
function test_resource()
    local resource = Resource.new()

    assert_equal(0, resource:GetValueLimit())
    resource:SetValueLimit(100)
    assert_equal(100, resource:GetValueLimit())

    assert_equal(0, resource:GetValue())
    resource:SetValue(100)
    assert_equal(100, resource:GetValue())

    resource:SetValue(200)
    assert_equal(200, resource:GetValue())

    assert_true(resource:IsOverLimit())
end

function test_automaticupdateresource()
    local automaticUpdateResource = AutomaticUpdateResource.new()
    automaticUpdateResource:SetProductionPerHour(0, 3600)
    automaticUpdateResource:SetValueLimit(5)
    Game.new():OnUpdate(function(time)
        if time == 1 then
        	-- automaticUpdateResource:AddResourceByCurrentTime(time, 2)
        	assert_equal(1, automaticUpdateResource:GetResourceValueByCurrentTime(time))
        end
        if time == 2 then
        	-- automaticUpdateResource:ReduceResourceByCurrentTime(time, 1)
        	assert_equal(2, automaticUpdateResource:GetResourceValueByCurrentTime(time))
        	
        end
        if time >= 10 and time < 20 then
            if time == 10 then
            	assert_equal(5, automaticUpdateResource:GetResourceValueByCurrentTime(time))
                automaticUpdateResource:SetValueLimit(10)
                automaticUpdateResource:SetProductionPerHour(time, 7200)
            elseif time == 15 then
            	-- automaticUpdateResource:UpdateResource(time, 20)
            	-- automaticUpdateResource:SetValueLimit(40)
            	automaticUpdateResource:ReduceResourceByCurrentTime(time, 5)
            	assert_equal(5, automaticUpdateResource:GetResourceValueByCurrentTime(time))
            end
        end
        -- print(automaticUpdateResource:GetResourceValueByCurrentTime(time))
        return time ~= 20
    end)
end


module( "test_resource_manager", lunit.testcase, package.seeall )
function setup()
    test_city = City.new()
    test_city:InitTiles(5, 5, {
        { x = 1, y = 1},
        { x = 1, y = 2},
        { x = 2, y = 1},
        { x = 2, y = 2},
    })
    test_city:InitBuildings({
        WarehouseUpgradeBuilding.new({ x = 9, y = 9, building_type = "warehouse", level = 1, w = 9, h = 10 }),
        DragonEyrieUpgradeBuilding.new({ x = 9, y = 9, building_type = "dragonEyrie", level = 1, w = 9, h = 10 }),
        })
    test_city:GenerateWalls()
end
function test_resource_manager()
    local decorator_building = PopulationResourceUpgradeBuilding.new({ x = 12, y = 12, building_type = "dwelling", level = 1, w = 10, h = 10})
    test_city:CreateDecorator(1, decorator_building)
end



module( "test_resource_wood", lunit.testcase, package.seeall )
function setup()
    test_city = City.new()
    test_city:InitTiles(5, 5, {
        { x = 1, y = 1},
        { x = 1, y = 2},
        { x = 2, y = 1},
        { x = 2, y = 2},
    })
    test_city:InitBuildings({
        WarehouseUpgradeBuilding.new({ x = 9, y = 9, building_type = "warehouse", level = 1, w = 9, h = 10 }),
        DragonEyrieUpgradeBuilding.new({ x = 9, y = 9, building_type = "dragonEyrie", level = 1, w = 9, h = 10 }),
        })
end
function test_resource_wood()
    local decorator_building = WoodResourceUpgradeBuilding.new({ x = 12, y = 12, building_type = "woodcutter", level = 1, w = 10, h = 10})
    test_city:CreateDecorator(1, decorator_building)

    Game.new():OnUpdate(function(time)
        test_city:OnTimer(time)

        return false
    end)
end





