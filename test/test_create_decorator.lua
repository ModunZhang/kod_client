local Game = require("Game")
local Building = import("app.entity.Building")
local UpgradeBuilding = import("app.entity.UpgradeBuilding")
local WarehouseUpgradeBuilding = import("app.entity.WarehouseUpgradeBuilding")
local DragonEyrieUpgradeBuilding = import("app.entity.DragonEyrieUpgradeBuilding")
test_city = import("app.entity.City").new()

module( "test_decorator", lunit.testcase, package.seeall )
function setup()
	test_city:InitTiles(5, 5, {})
	test_city:InitBuildings({
        WarehouseUpgradeBuilding.new({ x = 9, y = 9, building_type = "warehouse", level = 1, w = 9, h = 10 }),
        DragonEyrieUpgradeBuilding.new({ x = 9, y = 9, building_type = "dragonEyrie", level = 1, w = 9, h = 10 }),
        })
    test_city:InitDecorators({})
    test_city:ClearAllListener()
end
function test_decorator()
    test_city:AddListenOnType({
        OnOccupyRuins = function(self, ruins)
            assert_equal(1, #ruins)
            assert_equal(12, ruins[1].x)
            assert_equal(12, ruins[1].y)
        end},
    test_city.LISTEN_TYPE.OCCUPY_RUINS)

    test_city:AddListenOnType({
        OnDestoryDecorator = function(self, destory_decorator, ruins)
            assert_equal(1, #ruins)
        end},
    test_city.LISTEN_TYPE.DESTROY_DECORATOR)

    test_city:AddListenOnType({
        OnCreateDecorator = function(self, decorator_building)
            assert(decorator_building:GetType() == "decorator_1")
        end},
    test_city.LISTEN_TYPE.CREATE_DECORATOR)

    test_city:CreateDecorator(1, UpgradeBuilding.new({ x = 12, y = 12, building_type = "decorator_1", level = 1, w = 3, h = 3 }))
    test_city:DestoryDecoratorByPosition(1, 12, 12)

    assert_equal(1, #test_city:GetNeighbourRuinWithSpecificRuin(Building.new({ x = 12, y = 12, building_type = "ruins", w = 3, h = 3})))
    assert_equal(0, #test_city:GetNeighbourRuinWithSpecificRuin(Building.new({ x = 16, y = 12, building_type = "ruins", w = 3, h = 3})))
end






