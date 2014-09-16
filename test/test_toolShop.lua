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
    assert_table(toolShop:GetEvent())
    

    toolShop:AddToolShopListener({
        OnBeginMakeMaterials = function(listener, tool_shop)
            assert_equal(0, tool_shop:GetEvent():StartTime())
        end,
        OnMakingMaterials = function(listener, tool_shop, current_time)
            -- print("OnMakingMaterials", current_time)
        end,
        OnEndMakeMaterials = function(listener, tool_shop, current_time)
            assert_true(toolShop:IsStoredMaterials(current_time))
        end,
        OnGetMaterials = function(listener, tool_shop)
            assert_true(tool_shop:IsEmpty())
        end,
    })

    toolShop:MakeBuildingMaterials({}, toolShop:GetMakingTime("building"))
    Game.new():OnUpdate(function(time)
        toolShop:OnTimer(time)
        if time == 1 then
            assert_true(toolShop:IsMakingMaterials(time))
            assert_true(not toolShop:IsEmpty(time))
            assert_true(not toolShop:IsStoredMaterials(time))
            assert_equal(1, toolShop:GetEvent():ElapseTime(time))
            assert_equal(299, toolShop:GetEvent():LeftTime(time))
            assert_equal(300, toolShop:GetMakingTime("building"))
        elseif time == toolShop:GetMakingTime("building") then
            toolShop:EndMakeMaterials(time)
        elseif time == toolShop:GetMakingTime("building") + 1 then
            toolShop:GetMaterials()
            return false
        end
        return true
    end)
end





