local Game = require("Game")
local WarehouseUpgradeBuilding = import("app.entity.WarehouseUpgradeBuilding")
local DragonEyrieUpgradeBuilding = import("app.entity.DragonEyrieUpgradeBuilding")
City = import("app.entity.City").new()




module( "test_warehouse_building", lunit.testcase, package.seeall )
function setup()
    
    City:InitTiles(5, 5, {
        { x = 1, y = 1},
        { x = 1, y = 2},
        { x = 2, y = 1},
        { x = 2, y = 2},
    })
    City:InitBuildings({
        WarehouseUpgradeBuilding.new({ x = 19, y = 19, building_type = "warehouse", level = 1, w = 6, h = 6 }),
        DragonEyrieUpgradeBuilding.new({ x = 9, y = 9, building_type = "dragonEyrie", level = 1, w = 9, h = 10 }),
    })
    -- City:InitLocations({ 
    --     { location_id = 1, building_type = "keep", x = 9, y = 9, w = 10, h = 10 },
    --     { location_id = 2, building_type = "watchTower", x = 3, y = 19, w = 4, h = 4 },
    --     { location_id = 3, building_type = "warehouse", x = 19, y = 19, w = 6, h = 6 },
    --     { location_id = 4, building_type = "dragonEyrie", x = 19, y = 9, w = 10, h = 10 },
    -- })
    City:GenerateWalls()
end


function test_warehouse_building()
    local wood_limit, food_limit, iron_limit, stone_limit = City:GetFirstBuildingByType("warehouse"):GetResourceValueLimit()
    assert_equal(60000, wood_limit)
    assert_equal(60000, food_limit)
    assert_equal(60000, iron_limit)
    assert_equal(60000, stone_limit)

    local flag = true
    City:GetFirstBuildingByType("warehouse"):AddUpgradeListener({
        OnBuildingUpgradingBegin = function(self, building, time)
            print("begin", building:GetType(), time)
            assert_equal(1, time)
            assert_equal(1, building.level)
        end,
        OnBuildingUpgrading = function(self, building, time)
            
        end,
        OnBuildingUpgradeFinished = function(self, building, time)
            print("finished", building:GetType(), time)
            assert_equal(2, building.level)
            flag = false
        end
    })
    Game.new():OnUpdate(function(time)
        City:OnTimer(time)
        if time == 1 then
            City:GetFirstBuildingByType("warehouse"):UpgradeByCurrentTime(time)
        end
        return flag
    end)
    local wood_limit, food_limit, iron_limit, stone_limit = City:GetFirstBuildingByType("warehouse"):GetResourceValueLimit()
    assert_equal(120000, wood_limit)
    assert_equal(120000, food_limit)
    assert_equal(120000, iron_limit)
    assert_equal(120000, stone_limit)
end


