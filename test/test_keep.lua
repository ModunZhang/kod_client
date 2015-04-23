local Game = require("Game")
local KeepUpgradeBuilding = import("app.entity.KeepUpgradeBuilding")
local WarehouseUpgradeBuilding = import("app.entity.WarehouseUpgradeBuilding")
local DragonEyrieUpgradeBuilding = import("app.entity.DragonEyrieUpgradeBuilding")
test_city = import("app.entity.City").new()




module( "test_keep_building", lunit.testcase, package.seeall )
function setup()
    City = test_city.new()
    City:InitTiles(5, 5, {
        { x = 1, y = 1},
        { x = 1, y = 2},
        { x = 2, y = 1},
        { x = 2, y = 2},
    })
    City:InitBuildings({
        KeepUpgradeBuilding.new({ x = 9, y = 9, building_type = "keep", level = 1, w = 9, h = 10 }),
        WarehouseUpgradeBuilding.new({ x = 9, y = 9, building_type = "warehouse", level = 1, w = 9, h = 10 }),
        DragonEyrieUpgradeBuilding.new({ x = 9, y = 9, building_type = "dragonEyrie", level = 1, w = 9, h = 10 }),
    })
    City:GenerateWalls()
end


function test_keep_building()
    assert_equal(4, City:GetFirstBuildingByType("keep"):GetUnlockPoint())

    -- success, ret_code = City:UnlockTilesByIndex(1, 3)
    -- assert_equal(false, success)
    -- assert_equal(City.RETURN_CODE.HAS_NO_UNLOCK_POINT, ret_code)

    local flag = true
    City:GetFirstBuildingByType("keep"):AddUpgradeListener({
        OnBuildingUpgradingBegin = function(self, building, time)
            print("begin", building:GetType(), time)
            assert_equal(1, time)
            assert_equal(1, building:GetLevel())
        end,
        OnBuildingUpgrading = function(self, building, time)

        end,
        OnBuildingUpgradeFinished = function(self, building, time)
            print("finished", building:GetType(), time)
            assert_equal(2, building:GetLevel())
            assert_equal(5, City:GetFirstBuildingByType("keep"):GetUnlockPoint())
            flag = false
        end
    })
    Game.new():OnUpdate(function(time)
        City:OnTimer(time)
        if time == 1 then
            City:GetFirstBuildingByType("keep"):UpgradeByCurrentTime(time)
        end
        return flag
    end)
    
    -- success, ret_code = City:UnlockTilesByIndex(1, 3)
    -- assert_equal(false, success)
    -- assert_equal(City.RETURN_CODE.HAS_NO_UNLOCK_POINT, ret_code)
end


