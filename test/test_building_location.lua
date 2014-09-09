local Game = require("Game")
local City = import("app.entity.City")

module( "test_location", lunit.testcase, package.seeall )
function setup()
	test_city = City.new()
    test_city:InitTiles(5, 5, {
        { x = 1, y = 1},
        { x = 1, y = 2},
        { x = 2, y = 1},
        { x = 2, y = 2},
    })
    test_city:InitDecorators({})
end

function test_building_location()
    assert_equal(1, test_city:GetTileByIndex(2, 2):GetBuildingLocationByRelativePos(2, 2))
    assert_equal(2, test_city:GetTileByIndex(2, 2):GetBuildingLocationByRelativePos(5, 2))
    assert_equal(3, test_city:GetTileByIndex(2, 2):GetBuildingLocationByRelativePos(8, 2))

    local rx, ry = test_city:GetTileByIndex(2, 2):GetRelativePositionByLocation(1)
    assert_equal(2, rx)
    assert_equal(2, ry)

    local ax, ay = test_city:GetTileByIndex(2, 2):GetAbsolutePositionByLocation(3)
    assert_equal(18, ax)
    assert_equal(12, ay)
end
