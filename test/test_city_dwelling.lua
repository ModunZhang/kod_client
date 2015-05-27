local Game = require("Game")
local WarehouseUpgradeBuilding = import("app.entity.WarehouseUpgradeBuilding")
local DragonEyrieUpgradeBuilding = import("app.entity.DragonEyrieUpgradeBuilding")
local City = import("app.entity.City").new()


module( "test_build_dwelling", lunit.testcase, package.seeall )
local PopulationResourceUpgradeBuilding = import("app.entity.PopulationResourceUpgradeBuilding")
function setup()
    City:InitTiles(5, 5, {
        { x = 1, y = 1},
        { x = 1, y = 2},
        { x = 2, y = 1},
        { x = 2, y = 2},
    })
    City:InitBuildings({
        WarehouseUpgradeBuilding.new({ x = 9, y = 9, building_type = "warehouse", level = 1, w = 9, h = 10 }),
        DragonEyrieUpgradeBuilding.new({ x = 9, y = 9, building_type = "dragonEyrie", level = 1, w = 9, h = 10 }),
    })
    City:InitDecorators({})
    City:ClearAllListener()
    City:GenerateWalls()
end
function test_build_dwelling()

    Game.new():OnUpdate(function(time)
        City:OnTimer(time)
        if time == 1 then
            local population_resource = City:GetResourceManager():GetCitizenResource()
            population_resource:UpdateResource(time, 0)
            population_resource:SetValueLimit(10000)

            assert_equal(0, population_resource:GetResourceValueByCurrentTime(time))

            -- assert_equal(5, City:GetDwellingCounts())

            local decorator_building = PopulationResourceUpgradeBuilding.new({
                x = 12, y = 12, building_type = "dwelling", level = 1, w = 10, h = 10
            })

            assert_equal(300, decorator_building:GetProductionPerHour())

            City:CreateDecorator(time, decorator_building)

            assert_equal(0, population_resource:GetProductionPerHour())

            assert_equal(0, population_resource:GetResourceValueByCurrentTime(time))

            -- assert_equal(4, City:GetDwellingCounts())
        elseif time == 2 then
        -- assert_equal(0.5, population_resource:GetResourceValueByCurrentTime(time))
        end


        -- local decorator_building = PopulationResourceUpgradeBuilding.new({ x = 9, y = 9, building_type = "dwelling", level = 1, w = 10, h = 10, orient = Orient.Y})

        -- City:CreateDecorator(time, decorator_building)

        -- City:DestoryDecoratorByPosition(time, 9, 9)

        -- assert_equal(0, decorator_building:GetProductionPerHour())
        return time ~= 100
    end, 0.001)
end
