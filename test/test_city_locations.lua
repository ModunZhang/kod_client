local Game = require("Game")
local UpgradeBuilding = import("app.entity.UpgradeBuilding")
local KeepUpgradeBuilding = import("app.entity.KeepUpgradeBuilding")



module( "test_city_locations", lunit.testcase, package.seeall )
local test_city = import("app.entity.City").new().new()
function setup()
    test_city:InitTiles(5, 5, {
        { x = 1, y = 1},
        { x = 1, y = 2},
        { x = 2, y = 1},
        { x = 2, y = 2},
    })
    test_city:InitBuildings({
        KeepUpgradeBuilding.new({ x = 8, y = 8, building_type = "keep", level = 1, w = 9, h = 10 }),
        UpgradeBuilding.new({ x = 16, y = 19, building_type = "warehouse", level = 1, w = 6, h = 6 }),
    })
    test_city:InitDecorators({})
    test_city:GenerateWalls()
end
function test_city_locations()
    -- assert_equal("keep", test_city:GetBuildingByLocationId(1):GetType())
    -- assert_equal(1, test_city:GetLocationIdByBuilding(test_city:GetBuildingByLocationId(1)))

    -- assert_equal("watchTower", test_city:GetBuildingByLocationId(2):GetType())
    -- assert_equal(2, test_city:GetLocationIdByBuilding(test_city:GetBuildingByLocationId(2)))

    assert_equal("warehouse", test_city:GetBuildingByLocationId(3):GetType())
    assert_equal(3, test_city:GetLocationIdByBuilding(test_city:GetBuildingByLocationId(3)))

    -- assert_equal("dragonEyrie", test_city:GetBuildingByLocationId(4):GetType())
    -- assert_equal(4, test_city:GetLocationIdByBuilding(test_city:GetBuildingByLocationId(4)))

    -- assert_equal("toolShop", test_city:GetBuildingByLocationId(5):GetType())
    -- assert_equal(5, test_city:GetLocationIdByBuilding(test_city:GetBuildingByLocationId(5)))

    -- assert_equal("materialDepot", test_city:GetBuildingByLocationId(6):GetType())
    -- assert_equal(6, test_city:GetLocationIdByBuilding(test_city:GetBuildingByLocationId(6)))

    -- assert_equal("armyCamp", test_city:GetBuildingByLocationId(7):GetType())
    -- assert_equal(7, test_city:GetLocationIdByBuilding(test_city:GetBuildingByLocationId(7)))

    -- assert_equal("barracks", test_city:GetBuildingByLocationId(8):GetType())
    -- assert_equal(8, test_city:GetLocationIdByBuilding(test_city:GetBuildingByLocationId(8)))

    -- assert_equal("blackSmith", test_city:GetBuildingByLocationId(9):GetType())
    -- assert_equal(9, test_city:GetLocationIdByBuilding(test_city:GetBuildingByLocationId(9)))

    -- assert_equal("foundry", test_city:GetBuildingByLocationId(10):GetType())
    -- assert_equal(10, test_city:GetLocationIdByBuilding(test_city:GetBuildingByLocationId(10)))

    -- assert_equal("stoneMason", test_city:GetBuildingByLocationId(11):GetType())
    -- assert_equal(11, test_city:GetLocationIdByBuilding(test_city:GetBuildingByLocationId(11)))

    -- assert_equal("lumbermill", test_city:GetBuildingByLocationId(12):GetType())
    -- assert_equal(12, test_city:GetLocationIdByBuilding(test_city:GetBuildingByLocationId(12)))

    -- assert_equal("mill", test_city:GetBuildingByLocationId(13):GetType())
    -- assert_equal(13, test_city:GetLocationIdByBuilding(test_city:GetBuildingByLocationId(13)))

    -- assert_equal("hospital", test_city:GetBuildingByLocationId(14):GetType())
    -- assert_equal(14, test_city:GetLocationIdByBuilding(test_city:GetBuildingByLocationId(14)))

    -- assert_equal("townHall", test_city:GetBuildingByLocationId(15):GetType())
    -- assert_equal(15, test_city:GetLocationIdByBuilding(test_city:GetBuildingByLocationId(15)))

    -- assert_equal("academy", test_city:GetBuildingByLocationId(16):GetType())
    -- assert_equal(16, test_city:GetLocationIdByBuilding(test_city:GetBuildingByLocationId(16)))

    -- assert_equal("materialDepot", test_city:GetBuildingByLocationId(17):GetType())
    -- assert_equal(17, test_city:GetLocationIdByBuilding(test_city:GetBuildingByLocationId(17)))

    -- assert_equal("warehouse", test_city:GetBuildingByLocationId(18):GetType())
    -- assert_equal(18, test_city:GetLocationIdByBuilding(test_city:GetBuildingByLocationId(18)))

    -- assert_equal("tradeGuild", test_city:GetBuildingByLocationId(19):GetType())
    -- assert_equal(19, test_city:GetLocationIdByBuilding(test_city:GetBuildingByLocationId(19)))

    -- assert_equal("armyCamp", test_city:GetBuildingByLocationId(20):GetType())
    -- assert_equal(20, test_city:GetLocationIdByBuilding(test_city:GetBuildingByLocationId(20)))

    -- assert_equal("prison", test_city:GetBuildingByLocationId(21):GetType())
    -- assert_equal(21, test_city:GetLocationIdByBuilding(test_city:GetBuildingByLocationId(21)))

    -- assert_equal("hunterHall", test_city:GetBuildingByLocationId(22):GetType())
    -- assert_equal(22, test_city:GetLocationIdByBuilding(test_city:GetBuildingByLocationId(22)))

    -- assert_equal("trainingGround", test_city:GetBuildingByLocationId(23):GetType())
    -- assert_equal(23, test_city:GetLocationIdByBuilding(test_city:GetBuildingByLocationId(23)))

    -- assert_equal("stable", test_city:GetBuildingByLocationId(24):GetType())
    -- assert_equal(24, test_city:GetLocationIdByBuilding(test_city:GetBuildingByLocationId(24)))

    -- assert_equal("workshop", test_city:GetBuildingByLocationId(25):GetType())
    -- assert_equal(24, test_city:GetLocationIdByBuilding(test_city:GetBuildingByLocationId(25)))
end