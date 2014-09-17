local Game = require("Game")
local ToolShopUpgradeBuilding = import("app.entity.ToolShopUpgradeBuilding")

City = import("app.entity.City").new()
module( "test_toolShop", lunit.testcase, package.seeall )
function setup()
    City:InitTiles(5, 5, {
        { x = 1, y = 1},
        { x = 1, y = 2},
        { x = 2, y = 1},
        { x = 2, y = 2},
    })
    City:InitBuildings({
        ToolShopUpgradeBuilding.new({ x = 19, y = 19, building_type = "toolShop", level = 1, w = 6, h = 6 }),
    })
end


function test_toolShop()
    local toolShop = City:GetFirstBuildingByType("toolShop")
    assert_table(toolShop)
    assert_table(toolShop:GetMakeBuildingMaterialsEvent())

    toolShop:AddToolShopListener({
        OnBeginMakeMaterialsWithEvent = function(lisenter, tool_shop, event)
            assert_equal(0, tool_shop:GetMakeBuildingMaterialsEvent():StartTime())
        end,
        OnMakingMaterialsWithEvent = function(lisenter, tool_shop, event, current_time)

        end,
        OnEndMakeMaterialsWithEvent = function(lisenter, tool_shop, event, current_time)
            assert_true(toolShop:IsStoredBuildingMaterials(current_time))
        end,
        OnGetMaterialsWithEvent = function(lisenter, tool_shop, event)
            assert_true(tool_shop:IsBuildingMaterialsEmpty())
        end,
    })

    toolShop:MakeBuildingMaterials({1}, toolShop:GetMakingTimeByCategory("building"))

    Game.new():OnUpdate(function(time)
        toolShop:OnTimer(time)
        if time == 1 then
            assert_true(toolShop:IsMakingBuildingMaterials(time))
            assert_true(not toolShop:IsBuildingMaterialsEmpty())
            assert_true(not toolShop:IsStoredBuildingMaterials(time))
            assert_equal(1, toolShop:GetMakeBuildingMaterialsEvent():ElapseTime(time))
            assert_equal(299, toolShop:GetMakeBuildingMaterialsEvent():LeftTime(time))
            assert_equal(300, toolShop:GetMakingTimeByCategory("building"))
        elseif time == toolShop:GetMakingTimeByCategory("building") then
            toolShop:EndMakeBuildingMaterials({1}, time)
        elseif time == toolShop:GetMakingTimeByCategory("building") + 1 then
            toolShop:GetBuildingMaterials()
            return false
        end
        return true
    end)
end







