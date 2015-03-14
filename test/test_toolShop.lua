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
    City:GenerateWalls()
end


function test_toolShop()
    local toolShop = City:GetFirstBuildingByType("toolShop")
    assert_table(toolShop)
    assert_table(toolShop:GetMakeMaterialsEventByCategory("building"))

    toolShop:AddToolShopListener({
        OnBeginMakeMaterialsWithEvent = function(lisenter, tool_shop, event)
            assert_equal(0, tool_shop:GetMakeMaterialsEventByCategory("building"):StartTime())
        end,
        OnMakingMaterialsWithEvent = function(lisenter, tool_shop, event, current_time)

        end,
        OnEndMakeMaterialsWithEvent = function(lisenter, tool_shop, event, current_time)
            assert_true(toolShop:IsStoredMaterialsByCategory("building", current_time))
        end,
        OnGetMaterialsWithEvent = function(lisenter, tool_shop, event)
            assert_true(tool_shop:IsMaterialsEmptyByCategory("building"))
        end,
    })

    toolShop:MakeMaterialsByCategoryWithFinishTime("building", {1}, toolShop:GetMakingTimeByCategory("building"))

    Game.new():OnUpdate(function(time)
        toolShop:OnTimer(time)
        if time == 1 then
            assert_true(toolShop:IsMakingMaterialsByCategory("building", time))
            assert_true(not toolShop:IsMaterialsEmptyByCategory("building"))
            assert_true(not toolShop:IsStoredMaterialsByCategory("building", time))
            assert_equal(1, toolShop:GetMakeMaterialsEventByCategory("building"):ElapseTime(time))
            assert_equal(9, toolShop:GetMakeMaterialsEventByCategory("building"):LeftTime(time))
            assert_equal(10, toolShop:GetMakingTimeByCategory("building"))
        elseif time == toolShop:GetMakingTimeByCategory("building") then
            toolShop:EndMakeMaterialsByCategoryWithCurrentTime("building", {1}, time)
        elseif time == toolShop:GetMakingTimeByCategory("building") + 1 then
            toolShop:GetMaterialsByCategory("building")
            return false
        end
        return true
    end)
end







