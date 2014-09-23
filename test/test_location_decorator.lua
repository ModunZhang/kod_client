local Game = require("Game")
local UpgradeBuilding = import("app.entity.UpgradeBuilding")
local WarehouseUpgradeBuilding = import("app.entity.WarehouseUpgradeBuilding")
local DragonEyrieUpgradeBuilding = import("app.entity.DragonEyrieUpgradeBuilding")
test_city = import("app.entity.City").new()


module( "test_location_decorator", lunit.testcase, package.seeall )
function setup()
	test_city:InitTiles(5, 5, {})
	test_city:InitBuildings({
        WarehouseUpgradeBuilding.new({ x = 9, y = 9, building_type = "warehouse", level = 1, w = 9, h = 10 }),
        DragonEyrieUpgradeBuilding.new({ x = 9, y = 9, building_type = "dragonEyrie", level = 1, w = 9, h = 10 }),
        })
    test_city:InitDecorators({})
    test_city:ClearAllListener()
end
function createDecoratorUpgradeBuilding(x, y, building_type)
    local decorator_building = UpgradeBuilding.new({
        x = x, y = y,
        w = 3, h = 3,
        building_type = building_type,
        level = 1
    })
    return decorator_building
end
function test_building_location()
    test_city:CreateDecorator(1, createDecoratorUpgradeBuilding(12, 12, "miner"))
    assert_equal("miner", test_city:GetDecoratorsByLocationId(3)[1]:GetType())

    test_city:CreateDecorator(1, createDecoratorUpgradeBuilding(15, 12, "woodcutter"))
    assert_equal("woodcutter", test_city:GetDecoratorsByLocationId(3)[2]:GetType())

    test_city:CreateDecorator(1, createDecoratorUpgradeBuilding(18, 12, "dwelling"))
    assert_equal("dwelling", test_city:GetDecoratorsByLocationId(3)[3]:GetType())

end







