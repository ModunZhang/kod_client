local Game = require("Game")
local Orient = import("app.entity.Orient")
local UpgradeBuilding = import("app.entity.UpgradeBuilding")
local KeepUpgradeBuilding = import("app.entity.KeepUpgradeBuilding")
local City = import("app.entity.City").new()


module( "test_orient", lunit.testcase, package.seeall )
function setup()
    City:InitBuildings({
        KeepUpgradeBuilding.new({ x = 9, y = 9, building_type = "keep", level = 1, w = 10, h = 1 }),
    })
    City:InitDecorators({})
end

function test_orient()
    assert_true(City:GetFirstBuildingByType("keep"):GetOrient() == Orient.X)
    assert_true(City:GetFirstBuildingByType("keep").w == 10)
    assert_true(City:GetFirstBuildingByType("keep").h == 1)
    City:GetFirstBuildingByType("keep"):SetOrient(Orient.Y)
    assert_true(City:GetFirstBuildingByType("keep"):GetOrient() == Orient.Y)
    assert_true(City:GetFirstBuildingByType("keep").w == 1)
    assert_true(City:GetFirstBuildingByType("keep").h == 10)
    City:GetFirstBuildingByType("keep"):SetOrient(Orient.X)
    assert_true(City:GetFirstBuildingByType("keep"):GetOrient() == Orient.X)
    assert_true(City:GetFirstBuildingByType("keep").w == 10)
    assert_true(City:GetFirstBuildingByType("keep").h == 1)
end