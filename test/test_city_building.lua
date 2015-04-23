local Game = require("Game")
local KeepUpgradeBuilding = import("app.entity.KeepUpgradeBuilding")
local WarehouseUpgradeBuilding = import("app.entity.WarehouseUpgradeBuilding")
local DragonEyrieUpgradeBuilding = import("app.entity.DragonEyrieUpgradeBuilding")
local City = import("app.entity.City")

module( "test_city_building", lunit.testcase, package.seeall )
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
        KeepUpgradeBuilding.new({ x = 9, y = 9, building_type = "keep", level = 1, w = 9, h = 10 }),
        WarehouseUpgradeBuilding.new({ x = 9, y = 9, building_type = "warehouse", level = 1, w = 9, h = 10 }),
        DragonEyrieUpgradeBuilding.new({ x = 9, y = 9, building_type = "dragonEyrie", level = 1, w = 9, h = 10 }),
    })
    test_city:GenerateWalls()
end

function test_city_building()
    test_city:AddListenOnType({
        OnUpgradingBegin = function(self, building)
            print("OnUpgradingBegin", building:GetType())
        end,
        OnUpgrading = function(self, building)
            print("OnUpgrading", building:GetType())
        end,
        OnUpgradingFinished = function(self, building)
            print("OnUpgradingFinished", building:GetType())
        end}, City.LISTEN_TYPE.UPGRADE_BUILDING)

    local flag = true
    test_city:GetFirstBuildingByType("keep"):AddUpgradeListener({
        OnBuildingUpgradingBegin = function(self, building, time)
            assert_equal(1, time)
            assert_equal(1, building:GetLevel())
        end,
        OnBuildingUpgrading = function(self, building, time)
        end,
        OnBuildingUpgradeFinished = function(self, building, time)
            assert_equal(2, building:GetLevel())
            assert_equal(5, test_city:GetFirstBuildingByType("keep"):GetUnlockPoint())
            flag = false
        end
    })
    Game.new():OnUpdate(function(time)
        test_city:OnTimer(time)
        if time == 1 then
            test_city:GetFirstBuildingByType("keep"):UpgradeByCurrentTime(time)
        end
        return flag
    end)
end
